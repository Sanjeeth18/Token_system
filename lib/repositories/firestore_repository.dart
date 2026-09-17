import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/error/app_exception.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

/// Central Firestore data layer. All Firebase operations go through this class.
///
/// No credentials are hardcoded here. Firebase is initialised via
/// `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).
class FirestoreRepository {
  FirestoreRepository._();
  static final FirestoreRepository instance = FirestoreRepository._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final String _today = DateFormat('dd-MM-yyyy').format(DateTime.now());

  // ─── Auth ────────────────────────────────────────────────────────────────────

  /// Validates credentials and returns the authenticated [UserSession].
  ///
  /// Checks Admin → Manager → Employee → Student collections in order.
  /// Throws [InvalidCredentialsException] when not found / wrong password.
  Future<UserSession> checkCredentials(
      String username, String password) async {
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      throw const InvalidCredentialsException();
    }

    // Determine collection order by prefix
    final role = UserRole.fromUsername(trimmedUser);
    if (role == null) throw const InvalidCredentialsException();

    try {
      final doc = await _db
          .collection(role.firestoreCollection)
          .doc(trimmedUser)
          .get();

      if (!doc.exists) throw const InvalidCredentialsException();

      final storedPw = doc.data()?[AppConstants.fieldPassword] as String?;
      if (storedPw != trimmedPass) throw const InvalidCredentialsException();

      final name = doc.data()?[AppConstants.fieldName] as String? ?? trimmedUser;
      return UserSession(id: trimmedUser, name: name, role: role);
    } on InvalidCredentialsException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // ─── Student Token Data ───────────────────────────────────────────────────────

  /// Reads current token holdings for a student.
  Future<StudentTokens> getStudentTokens(String roll) async {
    try {
      final snap =
          await _db.collection(AppConstants.colStudents).doc(roll).get();
      if (!snap.exists) return StudentTokens.empty;
      return StudentTokens.fromMap(snap.data()!);
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  /// Purchases tokens for a student, decrementing the global Tokens/Counts doc.
  ///
  /// Returns the updated [StudentTokens] after the purchase.
  Future<StudentTokens> purchaseTokens(
      String roll, TokenSelection selection) async {
    try {
      final studentRef =
          _db.collection(AppConstants.colStudents).doc(roll);
      final countsRef = _db
          .collection(AppConstants.colTokens)
          .doc(AppConstants.docTokenCounts);

      return await _db.runTransaction((tx) async {
        final studentSnap = await tx.get(studentRef);
        final countsSnap = await tx.get(countsRef);

        if (!studentSnap.exists) {
          throw const UserNotFoundException('student');
        }

        final current = StudentTokens.fromMap(studentSnap.data()!);
        final counts = countsSnap.exists
            ? TokenCounts.fromMap(countsSnap.data()!)
            : TokenCounts.empty;

        int newVeg = current.veg;
        int newNonVeg = current.nonVeg;
        int newEggs = current.eggs;

        // Veg purchase
        if (selection.wantsVeg) {
          if (current.veg > 0) {
            throw const TokenException(
                TokenErrorType.alreadyUsed, 'Veg token already purchased.');
          }
          if (counts.veg <= 0) {
            throw const TokenException(
                TokenErrorType.soldOut, 'Veg tokens are sold out.');
          }
          newVeg = 1;
          tx.update(countsRef, {
            AppConstants.fieldVeg: FieldValue.increment(-1),
            AppConstants.fieldVegPurchased: FieldValue.increment(1),
          });
        }

        // Non-Veg purchase
        if (selection.wantsNonVeg) {
          if (current.nonVeg > 0) {
            throw const TokenException(
                TokenErrorType.alreadyUsed, 'Non-Veg token already purchased.');
          }
          if (counts.nonVeg <= 0) {
            throw const TokenException(
                TokenErrorType.soldOut, 'Non-Veg tokens are sold out.');
          }
          newNonVeg = 1;
          tx.update(countsRef, {
            AppConstants.fieldNonVeg: FieldValue.increment(-1),
            AppConstants.fieldNonVegPurchased: FieldValue.increment(1),
          });
        }

        // Eggs — no global count, just set the value
        if (selection.eggCount > 0) {
          newEggs = selection.eggCount;
        }

        final updated = StudentTokens(
            veg: newVeg, nonVeg: newNonVeg, eggs: newEggs);

        tx.update(studentRef, {
          AppConstants.fieldVeg: updated.veg,
          AppConstants.fieldNonVeg: updated.nonVeg,
          AppConstants.fieldEggs: updated.eggs,
        });

        return updated;
      });
    } on TokenException {
      rethrow;
    } on UserNotFoundException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // ─── QR Redemption (Employee Scanner) ────────────────────────────────────────

  /// Decrements tokens for a student after scanning their QR.
  ///
  /// [qrData] format: "<roll> <type> <count>"
  /// e.g., "23EE01 Veg 1" or "23EE01 Non-Veg 1" or "23EE01 Eggs 3"
  Future<StudentTokens> redeemToken(String qrData) async {
    final parts = qrData.trim().split(' ');
    if (parts.length < 3) throw const InvalidQrDataException();

    final roll = parts[0];
    final type = parts[1].toLowerCase();
    final count = int.tryParse(parts[2]) ?? 0;

    if (count <= 0) throw const InvalidQrDataException();

    try {
      final studentRef =
          _db.collection(AppConstants.colStudents).doc(roll);

      return await _db.runTransaction((tx) async {
        final snap = await tx.get(studentRef);
        if (!snap.exists) throw UserNotFoundException(roll);

        final current = StudentTokens.fromMap(snap.data()!);

        int newVeg = current.veg;
        int newNonVeg = current.nonVeg;
        int newEggs = current.eggs;

        if (type == 'veg') {
          if (current.veg <= 0) {
            throw const TokenException(TokenErrorType.alreadyUsed,
                'Veg token not purchased or already used.');
          }
          newVeg = (current.veg - count).clamp(0, current.veg);
        } else if (type == 'non-veg' || type == 'nonveg') {
          if (current.nonVeg <= 0) {
            throw const TokenException(TokenErrorType.alreadyUsed,
                'Non-Veg token not purchased or already used.');
          }
          newNonVeg = (current.nonVeg - count).clamp(0, current.nonVeg);
        } else if (type == 'eggs' || type == 'egg') {
          if (current.eggs <= 0) {
            throw const TokenException(TokenErrorType.alreadyUsed,
                'Egg token not purchased or already used.');
          }
          newEggs = (current.eggs - count).clamp(0, current.eggs);
        } else {
          throw const InvalidQrDataException();
        }

        final updated =
            StudentTokens(veg: newVeg, nonVeg: newNonVeg, eggs: newEggs);

        tx.update(studentRef, {
          AppConstants.fieldVeg: updated.veg,
          AppConstants.fieldNonVeg: updated.nonVeg,
          AppConstants.fieldEggs: updated.eggs,
        });

        return updated;
      });
    } on TokenException {
      rethrow;
    } on UserNotFoundException {
      rethrow;
    } on InvalidQrDataException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // ─── Token Count Management (Manager / Admin) ─────────────────────────────────

  Future<TokenCounts> getTokenCounts() async {
    try {
      final snap = await _db
          .collection(AppConstants.colTokens)
          .doc(AppConstants.docTokenCounts)
          .get();
      if (!snap.exists) return TokenCounts.empty;
      return TokenCounts.fromMap(snap.data()!);
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  Future<void> setTokenCount(String type, int count) async {
    try {
      final ref = _db
          .collection(AppConstants.colTokens)
          .doc(AppConstants.docTokenCounts);
      final snap = await ref.get();
      if (!snap.exists) {
        // Create document with all fields
        await ref.set({
          AppConstants.fieldVeg: 0,
          AppConstants.fieldNonVeg: 0,
          AppConstants.fieldVegPurchased: 0,
          AppConstants.fieldNonVegPurchased: 0,
        });
      }
      if (type == 'veg') {
        await ref.update({AppConstants.fieldVeg: count});
      } else if (type == 'non-veg') {
        await ref.update({AppConstants.fieldNonVeg: count});
      }
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // ─── User Creation ────────────────────────────────────────────────────────────

  Future<void> createStudent({
    required String roll,
    required String name,
    required String course,
    required String dob,
    required String doj,
    required String password,
  }) async {
    try {
      final ref =
          _db.collection(AppConstants.colStudents).doc(roll);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(roll);
      await ref.set({
        AppConstants.fieldName: name,
        AppConstants.fieldCourse: course,
        AppConstants.fieldDob: dob,
        AppConstants.fieldDoj: doj,
        AppConstants.fieldCreatedAt: _today,
        AppConstants.fieldPassword: password,
        AppConstants.fieldRole: AppConstants.roleStudent,
        AppConstants.fieldVeg: 0,
        AppConstants.fieldNonVeg: 0,
        AppConstants.fieldEggs: 0,
      });
    } on UserAlreadyExistsException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  Future<void> createEmployee({
    required String id,
    required String name,
    required String dob,
    required String doj,
    required String password,
  }) async {
    try {
      final ref =
          _db.collection(AppConstants.colEmployees).doc(id);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(id);
      await ref.set({
        AppConstants.fieldName: name,
        AppConstants.fieldDob: dob,
        AppConstants.fieldDoj: doj,
        AppConstants.fieldCreatedAt: _today,
        AppConstants.fieldPassword: password,
        AppConstants.fieldRole: AppConstants.roleEmployee,
      });
    } on UserAlreadyExistsException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  /// Only callable by Admin — creates a Manager account.
  Future<void> createManager({
    required String id,
    required String name,
    required String password,
    required UserSession currentUser,
  }) async {
    if (!currentUser.role.isAdmin) {
      throw const PermissionDeniedException();
    }
    try {
      final ref = _db.collection(AppConstants.colManagers).doc(id);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(id);
      await ref.set({
        AppConstants.fieldName: name,
        AppConstants.fieldCreatedAt: _today,
        AppConstants.fieldPassword: password,
        AppConstants.fieldRole: AppConstants.roleManager,
      });
    } on UserAlreadyExistsException {
      rethrow;
    } on PermissionDeniedException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // ─── User Deletion ────────────────────────────────────────────────────────────

  /// Deletes a user from the appropriate collection.
  ///
  /// - Managers can delete Students and Employees only.
  /// - Admins can delete Students, Employees, and Managers.
  /// - No one can delete Admins.
  Future<void> deleteUser(String id, UserSession currentUser) async {
    // Prevent any deletion of admin accounts
    if (id[0].toLowerCase() == AppConstants.prefixAdmin) {
      throw const PermissionDeniedException();
    }

    final targetRole = UserRole.fromUsername(id);
    if (targetRole == null) throw const UserNotFoundException('unknown');
    if (!currentUser.role.canManage(targetRole)) {
      throw const PermissionDeniedException();
    }

    try {
      final ref =
          _db.collection(targetRole.firestoreCollection).doc(id);
      final snap = await ref.get();
      if (!snap.exists) throw UserNotFoundException(id);
      await ref.delete();
    } on UserNotFoundException {
      rethrow;
    } on PermissionDeniedException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }
}

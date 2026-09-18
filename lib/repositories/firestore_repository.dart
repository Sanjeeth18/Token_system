import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/error/app_exception.dart';
import '../core/utils/date_utils.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

/// Central Firestore and Firebase Auth data layer. All app backend operations go through this class.
class FirestoreRepository {
  FirestoreRepository._();
  static final FirestoreRepository instance = FirestoreRepository._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  final String _today = DateFormat('dd-MM-yyyy').format(DateTime.now());

  // Auto ID Generation

  /// Auto-generates the next sequential User ID for the specified [role].
  ///
  /// Examples:
  /// - Student: M101, M102, M103...
  /// - Staff / Employee: E101, E102...
  /// - Manager: M101, M102...
  /// - Admin: A101, A102...
  Future<String> generateNextUserId(UserRole role) async {
    try {
      final String prefix;
      switch (role) {
        case UserRole.student:
          prefix = 'S';
          break;
        case UserRole.employee:
          prefix = 'E';
          break;
        case UserRole.manager:
          prefix = 'M';
          break;
        case UserRole.admin:
          prefix = 'A';
          break;
      }

      final snapshot = await _db.collection(role.firestoreCollection).get();
      int maxId = 0; // Sequence starts at 001

      final RegExp numberRegExp = RegExp(r'\d+');

      for (final doc in snapshot.docs) {
        final docId = doc.id.trim();
        final match = numberRegExp.firstMatch(docId);
        if (match != null) {
          final parsed = int.tryParse(match.group(0)!);
          if (parsed != null && parsed > maxId) {
            maxId = parsed;
          }
        }
      }

      final nextNum = maxId + 1;
      return '$prefix${nextNum.toString().padLeft(3, '0')}';
    } catch (e) {
      final String prefix;
      switch (role) {
        case UserRole.employee:
          prefix = 'E';
          break;
        case UserRole.manager:
          prefix = 'M';
          break;
        case UserRole.admin:
          prefix = 'A';
          break;
        default:
          prefix = 'S';
      }
      return '${prefix}001';
    }
  }

  // Auth

  /// Searches for a user document across collections by doc ID, email, or Firebase Auth UID.
  Future<({DocumentSnapshot doc, UserRole role})?> _findUserDoc({
    String? identifier,
    String? email,
    String? uid,
  }) async {
    final uppercaseId = identifier?.toUpperCase().trim();

    // 1. Direct doc ID lookup with smart prefix ordering
    if (uppercaseId != null && uppercaseId.isNotEmpty) {
      List<(UserRole, String)> targetCollections = [];
      if (uppercaseId.startsWith('A')) {
        targetCollections = [(UserRole.admin, AppConstants.colAdmins)];
      } else if (uppercaseId.startsWith('E')) {
        targetCollections = [(UserRole.employee, AppConstants.colEmployees)];
      } else if (uppercaseId.startsWith('M')) {
        // Manager IDs start with 'M' (e.g. M101). Students can also have M prefix or Roll Number.
        targetCollections = [
          (UserRole.manager, AppConstants.colManagers),
          (UserRole.student, AppConstants.colStudents),
        ];
      } else {
        targetCollections = [
          (UserRole.student, AppConstants.colStudents),
          (UserRole.manager, AppConstants.colManagers),
          (UserRole.employee, AppConstants.colEmployees),
          (UserRole.admin, AppConstants.colAdmins),
        ];
      }

      for (final (role, colName) in targetCollections) {
        try {
          final doc = await _db.collection(colName).doc(uppercaseId).get();
          if (doc.exists) {
            return (doc: doc, role: role);
          }
        } catch (e) {
          // Swallow permission errors on restricted collections during lookup
        }
      }
    }

    final allCollections = [
      (UserRole.student, AppConstants.colStudents),
      (UserRole.manager, AppConstants.colManagers),
      (UserRole.employee, AppConstants.colEmployees),
      (UserRole.admin, AppConstants.colAdmins),
    ];

    // 2. Email lookup across collections
    if (email != null && email.isNotEmpty) {
      for (final (role, colName) in allCollections) {
        try {
          final query = await _db
              .collection(colName)
              .where(AppConstants.fieldEmail, isEqualTo: email.trim().toLowerCase())
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            return (doc: query.docs.first, role: role);
          }
        } catch (_) {}
      }
    }

    // 3. UID lookup across collections
    if (uid != null && uid.isNotEmpty) {
      for (final (role, colName) in allCollections) {
        try {
          final query = await _db
              .collection(colName)
              .where(AppConstants.fieldUid, isEqualTo: uid)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            return (doc: query.docs.first, role: role);
          }
        } catch (_) {}
      }
    }

    return null;
  }

  /// Validates credentials via Firebase Auth and returns the authenticated [UserSession].
  Future<UserSession> checkCredentials(
      String inputIdentifier, String password) async {
    final trimmedId = inputIdentifier.trim();
    final trimmedPass = password.trim();

    if (trimmedId.isEmpty || trimmedPass.isEmpty) {
      throw const InvalidCredentialsException();
    }

    // Determine target email for Firebase Auth login
    String authEmail;
    if (trimmedId.contains('@')) {
      authEmail = trimmedId.toLowerCase();
    } else {
      authEmail = '${trimmedId.toLowerCase()}@psgtoken.com';
    }

    try {
      UserCredential? credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: authEmail,
          password: trimmedPass,
        );
      } on FirebaseAuthException catch (e) {
        if (!trimmedId.contains('@')) {
          final foundDoc = await _findUserDoc(identifier: trimmedId);
          if (foundDoc != null) {
            final data = foundDoc.doc.data() as Map<String, dynamic>?;
            final storedEmail = data?[AppConstants.fieldEmail] as String?;
            if (storedEmail != null && storedEmail.isNotEmpty && storedEmail != authEmail) {
              try {
                credential = await _auth.signInWithEmailAndPassword(
                  email: storedEmail,
                  password: trimmedPass,
                );
              } catch (_) {
                throw const InvalidCredentialsException();
              }
            } else {
              throw const InvalidCredentialsException();
            }
          } else {
            throw const InvalidCredentialsException();
          }
        } else {
          if (e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential' ||
              e.code == 'invalid-email') {
            throw const InvalidCredentialsException();
          }
          throw const InvalidCredentialsException();
        }
      }

      final User? authUser = credential.user;
      final activeUid = authUser?.uid;
      final activeEmail = authUser?.email ?? authEmail;

      // Locate user profile document in Firestore
      final found = await _findUserDoc(
        identifier: trimmedId.contains('@') ? null : trimmedId,
        email: activeEmail,
        uid: activeUid,
      );

      if (found == null) {
        final fallbackRole = UserRole.fromUsername(trimmedId) ?? UserRole.student;
        return UserSession(
          id: trimmedId.contains('@') ? trimmedId.split('@').first.toUpperCase() : trimmedId.toUpperCase(),
          name: trimmedId.split('@').first,
          role: fallbackRole,
          email: activeEmail,
          uid: activeUid,
        );
      }

      final data = found.doc.data() as Map<String, dynamic>;
      final role = found.role;
      final docId = found.doc.id;

      final name = data[AppConstants.fieldName] as String? ?? docId;
      final email = data[AppConstants.fieldEmail] as String? ?? activeEmail;
      final department = data[AppConstants.fieldCourse] as String? ??
          data[AppConstants.fieldDepartment] as String? ??
          'General';
      final photoUrl = data[AppConstants.fieldPhotoUrl] as String?;
      final dob = data[AppConstants.fieldDob] as String?;
      final doj = data[AppConstants.fieldDoj] as String?;
      final uid = activeUid ?? data[AppConstants.fieldUid] as String?;

      return UserSession(
        id: docId,
        name: name,
        role: role,
        email: email,
        department: department,
        photoUrl: photoUrl,
        uid: uid,
        dob: dob,
        doj: doj,
      );
    } on InvalidCredentialsException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  /// Signs out current Firebase Auth session.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // Profile Update

  /// Updates profile details in Firestore (Name, Department/Course, Photo URL).
  Future<void> updateUserProfile({
    required String userId,
    required UserRole role,
    String? name,
    String? department,
    String? photoUrl,
  }) async {
    try {
      final ref = _db.collection(role.firestoreCollection).doc(userId);
      final updates = <String, dynamic>{};

      if (name != null && name.trim().isNotEmpty) {
        updates[AppConstants.fieldName] = name.trim();
      }
      if (department != null && department.trim().isNotEmpty) {
        if (role == UserRole.student) {
          updates[AppConstants.fieldCourse] = department.trim();
        }
        updates[AppConstants.fieldDepartment] = department.trim();
      }
      if (photoUrl != null && photoUrl.trim().isNotEmpty) {
        updates[AppConstants.fieldPhotoUrl] = photoUrl.trim();
      }

      if (updates.isNotEmpty) {
        await ref.update(updates);
      }
    } catch (e) {
      throw FirestoreException('Failed to update profile: $e');
    }
  }

  // Student Token Data

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
  Future<StudentTokens> purchaseTokens(
      String roll, TokenSelection selection) async {
    try {
      final studentRef =
          _db.collection(AppConstants.colStudents).doc(roll);
      final countsRef = _db
          .collection(AppConstants.colTokens)
          .doc(AppConstants.docTokenCounts);

      final result = await _db.runTransaction((tx) async {
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
          final nextMealDate = MealDateUtils.getNextMealDate();
          if (!MealDateUtils.isNonVegAvailable(nextMealDate)) {
            throw const TokenException(
                TokenErrorType.alreadyUsed, 'Non-Veg meal is not served on this dining schedule.');
          }
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

        // Eggs (cumulative addition in batches of 15)
        if (selection.eggCount > 0) {
          newEggs = current.eggs + selection.eggCount;
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

      // Record transaction logs
      final now = DateTime.now();
      final dateStr = DateFormat('dd-MM-yyyy').format(now);
      final timeStr = DateFormat('hh:mm a').format(now);

      if (selection.wantsVeg) {
        await _db.collection(AppConstants.colPurchases).add({
          'rollNumber': roll,
          'category': 'veg',
          'count': 1,
          'date': dateStr,
          'time': timeStr,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      if (selection.wantsNonVeg) {
        await _db.collection(AppConstants.colPurchases).add({
          'rollNumber': roll,
          'category': 'nonveg',
          'count': 1,
          'date': dateStr,
          'time': timeStr,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      if (selection.eggCount > 0) {
        await _db.collection(AppConstants.colPurchases).add({
          'rollNumber': roll,
          'category': 'egg',
          'count': selection.eggCount,
          'date': dateStr,
          'time': timeStr,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      return result;
    } on TokenException {
      rethrow;
    } on UserNotFoundException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  /// Fetches detailed transaction history for a student.
  Future<List<TokenTransactionModel>> getStudentTransactionHistory(String roll) async {
    try {
      final snap = await _db.collection(AppConstants.colPurchases).get();
      final list = <TokenTransactionModel>[];
      final targetRoll = roll.trim().toUpperCase();

      for (final doc in snap.docs) {
        final data = doc.data();
        final docRoll = (data['rollNumber'] as String? ?? '').trim().toUpperCase();
        if (docRoll == targetRoll) {
          list.add(TokenTransactionModel.fromFirestore(doc));
        }
      }

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      return [];
    }
  }

  // QR Redemption (Employee Scanner)

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
                'QR code already used.');
          }
          newVeg = (current.veg - count).clamp(0, current.veg);
        } else if (type == 'non-veg' || type == 'nonveg') {
          if (current.nonVeg <= 0) {
            throw const TokenException(TokenErrorType.alreadyUsed,
                'QR code already used.');
          }
          newNonVeg = (current.nonVeg - count).clamp(0, current.nonVeg);
        } else if (type == 'eggs' || type == 'egg') {
          if (current.eggs <= 0) {
            throw const TokenException(TokenErrorType.alreadyUsed,
                'QR code already used.');
          }
          if (current.eggs < count) {
            throw TokenException(TokenErrorType.insufficientCount,
                'Insufficient egg tokens. Student has ${current.eggs} egg(s) available.');
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

  // Token Count Management (Manager / Admin)

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

  // Member Retrieval (Admin & Manager)

  /// Fetches all members in the system grouped by UserRole (Admin, Manager, Staff, Student).
  Future<Map<UserRole, List<UserSession>>> getAllMembersGrouped() async {
    final result = <UserRole, List<UserSession>>{
      UserRole.admin: [],
      UserRole.manager: [],
      UserRole.employee: [],
      UserRole.student: [],
    };

    final collections = [
      (UserRole.admin, AppConstants.colAdmins),
      (UserRole.manager, AppConstants.colManagers),
      (UserRole.employee, AppConstants.colEmployees),
      (UserRole.student, AppConstants.colStudents),
    ];

    for (final (role, colName) in collections) {
      try {
        final snap = await _db.collection(colName).get();
        final list = <UserSession>[];
        for (final doc in snap.docs) {
          final data = doc.data();
          list.add(UserSession(
            id: doc.id,
            name: data[AppConstants.fieldName] as String? ?? doc.id,
            role: role,
            email: data[AppConstants.fieldEmail] as String?,
            department: data[AppConstants.fieldCourse] as String? ??
                data[AppConstants.fieldDepartment] as String?,
            photoUrl: data[AppConstants.fieldPhotoUrl] as String?,
            uid: data[AppConstants.fieldUid] as String?,
            dob: data[AppConstants.fieldDob] as String?,
            doj: data[AppConstants.fieldDoj] as String?,
          ));
        }
        result[role] = list;
      } catch (_) {}
    }

    return result;
  }

  /// Fetches all users eligible for deletion by [currentUser].
  Future<List<UserSession>> getAllEligibleDeleteUsers(UserSession currentUser) async {
    final list = <UserSession>[];
    final collections = <(UserRole, String)>[];

    if (currentUser.role.isAdmin) {
      collections.addAll([
        (UserRole.manager, AppConstants.colManagers),
        (UserRole.employee, AppConstants.colEmployees),
        (UserRole.student, AppConstants.colStudents),
      ]);
    } else if (currentUser.role.isManagerOrAbove) {
      collections.addAll([
        (UserRole.employee, AppConstants.colEmployees),
        (UserRole.student, AppConstants.colStudents),
      ]);
    }

    for (final (role, colName) in collections) {
      try {
        final snap = await _db.collection(colName).get();
        for (final doc in snap.docs) {
          final data = doc.data();
          list.add(UserSession(
            id: doc.id,
            name: data[AppConstants.fieldName] as String? ?? doc.id,
            role: role,
            email: data[AppConstants.fieldEmail] as String?,
            department: data[AppConstants.fieldCourse] as String? ??
                data[AppConstants.fieldDepartment] as String?,
            photoUrl: data[AppConstants.fieldPhotoUrl] as String?,
            uid: data[AppConstants.fieldUid] as String?,
            dob: data[AppConstants.fieldDob] as String?,
            doj: data[AppConstants.fieldDoj] as String?,
          ));
        }
      } catch (_) {}
    }

    return list;
  }

  // User Creation with Firebase Auth & Firestore

  Future<void> createStudent({
    required String roll,
    required String name,
    required String course,
    required String dob,
    required String doj,
    String? customEmail,
    String password = AppConstants.defaultPassword,
  }) async {
    try {
      final ref = _db.collection(AppConstants.colStudents).doc(roll);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(roll);

      final userEmail = (customEmail != null && customEmail.trim().isNotEmpty)
          ? customEmail.trim().toLowerCase()
          : '${roll.toLowerCase()}@psgtoken.com';
      String? uid;

      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: userEmail,
          password: password,
        );
        uid = credential.user?.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw UserAlreadyExistsException(roll);
        }
      }

      await ref.set({
        AppConstants.fieldUid: uid,
        AppConstants.fieldName: name,
        AppConstants.fieldEmail: userEmail,
        AppConstants.fieldCourse: course,
        AppConstants.fieldDepartment: course,
        AppConstants.fieldDob: dob,
        AppConstants.fieldDoj: doj,
        AppConstants.fieldCreatedAt: _today,
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
    String? customEmail,
    String password = AppConstants.defaultPassword,
  }) async {
    try {
      final ref = _db.collection(AppConstants.colEmployees).doc(id);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(id);

      final userEmail = (customEmail != null && customEmail.trim().isNotEmpty)
          ? customEmail.trim().toLowerCase()
          : '${id.toLowerCase()}@psgtoken.com';
      String? uid;

      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: userEmail,
          password: password,
        );
        uid = credential.user?.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw UserAlreadyExistsException(id);
        }
      }

      await ref.set({
        AppConstants.fieldUid: uid,
        AppConstants.fieldName: name,
        AppConstants.fieldEmail: userEmail,
        AppConstants.fieldDepartment: 'Staff / Service',
        AppConstants.fieldDob: dob,
        AppConstants.fieldDoj: doj,
        AppConstants.fieldCreatedAt: _today,
        AppConstants.fieldRole: AppConstants.roleEmployee,
      });
    } on UserAlreadyExistsException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  Future<void> createManager({
    required String id,
    required String name,
    required UserSession currentUser,
    String? customEmail,
    String password = AppConstants.defaultPassword,
  }) async {
    if (!currentUser.role.isAdmin) {
      throw const PermissionDeniedException();
    }
    try {
      final ref = _db.collection(AppConstants.colManagers).doc(id);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(id);

      final userEmail = (customEmail != null && customEmail.trim().isNotEmpty)
          ? customEmail.trim().toLowerCase()
          : '${id.toLowerCase()}@psgtoken.com';
      String? uid;

      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: userEmail,
          password: password,
        );
        uid = credential.user?.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw UserAlreadyExistsException(id);
        }
      }

      await ref.set({
        AppConstants.fieldUid: uid,
        AppConstants.fieldName: name,
        AppConstants.fieldEmail: userEmail,
        AppConstants.fieldDepartment: 'Mess Administration',
        AppConstants.fieldCreatedAt: _today,
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

  Future<void> createAdmin({
    required String id,
    required String name,
    required UserSession currentUser,
    String? customEmail,
    String password = AppConstants.defaultPassword,
  }) async {
    if (!currentUser.role.isAdmin) {
      throw const PermissionDeniedException();
    }
    try {
      final ref = _db.collection(AppConstants.colAdmins).doc(id);
      if ((await ref.get()).exists) throw UserAlreadyExistsException(id);

      final userEmail = (customEmail != null && customEmail.trim().isNotEmpty)
          ? customEmail.trim().toLowerCase()
          : '${id.toLowerCase()}@psgtoken.com';
      String? uid;

      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: userEmail,
          password: password,
        );
        uid = credential.user?.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw UserAlreadyExistsException(id);
        }
      }

      await ref.set({
        AppConstants.fieldUid: uid,
        AppConstants.fieldName: name,
        AppConstants.fieldEmail: userEmail,
        AppConstants.fieldDepartment: 'System Administration',
        AppConstants.fieldCreatedAt: _today,
        AppConstants.fieldRole: AppConstants.roleAdmin,
      });
    } on UserAlreadyExistsException {
      rethrow;
    } on PermissionDeniedException {
      rethrow;
    } catch (e) {
      throw FirestoreException(e.toString());
    }
  }

  // User Deletion

  Future<void> deleteUser(String id, UserSession currentUser) async {
    if (id[0].toLowerCase() == AppConstants.prefixAdmin) {
      throw const PermissionDeniedException();
    }

    final targetRole = UserRole.fromUsername(id);
    if (targetRole == null) throw const UserNotFoundException('unknown');
    if (!currentUser.role.canManage(targetRole)) {
      throw const PermissionDeniedException();
    }

    try {
      final ref = _db.collection(targetRole.firestoreCollection).doc(id);
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


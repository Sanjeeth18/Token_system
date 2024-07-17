import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Firestore {
  DateTime now = DateTime.now();
  late String date =
      DateFormat('dd-MM-yyyy').format(DateTime(now.year, now.month, now.day));

  Future<bool> checkCredentials(
      BuildContext context, String username, String password) async {
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(username)
          .get();
      if (studentDoc.exists) {
        final storedPassword = studentDoc.data()?['Password'];
        if (storedPassword == password) {
          return true;
        }
      }

      final employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(username)
          .get();
      if (employeeDoc.exists) {
        final storedPassword = employeeDoc.data()?['Password'];
        if (storedPassword == password) {
          return true;
        }
      }

      final managerDoc = await FirebaseFirestore.instance
          .collection('Manager')
          .doc(username)
          .get();
      if (managerDoc.exists) {
        final storedPassword = managerDoc.data()?['Password'];
        if (storedPassword == password) {
          return true;
        }
      }

      showalert(context, 'Error',
          'The username does not exist or password is incorrect');
      return false;
    } catch (e) {
      showalert(context, 'Error',
          'An unexpected error occurred. Please try again later.');
      return false;
    }
  }

  Future<bool> CreateStudent(String name, String roll, String course,
      String dob, String doj, String password) async {
    final students =
        await FirebaseFirestore.instance.collection("Students").doc(roll).get();

    try {
      if (students.exists) {
        return false;
      } else {
        await FirebaseFirestore.instance.collection("Students").doc(roll).set({
          'name': name,
          'course': course,
          'Date of Birth': dob,
          'Date of Join': doj,
          'Date of created': date,
          'Password': password,
          'veg': 0,
          'non-veg': 0,
          'eggs': 0
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> CreateEmployee(
      String name, String ID, String dob, String doj, String password) async {
    final employee =
        await FirebaseFirestore.instance.collection("Employees").doc(ID).get();

    try {
      if (employee.exists) {
        return false;
      } else {
        await FirebaseFirestore.instance.collection("Employees").doc(ID).set({
          'name': name,
          'Date of Birth': dob,
          'Date of Join': doj,
          'Date of created': date,
          'Password': password
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<int>> readstudentTokenData(List<int> token, String roll) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .doc(roll)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        int veg = data?['veg'] ?? 0;
        int nonveg = data?['non-veg'] ?? 0;
        int eggs = data?['eggs'] ?? 0;
        return [nonveg, veg, eggs];
      } else {
        return [0, 0, 0];
      }
    } catch (e) {
      return [0, 0, 0];
    }
  }

  Future<List<int>> checkAndInsertTokenData(
      BuildContext context, List<int> token, String roll, bool opening) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .doc(roll)
          .get();

      final total = await FirebaseFirestore.instance
          .collection("Tokens")
          .doc("Counts")
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        Map<String, dynamic>? total_counts = total.data();
        int veg = data?['veg'] ?? 0;
        int nonveg = data?['non-veg'] ?? 0;
        int eggs = data?['eggs'] ?? 0;
        int veg_tokens = total_counts?['veg'] ?? '0';
        int nonveg_tokens = total_counts?['non-veg'] ?? '0';
        if (veg == 0 && token[1] == 1 && veg_tokens != 0) {
          veg = token[1];
          await FirebaseFirestore.instance
              .collection("Tokens")
              .doc("Counts")
              .update({
            "veg": FieldValue.increment(-1),
            "veg_purchased": FieldValue.increment(1)
          });
        } else if (token[1] == 0) {
        } else {
          showalert(context, "Error", "Veg Tokens are sold out");
        }
        if (nonveg == 0 && token[0] == 1 && nonveg_tokens != 0) {
          nonveg = token[0];
          await FirebaseFirestore.instance
              .collection("Tokens")
              .doc("Counts")
              .update({
            "non-veg": FieldValue.increment(-1),
            "non-veg_purchased": FieldValue.increment(1)
          });
        } else if (token[0] == 0) {
        } else {
          showalert(context, "Error", "Non-veg Tokens are sold out");
        }
        if (token[2] != 0) {
          eggs = token[2];
        }
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(roll)
            .update({
          'veg': veg,
          'non-veg': nonveg,
          'eggs': eggs,
        });

        return [nonveg, veg, eggs];
      } else {
        return [0, 0, 0];
      }
    } catch (e) {
      return [0, 0, 0];
    }
  }

  Future<List<dynamic>> checkAndDecrementTokenData(
      List<int> token, String roll) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Students')
          .doc(roll)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        int veg = data?['veg'] ?? 0;
        int nonveg = data?['non-veg'] ?? 0;
        int eggs = data?['eggs'] ?? 0;

        if ((token[1] > 0 && veg == 0) || (token[0] > 0 && nonveg == 0)) {
          return ['already_used', nonveg, veg, eggs];
        }

        if (token[1] > 0) {
          veg = (veg - token[1]).clamp(0, veg);
        }
        if (token[0] > 0) {
          nonveg = (nonveg - token[0]).clamp(0, nonveg);
        }
        if (token[2] > 0) {
          eggs = (eggs - token[2]).clamp(0, eggs);
        }

        await FirebaseFirestore.instance
            .collection('Students')
            .doc(roll)
            .update({
          'veg': veg,
          'non-veg': nonveg,
          'eggs': eggs,
        });

        return ['success', nonveg, veg, eggs];
      } else {
        return ['not_exist', 0, 0, 0];
      }
    } catch (e) {
      return ['error', 0, 0, 0];
    }
  }

  Future<void> createToken(int count, String type) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection("Tokens").doc("Counts");
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        if (type == 'veg') {
          await docRef.update({'veg': count});
        } else if (type == 'non') {
          await docRef.update({'non': count});
        }
      }
    } catch (e) {}
  }

  Future<List<int>> readTokens() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Tokens")
          .doc("Counts")
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        int veg = data?['veg'] ?? 0;
        int nonveg = data?['non-veg'] ?? 0;
        int vegpurchased = data?['veg_purchased'] ?? 0;
        int nonvegpurchased = data?['non-veg_purchased'] ?? 0;

        return [nonveg, veg, nonvegpurchased, vegpurchased];
      } else {
        return [0, 0, 0, 0];
      }
    } catch (e) {
      return [0, 0, 0, 0];
    }
  }

  Future<bool> delete_student_employee(String id) async {
    final students =
        await FirebaseFirestore.instance.collection("Students").doc(id);
    final employee =
        await FirebaseFirestore.instance.collection("Employees").doc(id);

    final snapshot1 = await students.get();
    final snapshot2 = await employee.get();

    if (snapshot1.exists) {
      await students.delete();
      return true;
    }
    if (snapshot2.exists) {
      await employee.delete();
      return true;
    } else {
      return false;
    }
  }

  void showalert(BuildContext context, String text, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

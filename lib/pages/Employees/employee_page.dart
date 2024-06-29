import 'package:flutter/material.dart';

class workerMenu extends StatefulWidget {
  const workerMenu({super.key});

  @override
  State<workerMenu> createState() => _workerMenuState();
}

class _workerMenuState extends State<workerMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/scan');
                  },
                  child: const Text("Scan QR code"),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: const Text("Log Out")),
              ),
            )
          ],
        ),
      ),
    );
  }
}

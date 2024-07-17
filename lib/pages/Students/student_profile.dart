import 'package:flutter/material.dart';

class studentProfile extends StatefulWidget {
  const studentProfile({super.key});

  @override
  State<studentProfile> createState() => _studentProfileState();
}

class _studentProfileState extends State<studentProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xff000428), Color(0xff004e92)]),
      ),
      child: Scaffold(backgroundColor: Colors.transparent, body: Container()),
    );
  }
}

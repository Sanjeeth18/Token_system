import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Nveg_use extends StatefulWidget {
  final String roll;
  Nveg_use({super.key, required this.roll});

  @override
  State<Nveg_use> createState() => _Nveg_useState();
}

class _Nveg_useState extends State<Nveg_use> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff000428), Color(0xff004e92)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(
              flex: 7,
            ),
            const Text(
              'Non-Veg Token',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const Spacer(
              flex: 1,
            ),
            const Text(
              'Scan to use',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            const Spacer(
              flex: 4,
            ),
            QrImageView(
              data: '${widget.roll} Non-Veg 1',
              backgroundColor: Colors.white,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            const Spacer(
              flex: 2,
            ),
            Container(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                    Text(
                      'Exit',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 7,
            )
          ],
        ),
      ),
    );
  }
}

class Veg_use extends StatefulWidget {
  final String roll;
  Veg_use({super.key, required this.roll});

  @override
  State<Veg_use> createState() => _Veg_useState();
}

class _Veg_useState extends State<Veg_use> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff000428), Color(0xff004e92)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(
              flex: 7,
            ),
            const Text(
              'Veg Token',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const Spacer(
              flex: 1,
            ),
            const Text(
              'Scan to use',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            const Spacer(
              flex: 4,
            ),
            QrImageView(
              data: '${widget.roll} Veg 1',
              backgroundColor: Colors.white,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            const Spacer(
              flex: 2,
            ),
            Container(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                    Text(
                      'Exit',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 7,
            )
          ],
        ),
      ),
    );
  }
}

class Egg_use extends StatefulWidget {
  final String roll;
  Egg_use({super.key, required this.roll});

  @override
  State<Egg_use> createState() => _Egg_useState();
}

class _Egg_useState extends State<Egg_use> {
  int count = 1;
  int generate = 0;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff000428), Color(0xff004e92)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(
              flex: 7,
            ),
            const Text(
              'Egg Token',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const Spacer(
              flex: 1,
            ),
            const Text(
              'Scan to use',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            const Spacer(
              flex: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      if (count > 1) {
                        if (generate == 0) count--;
                      }
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Text('$count')),
                IconButton(
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (generate == 0) count += 1;
                      });
                    },
                    icon: const Icon(Icons.add)),
              ],
            ),
            const Spacer(
              flex: 1,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    generate = 1;
                  });
                },
                child: const Text(
                  'Generate',
                  style: TextStyle(color: Colors.green),
                )),
            const Spacer(
              flex: 4,
            ),
            if (generate == 1)
              QrImageView(
                data: '${widget.roll} Eggs $count',
                backgroundColor: Colors.white,
                version: QrVersions.auto,
                size: 320,
                gapless: false,
              ),
            const Spacer(
              flex: 2,
            ),
            if (generate == 1)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    generate = 0;
                  });
                },
                child: const Text(
                  'Undo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(flex: 2),
            Container(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                    Text(
                      'Exit',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 7,
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(PocketDreams());
}

class PocketDreams extends StatefulWidget {
  const PocketDreams({super.key});

  @override
  State<PocketDreams> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PocketDreams> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 225, 175, 210),
          title: const Text("Pocket Dreams"),
          foregroundColor: Colors.white,
        ),

        backgroundColor: Colors.black,

        body: Stack(
          children: [
            Container(
              color: Colors.grey,
              child: SizedBox(
                width: 100,
                height: 100,
                child: const Text("Dreams"),
              ),
            ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 225, 175, 210),

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud),
              label: "Today's Dream",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Calendar",
            ),
          ],
        ),
      ),
    );
  }
}

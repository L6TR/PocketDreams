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
          backgroundColor: Colors.pinkAccent,
          title: const Text("Pocket Dreams"),
          foregroundColor: Colors.white,
        ),

        body: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          color: Colors.black,
          height: 100,
          width: 100,
          child: const Text("What did you dream about today?"),
        ),
      ),
    );
  }
}

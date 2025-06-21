import 'package:flutter/material.dart';

void main() {
  runApp(const PocketDreams());
}

class PocketDreams extends StatelessWidget {
  const PocketDreams({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Pocket Dreams", home: const LoginScreen());
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
        title: const Text("Pocket Dreams"),
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.black,

      body: ElevatedButton(
        child: Text("Login"),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const MainScreen()));
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
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
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),

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
    );
  }
}

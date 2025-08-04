import 'package:flutter/material.dart';
import 'package:pocket_dreams/bloc/backend_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const PocketDreams());
}

class PocketDreams extends StatelessWidget {
  const PocketDreams({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pocket Dreams",
      home: BlocProvider(
        create: (context) => BackendBloc(),
        child: LoginScreen(),
      ),
    );
  }
}

//
// Base widget
//

class Base extends StatefulWidget {
  const Base({super.key});

  @override
  State<Base> createState() => _BaseState();
}

//
// Login widget
//

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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Text(
                "How can we call you?",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              width: 250,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Login",
                ),
              ),
            ),
            SizedBox(
              child: Text(
                "Keep your secrets safe",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              width: 250,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
              ),
            ),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  //not a just "push" !!!
                  MaterialPageRoute(builder: (context) => const Base()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
// _BaseState widget
// child of Base()
//

class _BaseState extends State<Base> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final backendBloc = BlocProvider.of<BackendBloc>(context);
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
          BlocBuilder<BackendBloc, String>(
            builder: (context, state) {
              return Text(state);
            },
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

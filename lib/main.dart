import 'package:flutter/material.dart';
import 'package:pocket_dreams/bloc/backend_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//
// run application
//
void main() {
  runApp(
    BlocProvider(
      create: (context) => BackendBloc(),
      child: const PocketDreams(),
    ) /*const PocketDreams()*/,
  );
}

//
// application
//

class PocketDreams extends StatelessWidget {
  const PocketDreams({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Pocket Dreams", home: const LoginScreen());
  }
}

//
// Login widget
// Base for login
//

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

//
// _LoginScreenState
//

class _LoginScreenState extends State<LoginScreen> {
  bool isRemembered = false;
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // function for coloring the CheckBox
    // becouse it doesn't allow just a fixed color...
    // it want to be depended on the state of the checkbox
    // (-_-)

    Color getColor(Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Color.fromARGB(255, 250, 175, 195);
      }
      return Colors.transparent;
    }

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
                style: TextStyle(color: Colors.white),

                // color of blinking |
                cursorColor: Color.fromARGB(255, 250, 175, 195),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Login",
                  focusedBorder: OutlineInputBorder(
                    // color of the border
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 250, 175, 195),
                    ),
                  ),
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
                style: TextStyle(color: Colors.white),
                obscureText: true,

                // color of blinking |
                cursorColor: Color.fromARGB(255, 250, 175, 195),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                  focusedBorder: OutlineInputBorder(
                    // color of the border
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 250, 175, 195),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  fillColor: WidgetStateProperty.resolveWith(getColor),
                  value: isRemembered,
                  onChanged: (bool? value) {
                    setState(() {
                      isRemembered = value!;
                    });
                  },
                ),
                Text("can we "),
                Text("remember ", style: TextStyle(color: Colors.white)),
                Text("you?"),
              ],
            ),
            OutlinedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: Color.fromARGB(255, 250, 175, 195),
                    width: 5,
                  ),
                ),
              ),
              child: Text("Login", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  // not just a "push" !!!
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
// Base widget
// Base for Base
// :D
//

class Base extends StatefulWidget {
  const Base({super.key});

  @override
  State<Base> createState() => _BaseState();
}

//
// _BaseState widget
// child of Base()
//

class _BaseState extends State<Base> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    context.read<BackendBloc>().fetchData();
    // + data from beginning
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Center(
          child: Text("Chat screen", style: TextStyle(color: Colors.white)),
        );
      case 1:
        return Center(
          child: Text(
            "Today's Dream screen",
            style: TextStyle(color: Colors.white),
          ),
        );
      case 2:
        return Center(
          child: Text("Calendar screen", style: TextStyle(color: Colors.white)),
        );
      case 3:
        return const Settings();
      default:
        return Container();
    }
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
      body: _buildBody(),

      /*Stack(
        children: [
          Container(
            color: Colors.grey,
            child: SizedBox(
              width: 100,
              height: 100,
              child: const Text("Dreams"),
            ),
          ),

// 
// BlocBuilder !!!
//

          BlocBuilder<BackendBloc, String>(
            builder: (context, state) {
              return Text(state);
            },
          ),
        ],
      ),*/
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.chat, color: Colors.white),
            label: "Chat",
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud, color: Colors.white),
            label: "Today's Dream",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month, color: Colors.white),
            label: "Calendar",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings, color: Colors.white),
            label: "Settings",
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
      ),
    );
  }
}

//
// Settings widget
// Base for Settings
//

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

//
// _SettingsState widget
// child of Settings()
//

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: Color.fromARGB(255, 250, 175, 195),
                    width: 5,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text("Log Out", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

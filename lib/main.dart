import 'package:flutter/material.dart';
import 'package:pocket_dreams/bloc/backend_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    return MaterialApp(
      title: "Pocket Dreams",
      home: const /*LoginScreen*/ Base(),
    );
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> login() async {
    final response = await http.post(
      Uri.parse("http://10.0.1.12:5000/api/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    final data = json.decode(response.body);

    setState(() {
      message = data["message"];
    });

    if (data["success"]) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Base()));
    }
  }

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
                controller: emailController,
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
                controller: passwordController,
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
                /*Navigator.of(context).pushReplacement(
                  // not just a "push" !!!
                  MaterialPageRoute(builder: (context) => const Base()),
                );*/
                login();
              },
            ),
            SizedBox(height: 10),
            Text(message, style: TextStyle(color: Colors.red)),
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
        return const TodaysDream();
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
// Base for _SettingsState
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

//
// class for making Emotional Buttons
//

class EmotionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const EmotionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

//
// class for making Emotion
// that we need for buttons
//

class Emotion {
  final String name;
  final Color color;

  Emotion({required this.name, required this.color});
}

//
// list for all emotion what we have
//

final List<Emotion> emotions = [
  Emotion(name: "Happiness", color: Color.fromARGB(255, 255, 255, 0)),
  Emotion(name: "Love", color: Color.fromARGB(255, 255, 0, 0)),
  Emotion(name: "Calm", color: Color.fromARGB(255, 0, 0, 255)),
  Emotion(name: "Harmony", color: Color.fromARGB(255, 0, 255, 0)),
  Emotion(name: "Warmth", color: Color.fromARGB(255, 255, 165, 0)),
];

//
// TodaysDream widget
// Base for _TodaysDreamState
//

class TodaysDream extends StatefulWidget {
  const TodaysDream({super.key});

  @override
  State<TodaysDream> createState() => _TodaysDreamState();
}

//
// _TodaysDreamState
// child of TodaysDream()
//

class _TodaysDreamState extends State<TodaysDream> {
  List<Color> sphereColors = List.generate(6, (_) => Colors.white10);

  void newEmotionChoise(Emotion emotion) {
    int index = nextIndex(sphereColors);
    if (index != -1) {
      setState(() {
        sphereColors[index] = emotion.color;
      });
    }
  }

  int nextIndex(List listOfColors) {
    for (int i = 0; i < listOfColors.length; i++) {
      if (listOfColors[i] == Colors.white10) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: SizedBox(
                            width: 200,
                            child: Autocomplete<Emotion>(
                              optionsBuilder: (TextEditingValue userInput) {
                                if (userInput.text == "") {
                                  return const Iterable<Emotion>.empty();
                                }
                                return emotions.where((emotions) {
                                  return emotions.name.toLowerCase().contains(
                                    userInput.text.toLowerCase(),
                                  );
                                });
                              },
                              onSelected: (Emotion emotion) {
                                newEmotionChoise(emotion);
                              },
                              displayStringForOption: (Emotion emotion) =>
                                  emotion.name,

                              fieldViewBuilder:
                                  (
                                    context,
                                    textEditingController,
                                    focusNode,
                                    onFieldSubmitted,
                                  ) {
                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      style: TextStyle(color: Colors.white),

                                      // color of blinking |
                                      cursorColor: Color.fromARGB(
                                        255,
                                        250,
                                        175,
                                        195,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Find key words",
                                        focusedBorder: OutlineInputBorder(
                                          // color of the border
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              250,
                                              175,
                                              195,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (value) {},
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: SizedBox(
                          width: 200,
                          child: Text("zde budou Key words"),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      /*crossAxisAlignment: CrossAxisAlignment.center,*/
                      children: [
                        for (int i = 0; i < 6; i++)
                          Icon(Icons.circle, color: sphereColors[i]),
                        Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          color: Colors.white10,
                        ),
                        Icon(Icons.square_rounded, color: Colors.white10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                child: Text("zde bude button", style: TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

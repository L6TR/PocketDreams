import 'package:flutter/material.dart';
import 'package:pocket_dreams/bloc/backend_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';
//https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait

//
// global guys
//
Map<DateTime, List<Dream>> dreams = {};

String user = "merunka";
String server = "http://10.40.2.4:5000";

const List<String> tagList = [
  "Nightmare",
  "Future",
  "Family",
  "Fantasy",
  "Unreal",
  "Love",
  "Traveling",
  "Nostalgia",
  "Nature",
];

//
// global function guys
//
void addDreamToCalendar(Dream dream) {
  final day = DateTime(dream.date.year, dream.date.month, dream.date.day);

  //print(dreams[day]);
  if (dreams[day] != null) {
    dreams[day]!.add(dream);
  } else {
    dreams[day] = [dream];
  }
}

Color cloudPink() {
  return Color.fromARGB(255, 250, 175, 195);
}

OutlinedButton cloudyButton(String myText, doSomething) {
  return OutlinedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.white),
      side: WidgetStatePropertyAll(
        BorderSide(color: Color.fromARGB(255, 250, 175, 195), width: 5),
      ),
    ),
    child: Text(myText, style: TextStyle(color: Colors.black)),
    onPressed: () {
      doSomething();
    },
  );
}

//
// run application
//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    BlocProvider(
      create: (context) => BackendBloc(),
      child: const PocketDreams(),
    ),
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
      home: const /*LoginScreen(),*/ Base(),
      /*TagScreen(),*/
    );
  }
}

//
// Register widget
// Base for register
//

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

//
// _RegisterScreenState widget
// child of Login()
//

class _RegisterScreenState extends State<RegisterScreen> {
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> register() async {
    final response = await http.post(
      Uri.parse("$server/api/register"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Username": nicknameController.text,
        "Password": passwordController.text,
      }),
    );

    final data = json.decode(response.body);

    setState(() {
      message = data["message"];
    });

    if (data["success"]) {
      setState(() {
        user = nicknameController.text;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TagScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // no boottom overflowed by xx pixels
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
        title: const Text("Pocket Dreams"),
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.black,

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      flex: 9,
                      child: Center(
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
                                controller: nicknameController,
                                style: TextStyle(color: Colors.white),

                                // color of blinking |
                                cursorColor: Color.fromARGB(255, 250, 175, 195),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Name",
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

                            cloudyButton("Register", register),
                            SizedBox(height: 10),
                            Text(message, style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("or do we "),
                                Text(
                                  "already know ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text("you?"),
                              ],
                            ),
                            OutlinedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.white,
                                ),
                                side: WidgetStatePropertyAll(
                                  BorderSide(
                                    color: Color.fromARGB(255, 250, 175, 195),
                                    width: 5,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//
// Tag widget
// Base for Tags
//

class TagScreen extends StatefulWidget {
  const TagScreen({super.key});

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  String message = "";
  Future<void> chooseTags() async {
    final response = await http.post(
      Uri.parse("$server/api/chooseTags"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"Username": user, "Tags": chosenTags}),
    );

    final data = json.decode(response.body);

    setState(() {
      message = data["message"];
    });

    if (data["success"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Base()),
      );
    }
  }

  // list of Tags for database

  List<String> chosenTags = [];

  Map<String, bool> tagVisibility = {for (var tag in tagList) tag: false};

  void changeStatus(tag) {
    setState(() {
      tagVisibility[tag] = !(tagVisibility[tag] ?? false);
    });
  }

  void confimTags() {
    for (int i = 0; i < tagList.length; i++) {
      if (tagVisibility[tagList[i]] == true) {
        chosenTags.add(tagList[i]);
      }
    }

    setState(() {
      message = (chosenTags.length < 3) ? "choose at least 3" : "";
    });
    if (chosenTags.length >= 3) {
      chooseTags();
    }
    chosenTags = [];
  }

  bool visibility = false;
  // container with Tag and Done Square
  Container tagChoosing(tag) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(9),

      width: 109,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cloudPink()),
      ),

      child: InkWell(
        onTap: () {
          changeStatus(tag);
        },

        child: Row(
          children: [
            // pink square
            Container(
              margin: EdgeInsets.all(2),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: cloudPink()),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Visibility(
                visible: tagVisibility[tag] ?? false,
                child: Icon(Icons.done),
              ),
            ),
            Text(tag, style: TextStyle(color: cloudPink())),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
        title: const Text("Pocket Dreams"),
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Choose, what do you want to see more",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      tagChoosing(tagList[0]),
                      tagChoosing(tagList[1]),
                      tagChoosing(tagList[2]),
                    ],
                  ),
                  Row(
                    children: [
                      tagChoosing(tagList[3]),
                      tagChoosing(tagList[4]),
                      tagChoosing(tagList[5]),
                    ],
                  ),
                  Row(
                    children: [
                      tagChoosing(tagList[6]),
                      tagChoosing(tagList[7]),
                      tagChoosing(tagList[8]),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Center(child: cloudyButton("Confim", confimTags)),
                SizedBox(height: 10),
                Text(message, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
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
// _LoginScreenState widget
// child of Login()
//

class _LoginScreenState extends State<LoginScreen> {
  bool isRemembered = false;
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";

  Future<void> login() async {
    final response = await http.post(
      Uri.parse("$server/api/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Username": nicknameController.text,
        "Password": passwordController.text,
      }),
    );

    final data = json.decode(response.body);

    setState(() {
      message = data["message"];
    });

    if (data["success"]) {
      setState(() {
        user = nicknameController.text;
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) => Base()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // function for coloring the CheckBox
    // because it doesn't allow just a fixed color...
    // it want to be depended on the state of the checkbox
    // (-_-)

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
        title: const Text("Pocket Dreams"),
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.black,

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      flex: 9,
                      child: Center(
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
                                controller: nicknameController,
                                style: TextStyle(color: Colors.white),

                                // color of blinking |
                                cursorColor: Color.fromARGB(255, 250, 175, 195),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Name",
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

                            // remember me
                            cloudyButton("Login", login),
                            SizedBox(height: 10),
                            Text(message, style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("or you are "),
                                Text(
                                  "first time ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text("here?"),
                              ],
                            ),
                            OutlinedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.white,
                                ),
                                side: WidgetStatePropertyAll(
                                  BorderSide(
                                    color: Color.fromARGB(255, 250, 175, 195),
                                    width: 5,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        return const Calendar();
      case 3:
        return const Settings();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 175, 195),
        title: const Text("Pocket Dreams"),
        actions: [
          Text(user),
          SizedBox(width: 40, height: 40, child: Icon(Icons.account_circle)),
        ],
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.black,
      body: _buildBody(),
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
                  MaterialPageRoute(builder: (context) => const TagScreen()),
                );
              },
              child: Text(
                "Change my interests",
                style: TextStyle(color: Colors.black),
              ),
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
  final int index;
  final VoidCallback onPressed;

  const EmotionButton({
    super.key,
    required this.index,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        side: BorderSide(color: Colors.white, width: 5),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: Colors.black)),
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
  Emotion(name: "Freedom", color: Color.fromARGB(255, 0, 255, 255)),
  Emotion(name: "Creativity", color: Color.fromARGB(255, 255, 0, 255)),

  Emotion(name: "Purity", color: Color.fromARGB(255, 255, 255, 255)),
  Emotion(name: "Depth", color: Color.fromARGB(255, 0, 0, 0)),

  Emotion(name: "Warmth", color: Color.fromARGB(255, 255, 165, 0)),
];

//
//class for Dreams
//

class Dream {
  final DateTime date;
  final String name;
  final Color emotionColor;
  final String describe;
  final int isPrivate;
  final List<String> tags;

  Dream({
    required this.tags,
    required this.name,
    required this.date,
    required this.isPrivate,
    required this.emotionColor,
    required this.describe,
  });
}

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
  // color of our errors in the middle of the screen
  Color errorColor = Colors.red;

  // creating variables for our future work with json
  String message = "";
  String _name = "";
  String _description = "";
  bool isPrivate = true;
  final List<String> _tags = [];
  //final List<double> _mixedColor = [255, 96, 106, 116];
  final List<String> _emotions = [];
  bool colorWasChosen = false;
  int _isPrivate = 1;

  // we need that for remembering what we wrote
  String? lastNameUpdate;
  String? lastDescriptionUpdate;

  // if we has not chosen dream name it would be date when we had this dream
  // Chosen name was "" --- Dream name would be "2025.12.1 dream"
  String rightDreamNameFormat(chosenName) {
    String month = (_chosenDate.month < 10)
        ? "0${_chosenDate.month}"
        : "${_chosenDate.month}";
    String day = (_chosenDate.day < 10)
        ? "0${_chosenDate.day}"
        : "${_chosenDate.day}";
    String futureName = (chosenName == "")
        ? "${_chosenDate.year}.$month.$day dream"
        : chosenName;
    return futureName;
  }

  Future<void> addDream() async {
    _name = rightDreamNameFormat(lastNameUpdate);
    _description = lastDescriptionUpdate ?? "";
    _isPrivate = (isPrivate) ? 1 : 0;

    // working in cycle with sphere colors
    for (int i = 0; i < chosenSphereColors.length; i++) {
      // working in cycke with all emotions (final list)
      for (int a = 0; a < emotions.length; a++) {
        // compare our sphere colors with emotion color
        if (emotions[a].color == chosenSphereColors[i]) {
          // if emotion color is ok, adding it to the _emotions list (need for json)
          _emotions.add(emotions[a].name);
        }
      }
    }

    // make from date format in integer like yearmonthday
    // like if we have 2025.12.04 we create 20251204
    int rightDateFormat(date) {
      // if we have for example 4 month we need 04, that means if we have month < 10 we are adding 0
      String month = date.month < 10
          ? "0${date.month.toString()}"
          : date.month.toString();
      // same logic as in month
      String day = date.day < 10
          ? "0${date.day.toString()}"
          : date.day.toString();
      date = date.year.toString() + month + day;
      return int.parse(date);
    }

    /*final dream = newDream(
      mixedColor(chosenSphereColors),
      _name,
      _chosenDate,
      _description,
      _isPrivate,
      _tags,
    );*/

    //addDreamToCalendar(dream);
    final response = await http.post(
      Uri.parse("$server/api/addDream"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Name": _name,
        "Description": _description,
        "Date": rightDateFormat(_chosenDate),
        "IsPrivate": _isPrivate,
        "Tags": _tags,
        "User": user,
        "PublicationDate": rightDateFormat(DateTime.now()),
        "Emotions": _emotions,
      }),
    );

    //clearing list with emotion what we had sended to the backend
    _emotions.clear();
    final data = json.decode(response.body);

    setState(() {
      message = data["message"];
      error = message;
      errorColor = (error != "Your dream was added")
          ? Colors.red
          : Colors.green;
    });

    if (data["success"]) {
      //print(message);
    }
  }

  // List for all spheres + grey
  List<Color> sphereColors = List.generate(6, (_) => Colors.white10);

  // List for only chosen (i need that)
  List<Color> chosenSphereColors = [];

  List<EmotionButton> chosenEmotionButtons = [];

  List<String> chosenEmotions = [];

  //function for mixing colors
  Color mixedColor(List<Color> colorList) {
    if (colorList.isEmpty) return Colors.white10;

    double mixedR = 0;
    double mixedG = 0;
    double mixedB = 0;

    for (int i = 0; i < colorList.length; i++) {
      mixedR += (colorList[i].r * 255.0);

      mixedG += (colorList[i].g * 255.0);

      mixedB += (colorList[i].b * 255.0);
    }

    int len = colorList.length;
    colorWasChosen = chosenSphereColors.isNotEmpty;
    return Color.fromARGB(
      255,
      (mixedR / len).round(),
      (mixedG / len).round(),
      (mixedB / len).round(),
    );
  }

  //function for adding a Dream to The Calendar
  Dream newDream(
    dreamsColor,
    dreamName,
    dreamsDate,
    dreamsDescribe,
    dreamIsPrivate,
    dreamTags,
  ) {
    return Dream(
      tags: dreamTags,
      isPrivate: dreamIsPrivate,
      date: dreamsDate,
      name: dreamName,
      emotionColor: dreamsColor,
      describe: dreamsDescribe,
    );
  }

  // function for deleting Emotion
  void removeEmotion(int index) {
    setState(() {
      final removedColor = sphereColors[index];
      sphereColors[index] = Colors.white10;

      chosenSphereColors.remove(removedColor);
      chosenEmotionButtons.removeWhere((btn) => btn.index == index);
    });
  }

  //
  //adding a new emotion to the our list
  //
  void newEmotionChoise(Emotion emotion) {
    int index = nextIndex(sphereColors);
    if (index != -1) {
      setState(() {
        //remembering our index
        sphereColors[index] = emotion.color;

        //add a new color to our right side
        chosenSphereColors.add(emotion.color);

        //adding a button in the middle
        chosenEmotionButtons.add(
          EmotionButton(
            index: index,
            label: emotion.name,
            color: emotion.color,
            onPressed: () {
              removeEmotion(index);
            },
          ),
        );
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

  String error = "";

  final TextEditingController _dateController = TextEditingController();
  DateTime _chosenDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var chosenDate = DateTime.now();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // center part
                      Expanded(
                        flex: 9,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Dream emotion text box
                            SizedBox(
                              height: 100,
                              child: Center(
                                child: SizedBox(
                                  width: 200,
                                  child: Autocomplete<Emotion>(
                                    optionsBuilder:
                                        (TextEditingValue userInput) {
                                          if (userInput.text == "") {
                                            return const Iterable<
                                              Emotion
                                            >.empty();
                                          }
                                          return emotions.where((emotions) {
                                            return emotions.name
                                                .toLowerCase()
                                                .contains(
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
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),

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
                            // part with emotion buttons
                            Container(
                              constraints: BoxConstraints(minHeight: 200),
                              child: SizedBox(
                                width: 200,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Wrap(
                                          spacing: 8,
                                          children: chosenEmotionButtons,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // right part
                      // mixing emotions
                      Expanded(
                        flex: 1,
                        child: Center(
                          child:
                              // Sphere column
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < 6; i++)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: Container(
                                        width: 5,
                                        height: 5,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: sphereColors[i],
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),

                                  Icon(
                                    Icons.keyboard_double_arrow_down_rounded,
                                    color: chosenEmotionButtons.isNotEmpty
                                        ? Colors.white
                                        : Colors.white10,
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.square_rounded,
                                      color: mixedColor(chosenSphereColors),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // error text
          SizedBox(
            height: 40,
            child: SizedBox(
              width: 240,
              child: Text(
                error, // that would be our text
                style: TextStyle(color: errorColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // description textbox
          SizedBox(
            height: 160,
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // description Text box
                      SizedBox(
                        width: 120,
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                          controller: TextEditingController(text: _description),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Description",
                            focusedBorder: OutlineInputBorder(
                              // color of the border
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 250, 175, 195),
                              ),
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            _writeADescription();
                          },
                        ),
                      ),

                      SizedBox(height: 15),

                      // Date text box
                      SizedBox(
                        height: 60,
                        width: 120,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _dateController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: chosenDate.toString().split(" ")[0],
                            focusedBorder: OutlineInputBorder(
                              // color of the border
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 250, 175, 195),
                              ),
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            _selectDate();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),

                // swith part
                SizedBox(
                  width: 180,
                  child: Column(
                    children: [
                      // Swith text
                      SizedBox(
                        height: 28,
                        child: Center(
                          child: Text(
                            "Is your dream private?",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Private switch
                      Switch(
                        activeThumbColor: cloudPink(),
                        value: isPrivate,
                        onChanged: (value) {
                          setState(() {
                            isPrivate = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      // Choose tags box
                      SizedBox(
                        height: 60,
                        width: 140,
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Choose tags",
                            focusedBorder: OutlineInputBorder(
                              // color of the border
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 250, 175, 195),
                              ),
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            _chooseTags();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // add dream button
          SizedBox(
            height: 80,
            child: Center(
              child: SizedBox(
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: cloudPink(), width: 5),
                    ),
                  ),
                  child: Text(
                    "Add a dream to the Calendar",
                    style: TextStyle(color: Colors.black),
                  ),

                  //
                  // error logic and adding the dream
                  //
                  onPressed: () {
                    if (_tags.isEmpty &&
                        _description.isEmpty &&
                        !colorWasChosen) {
                      setState(() {
                        errorColor = Colors.red;
                        error = "You must to choose at least something";
                      });
                    } else if (!isPrivate &&
                        _tags.isEmpty &&
                        _description.isEmpty) {
                      setState(() {
                        errorColor = Colors.red;
                        error =
                            "You must to choose tags and write the description for the public dream";
                      });
                    } else if (!isPrivate && _tags.isEmpty) {
                      setState(() {
                        errorColor = Colors.red;
                        error = "You must to choose tags for the public dream";
                      });
                    } else if (!isPrivate && _description.isEmpty) {
                      setState(() {
                        errorColor = Colors.red;
                        error =
                            "You must to write the description for the public dream";
                      });
                    } else {
                      setState(() {
                        addDream();
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
  // Future
  // (something after the widget was built)
  //

  // select date for dream
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: cloudPink(),
            colorScheme: ColorScheme.light(
              primary: cloudPink(),
              onPrimary: Colors.white,
              surface: Color.fromARGB(255, 5, 5, 5),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _chosenDate = pickedDate;
        _dateController.text = pickedDate.toString().split(" ")[0];
      });
    } else {
      _dateController.text = DateTime.now().toString().split(" ")[0];
    }
  }

  // description for dreams
  Future<void> _writeADescription() async {
    final TextEditingController descriptionController = TextEditingController(
      text: lastDescriptionUpdate ?? '',
    );
    final TextEditingController nameController = TextEditingController(
      text: lastNameUpdate ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 5, 5, 5),

          content: SizedBox(
            height: 300,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 150,
                    child: TextField(
                      controller: nameController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color.fromARGB(255, 250, 175, 195),
                      decoration: InputDecoration(
                        hintText: "Add a name",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 250, 175, 195),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    child: TextField(
                      controller: descriptionController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Color.fromARGB(255, 250, 175, 195),

                      decoration: InputDecoration(
                        hintText: "Describe your dream...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 250, 175, 195),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cloudPink(),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  lastNameUpdate = nameController.text;
                  lastDescriptionUpdate = descriptionController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // mapping String to bool for all tags in tagList
  Map<String, bool> chosenDreamTags = {for (var tag in tagList) tag: false};

  // button for choosing tags for dream
  StatefulBuilder tagButton(tag) {
    bool chosen = chosenDreamTags[tag] ?? false;

    Color insideC = !chosen ? Colors.white : cloudPink();
    Color borderC = !chosen ? Colors.grey : Color.fromARGB(255, 125, 87, 98);

    return StatefulBuilder(
      builder: (context, setState) {
        return OutlinedButton(
          style: ButtonStyle(
            side: WidgetStatePropertyAll(BorderSide(color: borderC, width: 5)),
            backgroundColor: WidgetStatePropertyAll(insideC),
          ),

          onPressed: () {
            chosen = !chosen;
            chosenDreamTags[tag] = chosen;
            setState(() {
              insideC = (insideC == Color.fromARGB(255, 250, 175, 195))
                  ? Colors.white
                  : Color.fromARGB(255, 250, 175, 195);
              borderC = (borderC == Colors.grey)
                  ? Color.fromARGB(255, 125, 87, 98)
                  : Colors.grey;
            });
          },
          child: Text(tag, style: TextStyle(color: Colors.black)),
        );
      },
    );
  }

  // choose tag dialog for dreams
  Future<void> _chooseTags() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 5, 5, 5),
          content: SizedBox(
            height: 250,
            child: Column(
              children: [
                Row(
                  children: [
                    tagButton(tagList[0]),
                    SizedBox(width: 15),
                    tagButton(tagList[1]),
                  ],
                ),
                Row(
                  children: [
                    tagButton(tagList[2]),
                    SizedBox(width: 15),
                    tagButton(tagList[3]),
                  ],
                ),
                Row(
                  children: [
                    tagButton(tagList[4]),
                    SizedBox(width: 15),
                    tagButton(tagList[5]),
                  ],
                ),
                Row(
                  children: [
                    tagButton(tagList[6]),
                    SizedBox(width: 15),
                    tagButton(tagList[7]),
                  ],
                ),
                tagButton(tagList[8]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cloudPink(),
                foregroundColor: Colors.black,
              ),
              // clears tags and adding a tag to the tagList[]
              onPressed: () {
                if (_tags.isNotEmpty) _tags.clear();
                for (int i = 0; i < chosenDreamTags.length; i++) {
                  if (chosenDreamTags[tagList[i]] == true) {
                    _tags.add(tagList[i]);
                  }
                }

                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

//
// Calendar widget
// Base for _CalendarState
//

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

//
// _CalendarState
// child of Calendar()
//

class _CalendarState extends State<Calendar> {
  List _dreamsList = [];

  List<String> dreamStructure = [
    "Name",
    "Description",
    "Date",
    "IsPrivate",
    "PublicationDate",
  ];

  Future<void> askAboutDreams() async {
    final response = await http.get(
      Uri.parse("$server/api/askAboutDreams?username=$user"),
      headers: {"Content-Type": "application/json"},
    );
    String message = "";

    final data = json.decode(response.body);
    List dreamsList = data["dreamsList"];

    /*for (int i = 0; i < dreamsList.length; i++) {
      print("Dream $i");
      for (int s = 0; s < dreamStructure.length; s++) {
        print("${dreamStructure[s]}: ${dreamsList[i][dreamStructure[s]]}");
      }
      print("");
    }*/

    // dreamsC = dreams counter
    //for (int dreamsC = 0; dreamsC < dreams.length; dreamsC++) {}

    setState(() {
      _dreamsList = dreamsList;
    });

    print(_dreamsList[0]["Date"]);
  }

  // final => const value
  // late => variable would have a value latter, but not on the start
  // ValueNotifier x; => doing something, when the value of x is changing
  late final ValueNotifier<List<Dream>> _selectedDays;

  DateTime _focusedDay = DateTime.now();

  // x? means that x would be Null in the begining and we are ok with that
  DateTime? _selectedDay;

  @override
  // initState() {x}; we are doing x, one time, when we are initing a State
  // functions and other things what we need before the build
  void initState() {
    askAboutDreams();

    //means, we dont @override it
    super.initState();

    _selectedDay = _focusedDay;

    // x! means i am sure that x wouldnt be Null
    //_selectedDays = ValueNotifier(_getDreamsForDay(_selectedDay!));
  }

  // we need this one to deleting data when we are not looking at the widget
  @override
  void dispose() {
    _selectedDays.dispose();
    super.dispose();
  }

  DateTime rightDateFormat(int intDay) {
    return DateTime(intDay);
  }

  //rightDateFormat();

  final Map<DateTime, List<String>> dreams = {
    DateTime(2025, 1, 10): ['Сон 1', 'Сон 2'],
    DateTime(2025, 1, 11): ['Кошмар'],
  };

  // return the list of Object for the specific day
  List<String> _getDreamsForDay(DateTime day) {
    return dreams[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          outsideTextStyle: TextStyle(
            color: const Color.fromARGB(255, 33, 33, 33),
          ),
          defaultTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: cloudPink()),
        ),
        // text on the top part
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        rowHeight: 80,
        focusedDay: DateTime.now(),
        firstDay: DateTime(2000, 1, 1),
        lastDay: DateTime.now(),

        // we need this just because "==" is not working with DateTime normaly TTnTT
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },

        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return null;
          },
        ),

        // changing a day to the day what you are selecting
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: (day) {
          return _getDreamsForDay(day);
        },
      ),
    );
  }
}

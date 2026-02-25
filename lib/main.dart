import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pocket_dreams/bloc/backend_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//https://stackoverflow.com/questions/49418332/flutter-how-to-prevent-device-orientation-changes-and-force-portrait

//
// global guys
//
Map<DateTime, List<Dream>> dreams = {};

//
// list for all emotion what we have
//

final List<Hemotion> hSLemotions = [
  Hemotion(name: "Happiness", color: HSLColor.fromAHSL(1.0, 60.0, 0.7, 0.5)),
  Hemotion(name: "Love", color: HSLColor.fromAHSL(1.0, 0.0, 0.7, 0.5)),
  Hemotion(name: "Calm", color: HSLColor.fromAHSL(1.0, 240.0, 0.7, 0.5)),
  Hemotion(name: "Harmony", color: HSLColor.fromAHSL(1.0, 120.0, 0.7, 0.5)),
  Hemotion(name: "Freedom", color: HSLColor.fromAHSL(1.0, 180.0, 0.7, 0.5)),
  Hemotion(name: "Creativity", color: HSLColor.fromAHSL(1.0, 300.0, 0.7, 0.5)),

  Hemotion(name: "Purity", color: HSLColor.fromAHSL(1.0, 190.0, 0.7, 0.5)),
  Hemotion(name: "Depth", color: HSLColor.fromAHSL(1.0, 230.0, 0.7, 0.5)),

  Hemotion(name: "Warmth", color: HSLColor.fromAHSL(1.0, 39.0, 0.7, 0.5)),
  Hemotion(name: "Fear", color: HSLColor.fromAHSL(1.0, 275.0, 0.7, 0.5)),

  Hemotion(name: "Sadness", color: HSLColor.fromAHSL(1.0, 220.0, 0.7, 0.5)),
  Hemotion(name: "Anger", color: HSLColor.fromAHSL(1.0, 0.0, 0.85, 0.5)),

  Hemotion(name: "Shame", color: HSLColor.fromAHSL(1.0, 260.0, 0.4, 0.35)),
];

HSLColor mixEmotions(List<HSLColor> emotions) {
  final hue = mixHues(emotions.map((e) => e.hue).toList());
  final saturation = mixLinear(emotions.map((e) => e.saturation).toList());
  final lightness = mixLinear(emotions.map((e) => e.lightness).toList());

  return HSLColor.fromAHSL(1.0, hue, saturation, lightness);
}

double mixLinear(List<double> values) {
  return values.reduce((a, b) => a + b) / values.length;
}

// sayHiToTheBackend
/*Future<void> checkTheBackendStatus() async {
  final response = await http.get(
    Uri.parse("$server/api/chooseTags"),
    headers: {"Content-Type": "application/json"},
  );

  final data = json.decode(response.body);

  print(data);

  if (data["success"]) {}
}*/

// by this function we are getting from a Int date like 20251209 => DateTime 2025-12-09
DateTime intToDate(int date) {
  int year = date ~/ 10000;
  int month = ((date % 10000) ~/ 100);
  int day = (date % 100);
  return DateTime.utc(year, month, day);
}

// getting from DateTime 2026-01-15 00:00:00.000Z only DateTime 2026-01-15 00:00:00.000
DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

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
    likes: 0,
    tags: dreamTags,
    isPrivate: dreamIsPrivate,
    date: dreamsDate,
    name: dreamName,
    emotionColor: dreamsColor,
    describe: dreamsDescribe,
  );
}

// function for mixing hues from the double list
double mixHues(List<double> hues) {
  double x = 0;
  double y = 0;

  for (final h in hues) {
    final rad = h * pi / 180;
    x += cos(rad);
    y += sin(rad);
  }
  final avgRad = atan2(y, x);
  double result = avgRad * 180 / pi;

  if (result < 0) result += 360;
  return result;
}

// !!! dont forget to change
String user = "merunka";
String server = "http://192.168.0.233:5000";

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

OutlinedButton cloudyButton(
  String myText,
  VoidCallback doSomething,
  Color borderColor,
  Color buttonColor,
) {
  return OutlinedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(buttonColor),
      side: WidgetStatePropertyAll(BorderSide(color: borderColor, width: 5)),
    ),
    child: Text(myText, style: TextStyle(color: Colors.black)),
    onPressed: () {
      doSomething();
    },
  );
}

Map<String, bool> tagVisibility = {for (var tag in tagList) tag: false};

// button for choosing tags for dream
StatefulBuilder statusCloudyButton(
  String myText,
  VoidCallback doSomething,
  bool active,
) {
  Color insideC = !active ? Colors.white : cloudPink();
  Color borderC = !active ? Colors.grey : Color.fromARGB(255, 125, 87, 98);

  return StatefulBuilder(
    builder: (context, setState) {
      return OutlinedButton(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: borderC, width: 5)),
          backgroundColor: WidgetStatePropertyAll(insideC),
        ),

        onPressed: () {
          doSomething();
          active = !active;
          setState(() {
            insideC = (insideC == Color.fromARGB(255, 250, 175, 195))
                ? Colors.white
                : cloudPink();
            borderC = (borderC == Colors.grey)
                ? Color.fromARGB(255, 125, 87, 98)
                : Colors.grey;
          });
        },
        child: Text(myText, style: TextStyle(color: Colors.black)),
      );
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
                                cursorColor: cloudPink(),
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

                            cloudyButton(
                              "Register",
                              register,
                              cloudPink(),
                              Colors.white,
                            ),
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
  Container tagChoosing(String tag) {
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
            child: Wrap(
              spacing: 8,
              children: [for (String tag in tagList) tagChoosing(tag)],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Center(
                  child: cloudyButton(
                    "Confim",
                    confimTags,
                    cloudPink(),
                    Colors.white,
                  ),
                ),
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
        backgroundColor: cloudPink(),
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
                                    borderSide: BorderSide(color: cloudPink()),
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
                                cursorColor: cloudPink(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Password",
                                  focusedBorder: OutlineInputBorder(
                                    // color of the border
                                    borderSide: BorderSide(color: cloudPink()),
                                  ),
                                ),
                              ),
                            ),

                            // remember me
                            cloudyButton(
                              "Login",
                              login,
                              cloudPink(),
                              Colors.white,
                            ),
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
                                  BorderSide(color: cloudPink(), width: 5),
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
        return const DreamViev();
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
            icon: Icon(Icons.dashboard, color: Colors.white),
            label: "Tiles",
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
        backgroundColor: cloudPink(),
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

// get Map of user friends from the backend
Future<List<String>> getFriendsList(String user) async {
  final response = await http.get(
    Uri.parse("$server/api/getFriendsList?user=$user"),
    headers: {"Content-Type": "application/json"},
  );
  final data = json.decode(response.body);
  return List<String>.from(data["friendsMap"]);
}

//
// _SettingsState widget
// child of Settings()
//

class _SettingsState extends State<Settings> {
  // showing a dialog with all friends of this user
  Future<void> showMyFriends(List<String> friendsList) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 15, 15, 15),

              content: SizedBox(
                height: 350,
                width: 150,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      child: Text(
                        "Here you can see your friends",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (var friend in friendsList)
                            // container for every friend
                            Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 30, 30, 30),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: cloudPink(),
                                  width: 3,
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 75,
                                      child: Text(
                                        friend,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            "See profile",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    InkWell(
                                      onTap: () async {
                                        changeFriendshipStatus(friend);
                                        List<String> tempFriends =
                                            await getFriendsList(user);
                                        setDialogState(() {
                                          friendsList = tempFriends;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.person_off,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            "Delete friend",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 250),
            cloudyButton(
              "Change my interests",
              () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const TagScreen()),
                );
              },
              cloudPink(),
              Colors.white,
            ),
            cloudyButton(
              "My friends",
              () async {
                List<String> userFriends = await getFriendsList(user);
                showMyFriends(userFriends);
              },
              cloudPink(),
              Colors.white,
            ),
            Spacer(),
            cloudyButton(
              "Log Out",
              () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              cloudPink(),
              Colors.white,
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

class Hemotion {
  final String name;
  final HSLColor color;

  Hemotion({required this.name, required this.color});
}

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
  final int likes;

  Dream({
    required this.likes,
    required this.tags,
    required this.name,
    required this.date,
    required this.isPrivate,
    required this.emotionColor,
    required this.describe,
  });
}

// make from date format in integer like yearmonthday
// like if we have 2025.12.04 we create 20251204
int dateToInt(date) {
  // if we have for example 4 month we need 04, that means if we have month < 10 we are adding 0
  String month = date.month < 10
      ? "0${date.month.toString()}"
      : date.month.toString();
  // same logic as in month
  String day = date.day < 10 ? "0${date.day.toString()}" : date.day.toString();
  date = date.year.toString() + month + day;
  return int.parse(date);
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
  String rightDreamNameFormat(String? chosenName) {
    String month = (_chosenDate.month < 10)
        ? "0${_chosenDate.month}"
        : "${_chosenDate.month}";
    String day = (_chosenDate.day < 10)
        ? "0${_chosenDate.day}"
        : "${_chosenDate.day}";
    if (chosenName == null || chosenName.trim().isEmpty) {
      return "${_chosenDate.year}.$month.$day dream";
    }
    return chosenName.trim();
  }

  Future<void> addDream() async {
    _name = rightDreamNameFormat(lastNameUpdate);
    _description = lastDescriptionUpdate ?? "";
    _isPrivate = (isPrivate) ? 1 : 0;

    // working in cycle with sphere colors
    for (int i = 0; i < chosenSphereColors.length; i++) {
      // working in cycke with all emotions (final list)
      for (int a = 0; a < hSLemotions.length; a++) {
        // compare our sphere colors with emotion color
        if (hSLemotions[a].color == chosenSphereColors[i]) {
          // if emotion color is ok, adding it to the _emotions list (need for json)
          _emotions.add(hSLemotions[a].name);
        }
      }
    }

    final response = await http.post(
      Uri.parse("$server/api/addDream"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "Name": _name,
        "Description": _description,
        "Date": dateToInt(_chosenDate),
        "IsPrivate": _isPrivate,
        "Tags": _tags,
        "User": user,
        "PublicationDate": dateToInt(DateTime.now()),
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
  List<HSLColor?> sphereColors = List.generate(6, (_) => null);

  // List for only chosen (i need that)
  List<HSLColor> chosenSphereColors = [];

  List<EmotionButton> chosenEmotionButtons = [];

  List<String> chosenEmotions = [];

  Color mixedHSLColor(List<HSLColor> emotions) {
    if (emotions.isEmpty) return Colors.white10;

    final mixed = mixEmotions(emotions);
    colorWasChosen = emotions.isNotEmpty;
    return mixed.toColor();
  }

  // function for deleting Emotion
  void removeEmotion(int index) {
    setState(() {
      final removedColor = sphereColors[index];
      sphereColors[index] = null;

      chosenSphereColors.remove(removedColor);
      chosenEmotionButtons.removeWhere((btn) => btn.index == index);
    });
  }

  //
  //adding a new emotion to the our list
  //
  void newEmotionChoise(Hemotion emotion) {
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
            color: emotion.color.toColor(),
            onPressed: () {
              removeEmotion(index);
            },
          ),
        );
      });
    }
  }

  int nextIndex(List<HSLColor?> listOfColors) {
    for (int i = 0; i < listOfColors.length; i++) {
      if (listOfColors[i] == null) {
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
                                  child: Autocomplete<Hemotion>(
                                    optionsBuilder:
                                        (TextEditingValue userInput) {
                                          if (userInput.text == "") {
                                            return const Iterable<
                                              Hemotion
                                            >.empty();
                                          }
                                          return hSLemotions.where((emotions) {
                                            return emotions.name
                                                .toLowerCase()
                                                .contains(
                                                  userInput.text.toLowerCase(),
                                                );
                                          });
                                        },
                                    onSelected: (Hemotion emotion) {
                                      final hemotion = hSLemotions.firstWhere(
                                        (h) => h.name == emotion.name,
                                      );
                                      newEmotionChoise(hemotion);
                                    },
                                    displayStringForOption:
                                        (Hemotion emotion) => emotion.name,

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
                                            cursorColor: cloudPink(),
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
                                          color:
                                              sphereColors[i]?.toColor() ??
                                              Colors.white10,
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
                                      color: mixedHSLColor(chosenSphereColors),
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
                              borderSide: BorderSide(color: cloudPink()),
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
                              borderSide: BorderSide(color: cloudPink()),
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
                              borderSide: BorderSide(color: cloudPink()),
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
                        lastDescriptionUpdate!.isEmpty &&
                        !colorWasChosen) {
                      setState(() {
                        errorColor = Colors.red;
                        error = "You must to choose at least something";
                      });
                    } else if (!isPrivate &&
                        _tags.isEmpty &&
                        lastDescriptionUpdate!.isEmpty) {
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
                    } else if (!isPrivate && lastDescriptionUpdate!.isEmpty) {
                      setState(() {
                        errorColor = Colors.red;
                        error =
                            "You must to write the description for the public dream";
                      });
                    } else {
                      addDream();
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
                      cursorColor: cloudPink(),
                      decoration: InputDecoration(
                        hintText: "Add a name",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cloudPink()),
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
                      cursorColor: cloudPink(),

                      decoration: InputDecoration(
                        hintText: "Describe your dream...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: cloudPink()),
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
                  : cloudPink();
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

// i am tired
// would do more tomorow
// class for days from the calendar
class CalendarDay {
  int id;
  String name;
  String description;
  DateTime date;
  bool isPrivate;
  DateTime publicationDate;
  List<dynamic> tags;
  List<dynamic> emotions;
  String user;
  int likes;

  CalendarDay({
    required this.likes,
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.isPrivate,
    required this.publicationDate,
    required this.tags,
    required this.emotions,
    required this.user,
  });
}

class _CalendarState extends State<Calendar> {
  late String _tempName;
  late String _description;
  late int _privacity;
  late int _date;
  late List<String> _tags;
  late List<String> _emotions;
  late int _id;

  List _dreamsList = [];
  Map<DateTime, List<String>> dreams = {};
  List<CalendarDay> calendarDreams = [];
  late TextEditingController descriptionController;
  late TextEditingController nameController;

  // get all data about dreams from the backend
  Future<void> askAboutDreams() async {
    final response = await http.get(
      Uri.parse("$server/api/askAboutDreams?username=$user"),
      headers: {"Content-Type": "application/json"},
    );

    final data = json.decode(response.body);
    List dreamsList = data["dreamsList"];
    setState(() {
      calendarDreams.clear();
      for (var cDream in dreamsList) {
        calendarDreams.add(
          CalendarDay(
            id: cDream["ID"],
            name: cDream["Name"],
            description: cDream["Description"],
            date: normalize(intToDate(cDream["Date"])),
            isPrivate: (cDream["IsPrivate"] == 1),
            publicationDate: intToDate(cDream["PublicationDate"]),
            tags: cDream["Tags"],
            emotions: cDream["Emotions"],
            user: cDream["User"],
            likes: cDream["Likes"] ?? 0,
          ),
        );
      }

      dreams.clear();
      _dreamsList = dreamsList;
      for (int c = 0; c < _dreamsList.length; c++) {
        DateTime date = intToDate(_dreamsList[c]["Date"]);
        final key = normalize(date);

        final List<String> dEmotions = List<String>.from(
          (_dreamsList[c]["Emotions"]),
        );

        dreams.putIfAbsent(key, () => []);

        dreams[key]!.addAll(dEmotions);
      }
    });
  }

  Future<void> deleteThisDream(dream) async {
    await http.delete(
      Uri.parse("$server/api/deleteThisDream?dream=$dream"),
      headers: {"Content-Type": "application/json"},
    );
  }

  Future<void> saveTheChanges() async {
    await http.put(
      Uri.parse("$server/api/saveTheChanges"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": _id,
        "name": _tempName,
        "description": _description,
        "isPrivate": _privacity,
        "date": _date,
        "tags": _tags,
        "emotions": _emotions,
      }),
    );
  }

  Color getEmotionColor(String emotion) {
    for (var e in hSLemotions) {
      if (e.name == emotion) return e.color.toColor();
    }
    return Colors.transparent;
  }

  Color getColor(DateTime day) {
    bool hasDreams = false;
    List<HSLColor> hSLColors = [];

    for (CalendarDay dream in calendarDreams) {
      if (dream.date == day) {
        hasDreams = true;

        for (var e in dream.emotions) {
          for (var h in hSLemotions) {
            if (h.name == e) {
              hSLColors.add(h.color);
              break;
            }
          }
        }
      }
    }
    if (!hasDreams) {
      return Colors.transparent;
    } else if (hSLColors.isEmpty) {
      return Colors.grey;
    }
    return mixEmotions(hSLColors).toColor();
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

    descriptionController = TextEditingController();
    nameController = TextEditingController();

    _selectedDay = _focusedDay;
  }

  // we need this one to deleting data when we are not looking at the widget
  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();

    _selectedDays.dispose();
    super.dispose();
  }

  Color getTextColor(DateTime day) {
    Color textColor = (getColor(day) == Colors.transparent)
        ? Colors.white
        : Colors.black;
    return textColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: TableCalendar(
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
          focusedDay: _focusedDay,
          firstDay: DateTime(2000, 1, 1),
          lastDay: DateTime.now(),

          // we need this just because "==" is not working with DateTime normaly TTnTT
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },

          calendarBuilders: CalendarBuilders(
            // builder for today
            todayBuilder: (context, day, _) {
              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: getColor(normalize(day)),
                  shape: BoxShape.circle,
                  border: Border.all(color: cloudPink(), width: 3),
                ),
                child: Center(
                  child: Text(
                    "${day.day}",
                    style: TextStyle(color: getTextColor(normalize(day))),
                  ),
                ),
              );
            },

            // builder for a day what we selecting
            selectedBuilder: (context, day, _) {
              return Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: getColor(normalize(day)),
                  border: Border.all(color: Colors.white, width: 3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: getTextColor(normalize(day))),
                  ),
                ),
              );
            },

            // builder for all days
            defaultBuilder: (context, day, focusedDay) {
              bool hasAColor = false;
              for (CalendarDay calDream in calendarDreams) {
                if (normalize(calDream.date) == normalize(day)) {
                  hasAColor = true;
                  break;
                }
              }

              return (!hasAColor)
                  // null means clasic buider
                  ? null
                  : Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: getColor(normalize(day)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${day.day}",
                          style: TextStyle(color: getTextColor(normalize(day))),
                        ),
                      ),
                    );
            },
          ),

          // changing a day to the day what you are selecting
          onDaySelected: (selectedDay, focusedDay) {
            for (var days in calendarDreams) {
              if (days.date == normalize(selectedDay)) {
                _showTheDream(days);
                break;
              }
            }
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }

  // returning likes and their owners for a dream by his id in map format, where user id is a key and name is a value
  Future<List<Map<String, dynamic>>> getDreamLikesOwners(int id) async {
    final response = await http.get(
      Uri.parse("$server/api/getDreamLikesOwners?dreamId=$id"),
      headers: {"Content-Type": "application/json"},
    );

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final list = decoded["likeOwners"] as List;

    return list.cast<Map<String, dynamic>>();
  }

  // returning likes and their owners for a dream by his id in map format, where user id is a key and name is a value
  Future<List<Map<String, dynamic>>> getDreamCommentsOwners(int id) async {
    final response = await http.get(
      Uri.parse("$server/api/getDreamLikesOwners?dreamId=$id"),
      headers: {"Content-Type": "application/json"},
    );

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final list = decoded["likeOwners"] as List;

    return list.cast<Map<String, dynamic>>();
  }

  //              //
  // Dialog  Part //
  //              //
  Future<void> _showTheDream(CalendarDay dream) async {
    bool changes = false;
    Color mainColor = getColor(normalize(dream.date));

    final List<Map<String, dynamic>> listOfLikeOwners =
        await getDreamLikesOwners(dream.id);

    List<Map<String, dynamic>> commentsCalendarList = await getComments(
      dream.id,
    );

    String errorText = "";

    // temporary guys
    String tempDescription = dream.description;
    String tempName = dream.name;
    bool tempPrivacity = dream.isPrivate;
    DateTime tempDate = dream.date;

    List<Hemotion> tempEmotions = [];
    void getEmotionsFromTheDB() {
      tempEmotions.clear();
      for (String dreamEmotion in dream.emotions) {
        for (Hemotion staticEmotion in hSLemotions) {
          if (dreamEmotion == staticEmotion.name) {
            tempEmotions.add(staticEmotion);
            break;
          }
        }
      }
    }

    getEmotionsFromTheDB();

    List<String> tempTags = List.from(dream.tags);

    descriptionController.text = tempDescription;
    nameController.text = tempName;

    Future<bool> confirmClose() async {
      final bool? result = await showModalBottomSheet<bool>(
        context: context,
        //useRootNavigator: true,
        backgroundColor: const Color.fromARGB(255, 7, 7, 7),
        builder: (sheetContext) {
          return SizedBox(
            height: 150,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 15),
                Text(
                  "Are you sure, you want to close this dream?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  "you still have unsaved data",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    cloudyButton(
                      "Cancel",
                      () {
                        Navigator.of(sheetContext).pop(null);
                      },
                      Colors.white,
                      mainColor,
                    ),
                    cloudyButton(
                      "Still Close",
                      () {
                        Navigator.of(sheetContext).pop(true);
                      },
                      Colors.white,
                      Colors.red,
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        },
      );
      if (result != null) {
        return true;
      }
      return false;
    }

    await showDialog(
      barrierDismissible: (!changes),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return PopScope(
              canPop: (!changes),
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;

                final shouldClose = await confirmClose();
                if (shouldClose) {
                  Navigator.of(dialogContext).pop(result);
                }
              },
              child: AlertDialog(
                backgroundColor: const Color.fromARGB(255, 5, 5, 5),
                content: /*maybe we need to put it into the function*/ SizedBox(
                  width: 250,
                  height: 520,
                  child: Column(
                    children: [
                      // top part
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: Row(
                            children: [
                              // user name
                              Expanded(
                                flex: 1,
                                child: Text(
                                  dream.user,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              // dream name
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,

                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: mainColor,
                                    ),

                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: Center(
                                        child: TextField(
                                          controller: nameController,
                                          maxLines: 1,
                                          keyboardType: TextInputType.multiline,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,

                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.all(8),
                                          ),
                                          onChanged: (value) {
                                            setDialogState(() {
                                              tempName = value;
                                              changes = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // middle part
                      SizedBox(
                        height: 320,
                        child: Row(
                          children: [
                            // description text part
                            SizedBox(
                              width: 165,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 10, 10, 10),
                                  borderRadius: BorderRadius.circular(5),
                                ),

                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    height: 300,
                                    child: TextField(
                                      expands: true,
                                      controller: descriptionController,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          tempDescription = value;
                                          changes = true;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            // right middle part
                            SizedBox(
                              child: Column(
                                children: [
                                  SizedBox(height: 5),
                                  // privacity part
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: InkWell(
                                      splashColor: Colors.white10,
                                      borderRadius: BorderRadius.circular(8),

                                      child: Row(
                                        children: [
                                          Icon(
                                            tempPrivacity
                                                ? Icons.lock
                                                : Icons.lock_open,
                                            color: mainColor,
                                          ),
                                          Text(
                                            tempPrivacity
                                                ? "Private"
                                                : "Public",
                                            style: TextStyle(color: mainColor),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        setDialogState(() {
                                          tempPrivacity = !tempPrivacity;
                                          changes = true;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // emotions part
                                  InkWell(
                                    child: SizedBox(
                                      height: 150,
                                      width: 80,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            7,
                                            7,
                                            7,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),

                                        child: Column(
                                          children: [
                                            Text(
                                              "Emotions:",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),

                                            for (Hemotion everyEmotion
                                                in tempEmotions)
                                              Text(
                                                everyEmotion.name,
                                                style: TextStyle(
                                                  color: getEmotionColor(
                                                    everyEmotion.name,
                                                  ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    //
                                    // emotions bottom sheet
                                    //
                                    onTap: () async {
                                      final List<Hemotion>?
                                      result = await showModalBottomSheet<List<Hemotion>>(
                                        context: dialogContext,
                                        useRootNavigator: true,
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          7,
                                          7,
                                          7,
                                        ),
                                        builder: (sheetContext) {
                                          List<Hemotion> sheetEmotions =
                                              List<Hemotion>.from(tempEmotions);
                                          List<HSLColor> sheetEmotionsColor =
                                              [];
                                          for (Hemotion e in sheetEmotions) {
                                            sheetEmotionsColor.add(e.color);
                                          }

                                          return StatefulBuilder(
                                            builder: (context, setSheetState) {
                                              return SizedBox(
                                                height: 400,
                                                width: double.infinity,
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 20),
                                                      // top color combination part
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          for (
                                                            int i = 0;
                                                            i < 6;
                                                            i++
                                                          )
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  margin:
                                                                      EdgeInsets.symmetric(
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 3,
                                                                    ),
                                                                  ),
                                                                  child: Container(
                                                                    width: 5,
                                                                    height: 5,
                                                                    margin:
                                                                        EdgeInsets.symmetric(
                                                                          vertical:
                                                                              1,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color:
                                                                          (i <
                                                                              sheetEmotionsColor.length)
                                                                          ? sheetEmotionsColor[i].toColor()
                                                                          : Colors.white10,
                                                                      border: Border.all(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            1.5,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          // arrow
                                                          Icon(
                                                            Icons
                                                                .keyboard_double_arrow_right,
                                                            color:
                                                                sheetEmotions
                                                                    .isNotEmpty
                                                                ? Colors.white
                                                                : Colors
                                                                      .white10,
                                                          ),
                                                          // mixed emotions
                                                          Container(
                                                            margin:
                                                                EdgeInsets.symmetric(
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    7,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 3,
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .square_rounded,
                                                              color:
                                                                  (sheetEmotionsColor
                                                                      .isEmpty)
                                                                  ? Colors
                                                                        .white10
                                                                  : mixEmotions(
                                                                      sheetEmotionsColor,
                                                                    ).toColor(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Wrap(
                                                        spacing: 8,
                                                        children: [
                                                          for (Hemotion e
                                                              in hSLemotions)
                                                            cloudyButton(
                                                              e.name,
                                                              () {
                                                                setSheetState(() {
                                                                  if (sheetEmotions
                                                                      .contains(
                                                                        e,
                                                                      )) {
                                                                    sheetEmotions
                                                                        .remove(
                                                                          e,
                                                                        );
                                                                    sheetEmotionsColor
                                                                        .remove(
                                                                          e.color,
                                                                        );
                                                                  } else if (sheetEmotions
                                                                          .length <
                                                                      6) {
                                                                    sheetEmotions
                                                                        .add(e);
                                                                    sheetEmotionsColor
                                                                        .add(
                                                                          e.color,
                                                                        );
                                                                  }
                                                                });
                                                              },
                                                              (sheetEmotions
                                                                      .contains(
                                                                        e,
                                                                      ))
                                                                  ? Colors.white
                                                                  : Colors.grey,
                                                              (sheetEmotions
                                                                      .contains(
                                                                        e,
                                                                      ))
                                                                  ? e.color
                                                                        .toColor()
                                                                  : Colors
                                                                        .white,
                                                            ),
                                                        ],
                                                      ),
                                                      const Spacer(),

                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          cloudyButton(
                                                            "Cancel",
                                                            () {
                                                              Navigator.of(
                                                                sheetContext,
                                                              ).pop(null);
                                                            },
                                                            cloudPink(),
                                                            Colors.white,
                                                          ),
                                                          cloudyButton(
                                                            "Save",
                                                            () {
                                                              Navigator.of(
                                                                sheetContext,
                                                              ).pop(
                                                                sheetEmotions,
                                                              );
                                                            },
                                                            cloudPink(),
                                                            Colors.white,
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                      if (result != null) {
                                        changes = true;
                                        setDialogState(() {
                                          tempEmotions = result;
                                          List<HSLColor> mixList = [];
                                          for (Hemotion c in tempEmotions) {
                                            mixList.add(c.color);
                                          }
                                          mainColor = (mixList.isNotEmpty)
                                              ? mixEmotions(mixList).toColor()
                                              : Colors.grey;
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(height: 5),
                                  //
                                  // tags part
                                  //
                                  SizedBox(
                                    height: 110,
                                    width: 80,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          7,
                                          7,
                                          7,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: InkWell(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Tags:",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            for (
                                              int t = 0;
                                              t <= 3 && t < tempTags.length;
                                              t++
                                            )
                                              Text(
                                                (t != 3)
                                                    ? tempTags[t]
                                                    : "and other...",
                                                style: TextStyle(
                                                  color: (t != 3)
                                                      ? Colors.white
                                                      : Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                        // tags bottom sheet
                                        onTap: () async {
                                          final List<String>? result =
                                              await showModalBottomSheet<
                                                List<String>
                                              >(
                                                context: dialogContext,
                                                useRootNavigator: true,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      7,
                                                      7,
                                                      7,
                                                    ),
                                                builder: (sheetContext) {
                                                  List<String> sheetTags =
                                                      List.from(tempTags);

                                                  void changeTagStatus(
                                                    String tag,
                                                  ) {
                                                    if (sheetTags.contains(
                                                      tag,
                                                    )) {
                                                      sheetTags.remove(tag);
                                                    } else {
                                                      sheetTags.add(tag);
                                                    }
                                                  }

                                                  return SizedBox(
                                                    height: 400,
                                                    width: double.infinity,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 15,
                                                        ),

                                                        Wrap(
                                                          spacing: 8,
                                                          runSpacing: 8,
                                                          children: [
                                                            for (final tag
                                                                in tagList)
                                                              statusCloudyButton(
                                                                tag,
                                                                () =>
                                                                    changeTagStatus(
                                                                      tag,
                                                                    ),
                                                                sheetTags
                                                                    .contains(
                                                                      tag,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),

                                                        const Spacer(),

                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            cloudyButton(
                                                              "Cancel",
                                                              () {
                                                                Navigator.of(
                                                                  sheetContext,
                                                                ).pop(null);
                                                              },
                                                              cloudPink(),
                                                              Colors.white,
                                                            ),
                                                            cloudyButton(
                                                              "Save",
                                                              () {
                                                                Navigator.of(
                                                                  sheetContext,
                                                                ).pop(
                                                                  sheetTags,
                                                                );
                                                              },
                                                              cloudPink(),
                                                              Colors.white,
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );

                                          if (result != null) {
                                            changes = true;
                                            setDialogState(() {
                                              tempTags = result;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          InkWell(
                            // show users that liked your dream
                            onTap: listOfLikeOwners.isEmpty
                                ? null
                                : () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        7,
                                        7,
                                        7,
                                      ),
                                      builder: (sheetContext) {
                                        return StatefulBuilder(
                                          builder: (context, setSheetState) {
                                            return SizedBox(
                                              height: 300,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.all(15),
                                                    child: Text(
                                                      "People that liked your dream",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListView(
                                                      children: [
                                                        for (var u
                                                            in listOfLikeOwners)
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  right: 15,
                                                                  left: 15,
                                                                  bottom: 5,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                width: 3,
                                                                color: Colors
                                                                    .white70,
                                                              ),
                                                              color:
                                                                  Colors.black,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "user: ${u["username"]}",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                            child: Row(
                              children: [
                                Icon(
                                  dream.likes != 0
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: dream.likes != 0
                                      ? mainColor
                                      : Colors.grey,
                                ),
                                Text(
                                  dream.likes.toString(),
                                  style: TextStyle(
                                    color: dream.likes != 0
                                        ? mainColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            //it shows comments for your dream
                            onTap: commentsCalendarList.isEmpty
                                ? null
                                : () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        7,
                                        7,
                                        7,
                                      ),
                                      builder: (sheetContext) {
                                        return StatefulBuilder(
                                          builder: (context, setSheetState) {
                                            return SizedBox(
                                              height: 300,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.all(15),
                                                    child: Text(
                                                      "Comments for your dream",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListView(
                                                      children: [
                                                        for (var comm
                                                            in commentsCalendarList)
                                                          // Container for all comments
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  right: 15,
                                                                  left: 15,
                                                                  bottom: 5,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                width: 3,
                                                                color: Colors
                                                                    .white70,
                                                              ),
                                                              color:
                                                                  Colors.black,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                            ),
                                                            child: Container(
                                                              margin:
                                                                  EdgeInsets.all(
                                                                    5,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    "Dreamer: ${comm["CommentedBy"]} \nsaid: ${comm["Description"]}",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Spacer(),
                                                                  Text(
                                                                    "${intToDate(comm["Date"]).year.toString()}-${intToDate(comm["Date"]).month.toString()}-${intToDate(comm["Date"]).day.toString()}",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                            child: Row(
                              children: [
                                Text(
                                  commentsCalendarList.length.toString(),
                                  style: TextStyle(
                                    color: commentsCalendarList.isEmpty
                                        ? Colors.grey
                                        : Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.comment,
                                  color: commentsCalendarList.isEmpty
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // bottom part
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            // "hello"
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: InkWell(
                                  child: Text(
                                    "Dream Date: ${tempDate.year}-${tempDate.month}-${tempDate.day}",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  onTap: () async {
                                    List<DateTime> chosenDays = [];
                                    for (final CalendarDay chosenDay
                                        in calendarDreams) {
                                      chosenDays.add(chosenDay.date);
                                    }

                                    DateTime initial = normalize(
                                      DateTime.now(),
                                    );

                                    while (chosenDays.contains(initial)) {
                                      initial = initial.subtract(
                                        const Duration(days: 1),
                                      );
                                    }

                                    // date pick part
                                    DateTime? result = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),

                                      selectableDayPredicate: (day) {
                                        for (final disabled in chosenDays) {
                                          if (isSameDay(
                                            normalize(day),
                                            normalize(disabled),
                                          )) {
                                            return false;
                                          }
                                        }
                                        return true;
                                      },

                                      initialDate: initial,

                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: cloudPink(),
                                            colorScheme: ColorScheme.light(
                                              primary: cloudPink(),
                                              onPrimary: Colors.white,
                                              surface: Color.fromARGB(
                                                255,
                                                5,
                                                5,
                                                5,
                                              ),
                                              onSurface: Colors.white,
                                            ),
                                            dialogTheme: DialogThemeData(
                                              backgroundColor: Colors.black,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (result != null) {
                                      changes = true;
                                      setDialogState(() {
                                        tempDate = result;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              // hiiiii :) hiiiii :)
                              child: Center(
                                child: Text(
                                  "Publication Date: ${dream.publicationDate.year}-${dream.publicationDate.month}-${dream.publicationDate.day}",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // delete dream button
                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: Center(
                                child: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                              ),
                              // are you sure you want to delete this dream
                              onTap: () async {
                                final bool?
                                result = await showModalBottomSheet<bool>(
                                  context: dialogContext,
                                  useRootNavigator: true,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    7,
                                    7,
                                    7,
                                  ),
                                  builder: (sheetContext) {
                                    return StatefulBuilder(
                                      builder: (context, setSheetState) {
                                        return SizedBox(
                                          height: 155,
                                          width: double.infinity,
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    // top text part
                                                    Text(
                                                      "Are you sure you want to delete this dream?",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          tempName,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: mainColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          " will be lost forever! (A long time!)",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  cloudyButton(
                                                    "Cancel",
                                                    () {
                                                      Navigator.of(
                                                        sheetContext,
                                                      ).pop(null);
                                                    },
                                                    Colors.white,
                                                    mainColor,
                                                  ),
                                                  cloudyButton(
                                                    "Delete",
                                                    () {
                                                      Navigator.of(
                                                        sheetContext,
                                                      ).pop(true);
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();
                                                    },
                                                    Colors.white,
                                                    Colors.red,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 30),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                if (result != null) {
                                  deleteThisDream(dream.id);
                                  askAboutDreams();
                                }
                              },
                            ),
                            // reset button
                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: Center(
                                child: Icon(
                                  Icons.restore,
                                  color: (changes) ? mainColor : Colors.white10,
                                ),
                              ),
                              onTap: () {
                                if (changes) {
                                  setDialogState(() {
                                    tempTags = List.from(dream.tags);
                                    getEmotionsFromTheDB();
                                    tempDate = dream.date;
                                    tempPrivacity = dream.isPrivate;

                                    tempName = dream.name;
                                    nameController.text = tempName;

                                    tempDescription = dream.description;
                                    descriptionController.text =
                                        tempDescription;

                                    mainColor = getColor(normalize(dream.date));
                                    changes = false;
                                  });
                                }
                              },
                            ),
                            // save changes button
                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: Center(
                                child: Icon(
                                  Icons.save,
                                  color: (changes) ? mainColor : Colors.white10,
                                ),
                              ),
                              onTap: () async {
                                // save sheet
                                if (changes) {
                                  setDialogState(() {
                                    errorText = "";
                                  });
                                  final bool?
                                  result = await showModalBottomSheet<bool>(
                                    context: dialogContext,
                                    useRootNavigator: true,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      7,
                                      7,
                                      7,
                                    ),
                                    builder: (sheetContext) {
                                      return StatefulBuilder(
                                        builder: (context, setSheetState) {
                                          return SizedBox(
                                            height: 162,
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 20),
                                                      // top text part
                                                      SizedBox(
                                                        width: 250,
                                                        child: Text(
                                                          "Are you sure you want to save changes in this dream?",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  errorText,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Spacer(),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    cloudyButton(
                                                      "Cancel",
                                                      () {
                                                        Navigator.of(
                                                          sheetContext,
                                                        ).pop(null);
                                                      },
                                                      Colors.white,
                                                      mainColor,
                                                    ),
                                                    cloudyButton(
                                                      "Save",
                                                      () {
                                                        if ((!tempPrivacity &&
                                                                tempTags
                                                                    .isNotEmpty &&
                                                                tempDescription
                                                                    .isNotEmpty) ||
                                                            tempPrivacity) {
                                                          Navigator.of(
                                                            sheetContext,
                                                          ).pop(true);
                                                        } else {
                                                          if (tempTags
                                                              .isEmpty) {
                                                            setSheetState(() {
                                                              errorText =
                                                                  "please choose at least one Tag for your public dream";
                                                            });
                                                          } else if (tempDescription
                                                              .isEmpty) {
                                                            setSheetState(() {
                                                              errorText =
                                                                  "please write a description for your public dream";
                                                            });
                                                          }
                                                        }
                                                      },
                                                      Colors.white,
                                                      mainColor,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 30),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                  if (result != null) {
                                    setDialogState(() {
                                      changes = false;
                                    });
                                    List<String> tempEmotionsName = [];
                                    for (Hemotion e in tempEmotions) {
                                      tempEmotionsName.add(e.name);
                                    }
                                    _id = dream.id;
                                    _tags = tempTags;
                                    _emotions = tempEmotionsName;
                                    _date = dateToInt(tempDate);
                                    _privacity = (tempPrivacity ? 1 : 0);
                                    _tempName = tempName;
                                    _description = tempDescription;

                                    saveTheChanges();
                                    askAboutDreams();
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DreamViev extends StatefulWidget {
  const DreamViev({super.key});

  @override
  State<DreamViev> createState() => _DreamViev();
}

// Icon what, when we do tab on it, doing something
InkWell onTabIcon(Icon icon, Future<void> Function() doSomething) {
  return InkWell(onTap: doSomething, child: icon);
}

// class for showing our dream inside Tiles
class TileDream extends Dream {
  final DateTime publicationDate;
  final List<String> emotionsName;
  final String owner;
  final int id;
  final bool doILikeThis;

  TileDream({
    required this.id,
    required this.owner,
    required this.publicationDate,
    required this.emotionsName,
    required this.doILikeThis,

    required super.likes,
    required super.tags,
    required super.name,
    required super.date,
    required super.isPrivate,
    required super.emotionColor,
    required super.describe,
  });
}

//                                    //
// Widget for showing Dreams in Tiles //
//                                    //
class _DreamViev extends State<DreamViev> {
  List? tileDreams;
  List<TileDream> tileDreamsList = [];
  dynamic userTags;

  //
  // getting dreams from the backend
  //
  Future<void> getBackendDreams(String? chooseOption) async {
    final response = await http.get(
      Uri.parse(
        "$server/api/getBackendDreams?username=$user&chooseOption=$chooseOption",
      ),
      headers: {"Content-Type": "application/json"},
    );

    final data = json.decode(response.body);
    tileDreams = data["dreamsList"];

    tileDreamsList.clear();

    // getting from "2,10" String a [2,10] List<int>
    List<int> idFromStringToList(String? stringId) {
      if (stringId == null || stringId.trim().isEmpty) return [];
      return stringId.split(",").map((id) => int.parse(id.trim())).toList();
    }

    if (tileDreams != null) {
      for (var dream in tileDreams!) {
        List<HSLColor> emotionsColor = [];
        List<String> emotionsName = [];
        List<String> tagsName = [];

        // for emotions
        final List<int> tileEmotionsID = idFromStringToList(
          dream[5]?.toString(),
        );
        for (int id in tileEmotionsID) {
          if (id - 1 < hSLemotions.length) {
            emotionsColor.add(hSLemotions[id - 1].color);
            emotionsName.add(hSLemotions[id - 1].name);
          }
        }

        // for tags
        final List<int> tileTagsID = idFromStringToList(dream[6]?.toString());
        for (int id in tileTagsID) {
          if (id - 1 < tagList.length) {
            tagsName.add(tagList[id - 1]);
          }
        }
        tileDreamsList.add(
          TileDream(
            id: dream[0],
            publicationDate: normalize(intToDate(dream[4])),
            tags: tagsName,
            name: dream[1],
            date: normalize(intToDate(dream[3])),
            isPrivate: 0,
            emotionColor: emotionsColor.isNotEmpty
                ? mixEmotions(emotionsColor).toColor()
                : Colors.grey,
            describe: dream[2],
            emotionsName: emotionsName,
            owner: dream[7],
            likes: dream[8] ?? 0,
            doILikeThis: dream[9] == 1,
          ),
        );
      }
    }
    userTags = data["userTags"];

    if (mounted) {
      setState(() {});
    }
    //print(userTags);
  }

  String? _dropdownValue;
  // getting dreams at the start
  @override
  void initState() {
    super.initState();
    _dropdownValue = listChooseBy[0].value;
    getBackendDreams(_dropdownValue);
  }

  // list of all searching options
  List<DropdownMenuItem<String>> listChooseBy = [
    DropdownMenuItem(value: "userTags", child: Text("Your tags")),
    DropdownMenuItem(value: "userFriends", child: Text("Friends")),
    DropdownMenuItem(value: "userLikes", child: Text("My Likes")),
    DropdownMenuItem(value: "chosenTags", child: Text("Tags")),
    DropdownMenuItem(value: "chosenEmotions", child: Text("Emotions")),
  ];

  // change value of chosen options and send backend request
  void dropdownCallBack(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _dropdownValue = selectedValue;
      });
      getBackendDreams(_dropdownValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.only(left: 2, top: 5),
        child: Column(
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: cloudPink()),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButton<String>(
                iconSize: 32,
                isExpanded: true,
                items: listChooseBy,
                value: _dropdownValue,
                onChanged: dropdownCallBack,
                dropdownColor: const Color.fromARGB(255, 7, 7, 7),
                iconEnabledColor: cloudPink(),
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // our Tiles
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                itemCount: tileDreams != null ? tileDreams!.length : 0,
                itemBuilder: (context, index) {
                  return Tile(
                    index: index,
                    maxHeight: 250,
                    dream: tileDreamsList[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// api function for getting commenst for the dream
Future<List<Map<String, dynamic>>> getComments(int dreamId) async {
  //try {
  final response = await http.get(
    Uri.parse("$server/api/getComments?dream=$dreamId"),
    headers: {"Content-Type": "application/json"},
  );

  final data = json.decode(response.body);
  if (data["noComments"]) {
    return [];
  }
  return List<Map<String, dynamic>>.from(data["comments"]);
}

//                      //
// Creating Tiles Part  //
//                      //
class Tile extends StatefulWidget {
  final int index;
  final double maxHeight;
  final TileDream dream;

  const Tile({
    super.key,
    required this.index,
    required this.maxHeight,
    required this.dream,
  });

  @override
  State<Tile> createState() => _TileState();
}

// sending to the backend request for changing friendship status
Future<void> changeFriendshipStatus(String newFriendName) async {
  await http.post(
    Uri.parse("$server/api/changeFriendshipStatus"),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"user": user, "friend": newFriendName}),
  );
}

class _TileState extends State<Tile> {
  late bool localIsLiked;
  late int localLikesCount;

  @override
  void initState() {
    super.initState();
    localIsLiked = widget.dream.doILikeThis;
    localLikesCount = widget.dream.likes;
  }

  @override
  void didUpdateWidget(covariant Tile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dream.id != widget.dream.id) {
      localIsLiked = widget.dream.doILikeThis;
      localLikesCount = widget.dream.likes;
    }
  }
  // ai helped

  // api function for liking
  Future<void> changeBackendLikeStatus() async {
    setState(() {
      localIsLiked = !localIsLiked;
      localIsLiked ? localLikesCount++ : localLikesCount--;
    });

    try {
      await http.get(
        Uri.parse(
          "$server/api/changeBackendLikeStatus?username=$user&dream=${widget.dream.id}",
        ),
        headers: {"Content-Type": "application/json"},
      );
    } catch (error) {
      setState(() {
        localIsLiked = !localIsLiked;
        localIsLiked ? localLikesCount-- : localLikesCount++;
      });
    }
  }

  // sending our text to the backend
  Future<void> sendYourComment(String comment, int dreamID, int date) async {
    await http.post(
      Uri.parse("$server/api/sendYourComment"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "comment": comment,
        "user": user,
        "dreamID": dreamID,
        "date": date,
      }),
    );
  }

  // deleting comment of user by comment ID
  Future<void> deleteComment(commentID) async {
    await http.delete(
      Uri.parse("$server/api/deleteComment"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'comment': commentID}),
    );
  }

  Future<void> showCommentsSheet() async {
    final TextEditingController commentController = TextEditingController();

    // first list is a list of comments
    // second is a list of comment attributes
    // map is this attribustes
    List<Map<String, dynamic>> comments = await getComments(widget.dream.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 7, 7, 7),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Padding is cool
            // Love padding
            // it goes up with your keybord when you awake she
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // all comments + adding new
              child: SizedBox(
                height: 650,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(7),
                      child: Text(
                        "Comments",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: comments.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "No comments yet",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "But you could be the first.",
                                  style: TextStyle(
                                    color: Colors.white30,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 10),
                              itemCount: comments.length,
                              itemBuilder: (context, i) {
                                final comment = comments[i];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 3,
                                      color: Colors.white70,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.black87,
                                  ),
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(10),
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "dreamer: ${comment["CommentedBy"]}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              "${intToDate(comment["Date"]).year}-${intToDate(comment["Date"]).month}-${intToDate(comment["Date"]).day}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                comment["Description"],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (comment["CommentedBy"] == user)
                                          Column(
                                            children: [
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    child: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red,
                                                    ),
                                                    onTap: () async {
                                                      await deleteComment(
                                                        comment["CommentID"],
                                                      );
                                                      final newComments =
                                                          await getComments(
                                                            widget.dream.id,
                                                          );
                                                      setSheetState(() {
                                                        comments = newComments;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Row(
                      children: [
                        // Write a new comment part
                        Container(
                          margin: EdgeInsets.only(left: 20, bottom: 20),
                          width: 275,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          // Column for writting comments
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: commentController,
                            cursorColor: cloudPink(),
                            decoration: InputDecoration(
                              hintText: "Write new comment",
                              hintStyle: TextStyle(color: Colors.white),
                              // x button for clear
                              suffixIcon: IconButton(
                                onPressed: () => commentController.clear(),
                                icon: Icon(Icons.clear, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        // send button
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: OutlinedButton(
                            onPressed: commentController.text.trim().isEmpty
                                ? null
                                : () async {
                                    await sendYourComment(
                                      commentController.text,
                                      widget.dream.id,
                                      dateToInt(DateTime.now()),
                                    );
                                    commentController.clear();
                                    comments = await getComments(
                                      widget.dream.id,
                                    );

                                    setSheetState(() {});
                                  },
                            child: Icon(Icons.send, color: cloudPink()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // sending a request to the backend to verify whether this user is our friend yet
  // returning true or false
  Future<bool> isHeMyFriend(String potentialFriendName) async {
    final response = await http.get(
      Uri.parse(
        "$server/api/isHeMyFriend?myName=$user&protentialFriend=$potentialFriendName",
      ),
      headers: {"Content-Type": "application/json"},
    );
    final data = json.decode(response.body);
    return data["friendship"];
  }

  // would return a lile list of dreams what this user have
  void showUserProfile(userName) {}

  // report user for something
  void reportUser(reportedUser) {}

  Future<void> optionWithThisUser(bool isFriend) {
    bool friendship = isFriend;
    // asking backend about current friendship status
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 7, 7, 7),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Padding is cool
            // Love padding
            // it goes up with your keybord when you awake she
            return SizedBox(
              height: 130,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Text(
                    "What do you want to do with this user?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    friendship
                        ? "He is your friend"
                        : "You are not friend with this user yet",
                    style: TextStyle(color: cloudPink(), fontSize: 14),
                  ),
                  Spacer(),
                  Wrap(
                    children: [
                      cloudyButton(
                        "His dreams",
                        () {
                          showUserProfile(widget.dream.owner);
                        },
                        Colors.green,
                        Colors.white,
                      ),
                      SizedBox(width: 5),
                      cloudyButton(
                        friendship ? "End friendship" : "New friend",
                        () {
                          changeFriendshipStatus(widget.dream.owner);
                          setSheetState(() {
                            friendship = !friendship;
                          });
                        },
                        Colors.blue,
                        Colors.white,
                      ),
                      SizedBox(width: 5),
                      cloudyButton(
                        "Report",
                        () {
                          reportUser(widget.dream.owner);
                        },
                        Colors.red,
                        Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),

        // our dream viev
        child: Column(
          children: [
            // top part
            Container(
              height: 30,
              width: double.infinity,
              margin: const EdgeInsets.only(
                top: 5,
                left: 3,
                right: 3,
                bottom: 2,
              ),
              decoration: BoxDecoration(
                color: widget.dream.emotionColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.dream.name, textAlign: TextAlign.center),
            ),
            InkWell(
              onTap: () async {
                optionWithThisUser(await isHeMyFriend(widget.dream.owner));
              },
              child: Text(
                "User: ${widget.dream.owner}",
                style: TextStyle(color: Colors.white),
              ),
            ),
            // middle part
            // Constrains means it could be some constant max height
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(5),
                  child: Text(
                    widget.dream.describe,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            // bottom part
            Container(
              margin: EdgeInsets.only(right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // likes
                  onTabIcon(
                    Icon(
                      localIsLiked ? Icons.favorite : Icons.favorite_border,
                      color: localIsLiked
                          ? widget.dream.emotionColor
                          : Colors.grey,
                    ),
                    changeBackendLikeStatus,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 3),
                    child: Text(
                      localLikesCount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Spacer(),
                  // comments
                  onTabIcon(
                    Icon(Icons.comment, color: Colors.grey),
                    showCommentsSheet,
                  ),
                ],
              ),
            ),
            Wrap(
              children: [
                for (String tag in widget.dream.tags)
                  // Container for our tags
                  Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      " #$tag ",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                //Text(tag, style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

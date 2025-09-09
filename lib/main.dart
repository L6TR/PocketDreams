import 'package:flutter/material.dart';
import 'package:pocket_dreams/bloc/backend_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

//
// global guys
//
Map<DateTime, List<Dream>> dreams = {};

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
  @override
  Widget build(BuildContext context) {
    return Scaffold();
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
        return const Calendar();
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
  Emotion(name: "Warmth", color: Color.fromARGB(255, 255, 165, 0)),
];

//
//class for Dreams
//

class Dream {
  final DateTime date;
  final Color emotionColor;
  final String describe;

  Dream({
    required this.date,
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
  // List for all spheres + grey
  List<Color> sphereColors = List.generate(6, (_) => Colors.white10);

  // List for only chosen (i need that)
  List<Color> chosenSphereColors = [];

  List<EmotionButton> chosenEmotionButtons = [];

  //function for mixing collors
  Color mixedColor(List<Color> colorList) {
    double mixedA = 0;
    double mixedR = 0;
    double mixedG = 0;
    double mixedB = 0;

    if (colorList.isEmpty) return Colors.white10;

    for (int i = 0; i < colorList.length; i++) {
      mixedA += (colorList[i].a * 255.0 / colorList.length);

      mixedR += (colorList[i].r * 255.0 / colorList.length);

      mixedG += (colorList[i].g * 255.0 / colorList.length);

      mixedB += (colorList[i].b * 255.0 / colorList.length);
    }
    return Color.fromARGB(
      mixedA.round() & 0xff,
      mixedR.round() & 0xff,
      mixedG.round() & 0xff,
      mixedB.round() & 0xff,
    );
  }

  //function for adding a Dream to The Calendar
  Dream newDream(dreamsColor, dreamsDate, dreamsDescribe) {
    //print(dreamsColor);
    //print(dreamsDate);
    //print(dreamsDescribe);
    return Dream(
      date: dreamsDate,
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

  void newEmotionChoise(Emotion emotion) {
    int index = nextIndex(sphereColors);
    if (index != -1) {
      setState(() {
        sphereColors[index] = emotion.color;

        chosenSphereColors.add(emotion.color);

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

  final TextEditingController _dateController = TextEditingController();
  String _description = "";
  DateTime _chosenDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var chosenDate = DateTime.now();
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
                                /*EmotionButton(
                                  index: emotion.index,
                                  color: emotion.color,
                                  label: emotion.name,
                                  onPressed: () => Void,
                                );*/
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
                    ],
                  ),
                ),
                //Expanded(flex: 1, child: Icon(Icons.clear, color: Colors.red)),
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
                                  margin: EdgeInsets.symmetric(vertical: 1),
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
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

                SizedBox(
                  width: 110,
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

            /* SizedBox(
                    child: OutlinedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        side: WidgetStatePropertyAll(
                          BorderSide(
                            color: Color.fromARGB(255, 250, 175, 195),
                            width: 5,
                          ),
                        ),
                      ),
                      child: Text(
                        "Write",
                        style: TextStyle(color: Colors.black),
                      ),

                      //
                      // important!!!
                      //
                      onPressed: () {},
                    ),
                  ),*/
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: Color.fromARGB(255, 250, 175, 195),
                        width: 5,
                      ),
                    ),
                  ),
                  child: Text(
                    "Add a dream to the Calendar",
                    style: TextStyle(color: Colors.black),
                  ),

                  //
                  // important!!!
                  //
                  onPressed: () {
                    final dream = newDream(
                      mixedColor(chosenSphereColors),
                      _chosenDate,
                      _description,
                    );

                    addDreamToCalendar(dream);
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

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

  Future<void> _writeADescription() async {
    final TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 5, 5, 5),
          title: Text(
            "Write your dream",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            height: 200,
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 250, 175, 195),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _description = descriptionController.text;
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
}

//
// TodaysDream widget
// Base for _TodaysDreamState
//

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

//
// _TodaysDreamState
// child of TodaysDream()
//

class _CalendarState extends State<Calendar> {
  // final => const value
  // late => variable would have a value latter, but not on the start
  // ValueNotifier x; => doing something, when the value of x is changing
  late final ValueNotifier<List<Dream>> _selectedDays;

  DateTime _focusedDay = DateTime.now();

  // x? means that x would be Null in the begining and we are ok with that
  DateTime? _selectedDay;

  @override
  // initState() {x}; we are doing x, one time, when we are initing a State
  void initState() {
    //means, we dont @override it
    super.initState();

    _selectedDay = _focusedDay;

    // x! means i am sure that x wouldnt be Null
    _selectedDays = ValueNotifier(_getDreamsForDay(_selectedDay!));
  }

  // we need this one to deleting data when we are not looking at the widget
  @override
  void dispose() {
    _selectedDays.dispose();
    super.dispose();
  }

  // return the list of Object for the specific day
  List<Dream> _getDreamsForDay(DateTime day) {
    // x ?? y
    // means
    // if x is null, please, use y
    return dreams[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /*void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedDays.value = _getDreamsForDay(selectedDay);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: TableCalendar(
        calendarStyle: CalendarStyle(outsideDaysVisible: false),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        rowHeight: 80,
        focusedDay: DateTime.now(),
        firstDay: DateTime(2000, 1, 1),
        lastDay: DateTime(2100, 1, 1),

        // we need this just because "==" is not working with DateTime normaly TTnTT
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },

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
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, dreams) {
            if (dreams.isNotEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dreams.take(3).map((dream) {
                  //
                  // now we can use onTap
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: (context),
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          title: Text(
                            "Dream on ${date.toString().split(" ")[0]}",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            (dream).describe,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (dream as Dream).emotionColor,
                      ),
                    ),
                  );
                }).toList(),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

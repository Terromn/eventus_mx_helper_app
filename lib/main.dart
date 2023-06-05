import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Eventus Helper App',
      home: MyHomePage(title: 'Eventus Helper App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedEventName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0813),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF5400DA),
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading events');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF5400DA)),
                  );
                }

                List<String> eventNames = snapshot.data!.docs
                    .map((doc) => doc['eventName'] as String)
                    .toList();

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF5400DA), // Outline color
                            width: 2.0, // Outline width
                          ),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        margin: const EdgeInsets.all(24.0),
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(

                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 500,
                                  color: const Color(0xFF0A0813),
                                  child: ListView.builder(
                                    itemCount: eventNames.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Text(eventNames[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                            textAlign: TextAlign.center),
                                        onTap: () {
                                          setState(() {
                                            selectedEventName =
                                                eventNames[index];
                                          });
                                          Navigator.pop(
                                              context); // Close the bottom sheet
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedEventName ?? 'Seleccione un evento',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                  const EdgeInsets.all(12),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF5400DA)),
              ),
              child: const Text(
                'Scanear Codigos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snailpace/data/roleplay_data.dart';
import 'package:snailpace/data/verbose_data.dart';
import 'package:snailpace/screens/about.dart';

import 'package:snailpace/screens/privacy.dart';

//import 'package:snailpace/widgets/custom_drawer.dart';
import 'package:snailpace/widgets/landing_options.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

double myAIIQScore = 100;
double baseScore = 100;

class Landing extends StatefulWidget {
  Landing({super.key, required this.goToWidget});

  final void Function(String widgetName) goToWidget;

  @override
  State<Landing> createState() {
    // TODO: implement createState
    return _LandingState();
  }
}

class _LandingState extends State<Landing> {
  var _userSelectedRolePlay;
  var _userSelectedVerbose;

  final currentlyLoggedInUser = FirebaseAuth.instance.currentUser!;

  Future<void> getUserStats() async {
    var totalRightAnswersScore = 0;
    double totalTimeSpentScore = 0;
    double totalAssessmentPoints = 0;

    await FirebaseFirestore.instance
        .collection("quizData")
        .where('userId', isEqualTo: currentlyLoggedInUser.uid)
        .where('isCorrect', isEqualTo: 1)
        .count()
        .get()
        .then(
          (res) => totalRightAnswersScore = res.count!,
          onError: (e) => totalRightAnswersScore = 0,
        );

/*     await FirebaseFirestore.instance
        .collection("userProgressDetailData")
        .where('userId', isEqualTo: currentlyLoggedInUser.uid)
        .aggregate(sum('timeSpentForLearningPoints'))
        .get()
        .then((AggregateQuerySnapshot aggregateSnapshot) {
      totalTimeSpentScore =
          aggregateSnapshot.getSum('timeSpentForLearningPoints')!.toDouble();
    }); */

    await FirebaseFirestore.instance
        .collection("userProgressDetailData")
        .where('userId', isEqualTo: currentlyLoggedInUser.uid)
        .aggregate(sum('timeSpentForLearningPoints'))
        .get()
        .then(
          (AggregateQuerySnapshot aggregateSnapshot) => totalTimeSpentScore =
              aggregateSnapshot
                  .getSum('timeSpentForLearningPoints')!
                  .toDouble(),
          onError: (e) => totalTimeSpentScore = 0,
        );

    await FirebaseFirestore.instance
        .collection("assessmentData")
        .where('userId', isEqualTo: currentlyLoggedInUser.uid)
        .aggregate(sum('correctAnswers'))
        .get()
        .then(
          (AggregateQuerySnapshot aggregateSnapshot) => totalAssessmentPoints =
              aggregateSnapshot.getSum('correctAnswers')!.toDouble(),
          onError: (e) => totalAssessmentPoints = 0,
        );

    myAIIQScore = baseScore +
        totalRightAnswersScore.toDouble() +
        totalTimeSpentScore +
        totalAssessmentPoints;
  }

  Future<String> getUserSettings() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentlyLoggedInUser.uid)
        .get();

    if (userData.exists) {
      _userSelectedRolePlay = userData.data()!['roleforArticulation'] == null
          ? rolePlayList[0]
          : userData.data()!['roleforArticulation'].toString();
      _userSelectedVerbose =
          userData.data()!['verbosityforArticulation'] == null
              ? verboseList[1]
              : userData.data()!['verbosityforArticulation'].toString();
    } else {
      _userSelectedRolePlay = rolePlayList[0];
      _userSelectedVerbose = verboseList[1];
    }

    await getUserStats();

    return Future.value("Done");
  }

  @override
  Widget build(BuildContext context) {
    void onClick(String blockTitle) {
      if (blockTitle == "User Settings") {
        widget.goToWidget(blockTitle);
      } else if (blockTitle == "Guided Learning") {
        widget.goToWidget(blockTitle);
      } else if (blockTitle == "Chat on Topic") {
        widget.goToWidget(blockTitle);
      } else if (blockTitle == "Assessments") {
        widget.goToWidget(blockTitle);
      } else if (blockTitle == "About") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const About()),
        );
      } else if (blockTitle == "Privacy") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Privacy()),
        );
      }
    }

    // TODO: implement build
    return Center(
      child: Container(
        width: 500,
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('Snailpace-ai Learning')),
            actions: [
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
//                    Navigator.of(context).pop();

/*                     Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AuthScreen())); */
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).colorScheme.primary,
                  ))
            ],
          ),
          //drawer: CustomDrawer(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 300,
                  width: 450,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightGreenAccent.withOpacity(0.55),
                        Colors.lightGreenAccent.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: FutureBuilder(
                    future: getUserSettings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          !snapshot.hasError) {
                        return Column(
                          children: [
                            Expanded(
                              child: SfRadialGauge(
                                  title: GaugeTitle(
                                      text: 'Your AiIQ Score',
                                      textStyle: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold)),
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                        minimum: 0,
                                        maximum: 9000,
                                        ranges: <GaugeRange>[
                                          GaugeRange(
                                              startValue: 0,
                                              endValue: 1500,
                                              color: Colors.pink,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 1500,
                                              endValue: 3000,
                                              color: Colors.black,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 3000,
                                              endValue: 4500,
                                              color: Colors.red,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 4500,
                                              endValue: 6000,
                                              color: Colors.blue,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 6000,
                                              endValue: 7500,
                                              color: Colors.amber,
                                              startWidth: 10,
                                              endWidth: 10),
                                          GaugeRange(
                                              startValue: 7500,
                                              endValue: 9000,
                                              color: Colors.green,
                                              startWidth: 10,
                                              endWidth: 10)
                                        ],
                                        pointers: <GaugePointer>[
                                          NeedlePointer(value: myAIIQScore)
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                              widget: Container(
                                                  child: Text("$myAIIQScore",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              angle: 90,
                                              positionFactor: 0.5)
                                        ])
                                  ]),
                            ),
                            const Text(
                              'My current configured settings',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                            Text(
                              "Explain any concept ASSUMING I am $_userSelectedRolePlay in $_userSelectedVerbose, Change your settings through User Settings",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                              softWrap: true,
                            ),
/*                             const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Your AiIQ',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ), */
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'My current configured settings',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Explain any concept ASSUMING I am $_userSelectedRolePlay in $_userSelectedVerbose, Change your settings through User Settings",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                              softWrap: true,
                            ),
                          ],
                        );
                      } else {
                        return const Column(
                          children: [
                            Text(
                              'Loading Your settings from database...',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                              softWrap: true,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              height: 100,
                              width: 100,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                backgroundColor: Colors.amber,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: GridView(
                    padding: EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    children: [
                      LandingOptions(
                        blockTitle: "About",
                        blockColor: Colors.orange,
                        iconClass: Icons.abc,
                        onBlockTap: () {
                          onClick("About");
                        },
                      ),
                      LandingOptions(
                        blockTitle: "User Settings",
                        blockColor: Colors.amber,
                        iconClass: Icons.settings,
                        onBlockTap: () {
                          onClick("User Settings");
                        },
                      ),
                      LandingOptions(
                          blockTitle: "Privacy",
                          blockColor: Colors.lightGreenAccent,
                          iconClass: Icons.privacy_tip_sharp,
                          onBlockTap: () {
                            onClick("Privacy");
                          }),
                      LandingOptions(
                        blockTitle: "Guided Learning",
                        blockColor: Colors.redAccent,
                        iconClass: Icons.directions_sharp,
                        onBlockTap: () {
                          onClick("Guided Learning");
                        },
                      ),
                      LandingOptions(
                          blockTitle: "Chat on Topic",
                          blockColor: Colors.pinkAccent,
                          iconClass: Icons.chat_bubble_outline_sharp,
                          onBlockTap: () {
                            onClick("Chat on Topic");
                          }),
                      LandingOptions(
                          blockTitle: "Assessments",
                          blockColor: const Color.fromARGB(255, 182, 225, 134),
                          iconClass: Icons.question_mark_sharp,
                          onBlockTap: () {
                            onClick("Assessments");
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snailpace/screens/assess.dart';
import 'package:snailpace/screens/assessment.dart';
import 'package:snailpace/screens/auth.dart';
import 'package:snailpace/screens/chat.dart';
import 'package:snailpace/screens/guided_navigation.dart';
import 'package:snailpace/screens/home.dart';
import 'package:snailpace/screens/landing.dart';
import 'package:snailpace/screens/user_settings.dart';

class MasterScreen extends StatefulWidget {
  @override
  State<MasterScreen> createState() {
    // TODO: implement createState
    return _MasterScreenState();
  }
}

class _MasterScreenState extends State<MasterScreen> {
  String widgetName = "Landing";
  void goToWidget(String pwidgetName) {
    widgetName = pwidgetName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Center(
      child: widgetName == "Guided Learning"
          ? GuidedNavigation(
              goToWidget: goToWidget) //Home(goToWidget: goToWidget)
          : (widgetName == "Landing"
              ? Landing(goToWidget: goToWidget)
              : (widgetName == "Chat on Topic"
                  ? ChatScreen(goToWidget: goToWidget)
                  : (widgetName == "User Settings"
                      ? UserSettings(goToWidget: goToWidget)
                      : (widgetName == "Assessments"
                          ? Assess(
                              goToWidget:
                                  goToWidget) //Assessment(goToWidget: goToWidget)
                          : AuthScreen())))),
    );
  }
}

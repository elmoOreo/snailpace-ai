import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snailpace/data/roleplay_data.dart';
import 'package:snailpace/data/user_session_data.dart';
import 'package:snailpace/data/verbose_data.dart';
import 'package:snailpace/widgets/custom_dropdown_filter.dart';

final _userSettingsForm = GlobalKey<FormState>();
var _userSelectedRolePlay;
var _userSelectedVerbose;

class UserSettings extends StatelessWidget {
  UserSettings({super.key});

  final currentlyLoggedInUser = FirebaseAuth.instance.currentUser!;

  Future<String> saveUserSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentlyLoggedInUser.uid)
          .update({
        'roleforArticulation': _userSelectedRolePlay,
        'verbosityforArticulation': _userSelectedVerbose,
      });
    } catch (error) {
      return Future.value("Error");
    }

    userSessionDataValue["roleforArticulation"] = _userSelectedRolePlay;
    userSessionDataValue["verbosityforArticulation"] = _userSelectedVerbose;

    return Future.value("Done");
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

    return Future.value("Done");
  }

  @override
  Widget build(BuildContext context) {
    final _heightOfScreen = MediaQuery.of(context).size.height;

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
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).colorScheme.primary,
                  ))
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Center(
            child: SizedBox(
              height: _heightOfScreen, // 800,
              width: 500, //_widthOfScreen,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FutureBuilder(
                      future: getUserSettings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            !snapshot.hasError) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'My Settings',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomDropdownFilter(
                                dropDownTitle: 'Selected Role',
                                dropDownData: rolePlayList,
                                defaultValue: _userSelectedRolePlay,
                                onSelectionOfOption: (selectedOption) {
                                  _userSelectedRolePlay = selectedOption;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomDropdownFilter(
                                dropDownTitle: 'Articulate',
                                dropDownData: verboseList,
                                defaultValue: _userSelectedVerbose,
                                onSelectionOfOption: (selectedOption) {
                                  _userSelectedVerbose = selectedOption;
                                },
                              )
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'My Settings',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomDropdownFilter(
                                dropDownTitle: 'Selected Role',
                                dropDownData: rolePlayList,
                                defaultValue: rolePlayList[0],
                                onSelectionOfOption: (selectedOption) {
                                  _userSelectedRolePlay = selectedOption;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomDropdownFilter(
                                dropDownTitle: 'Articulate',
                                dropDownData: verboseList,
                                defaultValue: verboseList[0],
                                onSelectionOfOption: (selectedOption) {
                                  _userSelectedVerbose = selectedOption;
                                },
                              )
                            ],
                          );
                        } else {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Loading Data from database',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ElevatedButton.icon(
                      label: const Text('Save User Settings'),
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        saveUserSettings();
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

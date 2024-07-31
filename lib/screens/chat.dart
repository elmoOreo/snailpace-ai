//import 'package:dropdown_search/dropdown_search.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:snailpace/data/roleplay_data.dart';

import 'package:snailpace/data/topic_data.dart';
import 'package:snailpace/data/verbose_data.dart';
import 'package:snailpace/screens/landing.dart';
import 'package:snailpace/widgets/chat_filter.dart';
import 'package:snailpace/widgets/chat_nuggets.dart';
/* import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart'; */

var _firstloadedDateTime = DateTime.now();
var _nextloadedDateTime = DateTime.now();
String _selectedTopicForDiscussion = "";

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.goToWidget});

  final void Function(String widgetName) goToWidget;

  @override
  State<ChatScreen> createState() {
    // TODO: implement createState
    return _ChatScreenState();
  }
}

List<Content> chatList = [];
var userChatShowList = [];
var modelChatShowList = [];
List<List<dynamic>> modelChatSourceList = [];
var currentSelectedItem;
var conceptArticulation = null;
var userQuery = null;
var linkCount;
bool processInExecution = false;
var selectedTopicForDiscussion;

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController queryFromUser = TextEditingController();
  final currentlyLoggedInUser = FirebaseAuth.instance.currentUser!;

  Future<void> getInitialPrompt(String topicOfDiscussion) async {
    var rolePlaySelected;
    var verboseSelected;

    chatList.clear();
    final userSettingsData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentlyLoggedInUser.uid)
        .get();

    if (userSettingsData.exists) {
      rolePlaySelected = userSettingsData.data()!['roleforArticulation'] == null
          ? rolePlayList[0]
          : userSettingsData.data()!['roleforArticulation'].toString();
      verboseSelected =
          userSettingsData.data()!['verbosityforArticulation'] == null
              ? verboseList[1]
              : userSettingsData.data()!['verbosityforArticulation'].toString();
    } else {
      rolePlaySelected = rolePlayList[0];
      verboseSelected = verboseList[1];
    }

    final currentPrompt = '''
        You are an AI Guru and an expert in articulating complex concepts on AI in simpler terms. 

        Please do not hallucinate, if you are not aware, please say it so in courteous fashion.

        The following will be your task
        1) Imagine you have to engage in an informed conversation on this particular concept $topicOfDiscussion in the context AI. Assume your audience is $rolePlaySelected. If there are questions not relevant to topic of discussion $topicOfDiscussion, please let the User know in a courteous manner that its beyond the current scope of discussion.
        2) You will be prompted with a Question from the end User
        3) You will respond to the Question to the best of your knowledge and limit your responses to $verboseSelected 
        4) For the response in Step 3 enclose all the source of information as a list

        Question:
        Response:
        Sources:

        Return the results in the format below and ensure JSON is valid. 
          "{
            "Response": str
            "Sources": []
          }"
    ''';

    chatList.add(Content.model([TextPart(currentPrompt)]));
  }

  Future<String> getPromptCompletionForChat(String chatString) async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var jsonDataReturned;
    var allSources = [];

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.0));

    final chat = model.startChat(history: chatList);

    content = Content.text(
        "The topic of dicussion is $selectedTopicForDiscussion. If the following question is not relevant to the topic, please let the User know in a courteous manner and also suggest any questions that User may want to seek information on the topic of discussion which is $selectedTopicForDiscussion.  Question: $chatString");

    try {
      response = await chat.sendMessage(content);
      ;
    } catch (error) {
      return Future.value(error.toString());
    }

    dataString = response.text.toString();
    dataString = dataString.replaceAll("```", "");
    dataString = dataString.replaceAll("json", "");

    jsonDataReturned = json.decode(dataString);

    conceptArticulation = jsonDataReturned["Response"];

    modelChatShowList.add(conceptArticulation);

    chatList.add(Content.model([TextPart("Response:")]));
    chatList.add(Content.model([TextPart(conceptArticulation)]));

    chatList.add(Content.model([TextPart("Sources:")]));
    allSources.clear();
    for (int outLoop = 0;
        outLoop < jsonDataReturned["Sources"].length;
        outLoop++) {
      allSources.add(jsonDataReturned["Sources"][outLoop].toString().trim());
      chatList.add(Content.model(
          [TextPart(jsonDataReturned["Sources"][outLoop].toString().trim())]));
    }

    modelChatSourceList.add(allSources);

    return Future.value("Done");
  }

  void getInitialCompletion(String selectedItem) async {
    _firstloadedDateTime = DateTime.now();
    setState(() {});
    userChatShowList.clear();
    modelChatShowList.clear();
    modelChatSourceList.clear();
    selectedTopicForDiscussion = selectedItem;
    await getInitialPrompt(selectedItem);
    userQuery = "Explain the concept of $selectedItem";
    userChatShowList.add(userQuery);
    await getPromptCompletionForChat(userQuery);

    setState(() {
      processInExecution = false;
    });
  }

  void askSnail(String userQuery) async {
    setState(() {});

    userChatShowList.add(userQuery);
    queryFromUser.text = "";

    await getPromptCompletionForChat(userQuery);

    setState(() {
      processInExecution = false;
    });
    _nextloadedDateTime = DateTime.now();
    logUserProgressData();
    _firstloadedDateTime = DateTime.now();
  }

  void logUserProgressData() async {
    double timeSpentForLearningPoints = 0;

    // Assuming no content exceeds 120/5 seconds of learning.

    timeSpentForLearningPoints =
        _nextloadedDateTime.difference(_firstloadedDateTime).inSeconds.abs() /
            5;

    final userProgressDetailData = <String, dynamic>{
      "userId": currentlyLoggedInUser.uid,
      "currentNugget": topics[0]
          .subTopics
          .indexOf(selectedTopicForDiscussion.toString().trim()),
      "currentNuggetItem": selectedTopicForDiscussion.toString().trim(),
      "startedAt": _firstloadedDateTime,
      "finishedAt": _nextloadedDateTime,
      "timeSpent":
          _nextloadedDateTime.difference(_firstloadedDateTime).inSeconds.abs(),
      "timeSpentForLearningPoints":
          timeSpentForLearningPoints > 24 ? 24 : timeSpentForLearningPoints,
      "type": "Chat"
    };

    await FirebaseFirestore.instance
        .collection('userProgressDetailData')
        .add(userProgressDetailData);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final _heightOfScreen = MediaQuery.of(context).size.height;
    var dataCount = userChatShowList.length;

    // TODO: implement build
    return
/*     Center(
      child:  */
        Container(
      width: 500,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Snailpace-ai Learning')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to the previous screen by popping the current route
              //Navigator.pop(context);

              widget.goToWidget("Landing");

              //Navigator.of(context).popUntil((route) => route.isFirst);
/* 
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Landing())); */
/*                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Landing()),
                ); */
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  widget.goToWidget("AuthScreen");
                  //Navigator.of(context, rootNavigator: true).pop(context);
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.primary,
                ))
          ],
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .primary, //Color.fromARGB(255, 154, 212, 242),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ChatFilter(
                    selectedTopicForDiscussion: _selectedTopicForDiscussion ==
                            "null"
                        ? ""
                        : _selectedTopicForDiscussion, //topics[0].subTopics[0],
                    getInitialCompletion: (item) {
                      _selectedTopicForDiscussion = item;
                      processInExecution = true;
                      setState(() {});
                      getInitialCompletion(item);
                    },
                    topicForSelection: topics[0].subTopics,
                    askSnail: (queryFromUser) {
                      processInExecution = true;
                      setState(() {});
                      askSnail(queryFromUser);
                    }),
                /* SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 500,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/snailpace_logo_alt_2.png',
                        height: 100,
                      ),
                      DropdownMenu<String>(
                        enableFilter: true,
                        enableSearch: true,
                        leadingIcon: const Icon(Icons.search),
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                        ),
                        controller: itemController,
                        requestFocusOnTap: true,
                        label: const Text('Select a topic for chat'),
                        onSelected: (item) {
                          processInExecution = true;
                          selectedTopicForDiscussion = item;
                          getInitialCompletion(item!);
                        },
                        dropdownMenuEntries: topics[0]
                            .subTopics
                            .map<DropdownMenuEntry<String>>((String item) {
                          return DropdownMenuEntry<String>(
                            value: item,
                            label: item,
                            style: MenuItemButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 500,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          controller: queryFromUser,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 0.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 0.0),
                            ),
                            labelText: 'AskSnail',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            processInExecution = true;
                            askSnail(queryFromUser.text);
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ))
                    ],
                  ),
                ), */
                if (processInExecution)
                  const SizedBox(
                    height: 100,
                    width: 100,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.amber,
                    ),
                  ),
                if (!processInExecution)
                  ChatNuggets(
                      dataCountNuggets: dataCount,
                      userChatShowList: userChatShowList,
                      modelChatShowList: modelChatShowList,
                      modelChatSourceList: modelChatSourceList),
                /* SingleChildScrollView(
                      child: Column(
                        children: [
                          ...userChatShowList.map((item) {
                            dataCount--;
                            linkCount = 0;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 500,
                                  child: Row(
                                    children: [
                                      Card(
                                          elevation: 50,
                                          shadowColor: Colors.black,
                                          color: Colors.amberAccent[100],
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text(
                                              userChatShowList[dataCount],
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          )),
                                      const Expanded(
                                        child: SizedBox(
                                          width: 50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: Card(
                                      elevation: 50,
                                      shadowColor: Colors.black,
                                      color: Colors.greenAccent[200],
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                            modelChatShowList[dataCount],
                                            style: TextStyle(fontSize: 15)),
                                      )),
                                ),
                                ...modelChatSourceList[dataCount].map((item) {
                                  linkCount++;
                                  return SizedBox(
                                    width: 500,
                                    child: Card(
                                      elevation: 50,
                                      shadowColor: Colors.black,
                                      color: Colors.greenAccent[300],
                                      child: InkWell(
                                        onTap: () => isURL(item)
                                            ? launchUrl(Uri.parse(item))
                                            : () {},
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            isURL(item)
                                                ? "Source Link $linkCount : : $item"
                                                : item,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                              ],
                            );
                          })
                        ],
                      ),
                    ), */
              ],
            ),
          ),
        ),
      ),
    );
    //);
  }
}

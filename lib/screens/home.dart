import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:snailpace/screens/landing.dart';
/* import 'package:snailpace/screens/chat.dart';
import 'package:snailpace/screens/user_settings.dart';
import 'package:snailpace/widgets/custom_drawer.dart'; */
import 'package:snailpace/widgets/nuggets.dart';
import 'package:snailpace/data/topic_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'dart:convert';
import 'package:snailpace/widgets/quiz_nuggets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:syncfusion_flutter_gauges/gauges.dart';

var _currentNuggetItem = 0;
var _currentItem = "in-process";
var _currentSelectionToShow = 0;
final randomizer = Random();
var _currentTriviaSelection = "Loading...";
var jsonDataReturned;
List<String> allOptions = [];
bool columnarView = true;
List<String> allSources = [];
var _firstloadedDateTime = DateTime.now();
var _nextloadedDateTime = DateTime.now();

var conceptArticulation;

class Home extends StatefulWidget {
  const Home({super.key, required this.goToWidget});

  final void Function(String widgetName) goToWidget;

  @override
  State<Home> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final currentlyLoggedInUser = FirebaseAuth.instance.currentUser!;
  final totalNumberOfNuggets = topics[0].subTopics.length;

  var triviaTopicList = [
    'Statistics',
    'Machine Learning',
    'Deep Learning',
    'Artificial Intelligence',
    'Generative AI',
    'Supervised Learning',
    'Unsupervised Learning',
    'Clustering',
    'Probability',
    'Conditional Probability',
    'Inferential Statistics',
    'Probabilistic Distributions',
    'Regression',
    'Classification',
    'Machine Learning Evaluation Metrics',
    'p-Value',
    'Hypothesis Testing'
  ];

  var rolePlayList = [
    'a School Going Kid',
    'a Technologist',
    'a Business Analyst',
    'a Business Head',
    'a Sales Head',
    'a CEO',
    'a CMO',
    'a CFO',
    'a CTO',
    'a CISO',
    'a CIO',
  ];
  String rolePlaySelected = "Loading...";

  var verboseList = [
    'less than 100 words',
    'less than 250 words',
    'less than 500 words'
  ];
  String verboseSelected = "Loading...";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rolePlaySelected = rolePlayList[0];
    verboseSelected = verboseList[1];
    _firstloadedDateTime = DateTime.now();
  }

  void refreshTopic() {
    setState(() {
      _currentItem = "nugget";
    });
  }

  void getTheNextTopic() {
    //_currentSelectionToShow = randomizer.nextInt(3);

    if (_currentSelectionToShow == 0) {
      _currentSelectionToShow = 1;
    } else if (_currentSelectionToShow == 1) {
      _currentSelectionToShow = 2;
    } else {
      _currentSelectionToShow = 0;
    }

    setState(() {
      if (_currentSelectionToShow == 0) {
        if (_currentNuggetItem < totalNumberOfNuggets) {
          _currentNuggetItem++;
          logUserProgressData();
          _firstloadedDateTime = DateTime.now();
        }
        _currentItem = "nugget";
      } else if (_currentSelectionToShow == 1) {
        _currentItem = "trivia";
      }
    });
  }

/*   void goToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  } */

/*   void goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserSettings()),
    );
  } */

  void getThePreviousTopic() {
    _currentSelectionToShow = 0;

    setState(() {
      if (_currentSelectionToShow == 0) {
        if (_currentNuggetItem > 0) {
          _currentNuggetItem--;
        } else {
          _currentNuggetItem = 0;
        }
        _currentItem = "nugget";
        logUserProgressData();
        _firstloadedDateTime = DateTime.now();
      } else if (_currentSelectionToShow == 1) {
        _currentItem = "trivia";
      }
    });
  }

  Future<String> logUserProgressData() async {
    var returnValue = "No error";
    _nextloadedDateTime = DateTime.now();

    final userProgressData = <String, dynamic>{
      "userId": currentlyLoggedInUser.uid,
      "currentNugget": _currentNuggetItem,
      'lastUpdatedOn': Timestamp.now(),
    };

    double timeSpentForLearningPoints = 0;

    timeSpentForLearningPoints =
        _nextloadedDateTime.difference(_firstloadedDateTime).inSeconds.abs() /
            5;

    final userProgressDetailData = <String, dynamic>{
      "userId": currentlyLoggedInUser.uid,
      "currentNugget": _currentNuggetItem,
      "currentNuggetItem": topics[0].subTopics[_currentNuggetItem],
      "startedAt": _firstloadedDateTime,
      "finishedAt": _nextloadedDateTime,
      "timeSpent":
          _nextloadedDateTime.difference(_firstloadedDateTime).inSeconds.abs(),
      "timeSpentForLearningPoints":
          timeSpentForLearningPoints > 24 ? 24 : timeSpentForLearningPoints,
      "type": "GuidedLearning"
    };

    await FirebaseFirestore.instance
        .collection("userProgressData")
        .doc(currentlyLoggedInUser.uid)
        .set(userProgressData)
        .then((value) => returnValue = "Data added successfully")
        .catchError((error) => returnValue = "Failed to add data: $error");

    await FirebaseFirestore.instance
        .collection('userProgressDetailData')
        .add(userProgressDetailData);

    return (Future.value(returnValue).toString());
  }

  void logQuizData(question, choosenAnswer, correctAnswer) async {
    await FirebaseFirestore.instance.collection('quizData').add({
      'createdAt': Timestamp.now(),
      'userId': currentlyLoggedInUser.uid,
      'question': question,
      'choosenAnswer': choosenAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': choosenAnswer == correctAnswer ? 1 : 0
    });
  }

  void eventOnSelectedAnswer(
      question, choosenAnswer, correctAnswer, reasoningForTheAnswer) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: choosenAnswer == correctAnswer
            ? Colors.greenAccent[100]
            : Colors.deepOrange[100],
        insetPadding: const EdgeInsets.all(1),
        title: const Text('Quiz Result'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                ColoredBox(
                  color: Colors.lightBlueAccent,
                  child: Text(
                    'Question : $question',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Divider(
                  height: 10,
                  thickness: 2,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.black,
                ),
                Text(
                  'Choosen Answer : $choosenAnswer',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(
                  height: 10,
                  thickness: 2,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.black,
                ),
                Text(
                  'Correct Answer : $correctAnswer',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(
                  height: 10,
                  thickness: 2,
                  indent: 0,
                  endIndent: 0,
                  color: Colors.black,
                ),
                ColoredBox(
                  color: Colors.lightGreenAccent,
                  child: Text(
                    'Reasoning for the Answer : $reasoningForTheAnswer',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                )),
          ),
        ],
      ),
    );

    logQuizData(question, choosenAnswer, correctAnswer);
    getTheNextTopic();
  }

  Future<String> getAssessment() async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var randomTopicNumber;

    final userData = await FirebaseFirestore.instance
        .collection('userProgressData')
        .doc(currentlyLoggedInUser.uid)
        .get();

    if (userData.exists) {
      _currentNuggetItem =
          int.parse(userData.data()!['currentNugget'].toString());
    } else {
      _currentNuggetItem = 0;
    }

    if (_currentNuggetItem > 2) {
      randomTopicNumber = randomizer.nextInt(_currentNuggetItem);
    } else {
      randomTopicNumber = 0;
    }

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.8));

    final currentPrompt = '''
        You are an AI Guru and an expert in AI literature. 
        
        Please do not hallucinate, if you are not aware, please say it so in courteous fashion. 
        Please do not share anything that can be construed as harmful.
        You are tasked with formulating a question and set of possible answers. 

        The following will be your task in steps
        Step 1) Ask a challenging relevant question on the topic ${topics[0].subTopics[randomTopicNumber]}.
        Step 2) List the answer having a maximum length of no more than 2 words to the question in Step 1.
        Step 3) Generate 3 other similar answers having a maximum length of no more than 2 words as in Step 2. 
        Step 4) Return the answers generated in Step 2 and Step 3 as a single list.
        Step 5) Articulate in detail why the answer in Step 2 is the right answer for the question in Step 1

        Return the results in the format below and ensure JSON is valid. 
          "{
            "Question": str
            "Answer": str
            "AllOptions":[]
            "Reasoning": str
          }"
    ''';

    content = [Content.text(currentPrompt)];

    try {
      response = await model.generateContent(content);
    } catch (error) {
      return Future.value(error.toString());
    }

    dataString = response.text.toString();
    dataString = dataString.replaceAll("```", "");
    dataString = dataString.replaceAll("json", "");

    jsonDataReturned = json.decode(dataString);

    allOptions.clear();
    for (int outLoop = 0;
        outLoop < jsonDataReturned["AllOptions"].length;
        outLoop++) {
      allOptions.add(jsonDataReturned["AllOptions"][outLoop]);
    }
    allOptions.shuffle();

    return Future.value("Done");
  }

  Future<String> getRandomTriviaOnAI() async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var jsonDataReturned;

    final randomTriviaNumber = randomizer.nextInt(triviaTopicList.length);

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.8));

    final currentPrompt = '''
        You are an AI Guru and an expert in AI literature. 

        Please do not hallucinate, if you are not aware, please say it so in courteous fashion. 
        Please do not share anything that can be construed as biased or harmful.

        The following will be your task in steps
        Step 1) Share any present or historical random trivia on ${triviaTopicList[randomTriviaNumber]} and its real time applications
        Step 2) For the information that was gathered as part of step 1 enclose all the source of information as a list

        Return the results in the format below and ensure JSON is valid. 
          "{
            "Trivia": str
            "Sources": []
          }"
    ''';
    content = [Content.text(currentPrompt)];

    try {
      response = await model.generateContent(content);
    } catch (error) {
      return Future.value(error.toString());
    }

    dataString = response.text.toString();
    dataString = dataString.replaceAll("```", "");
    dataString = dataString.replaceAll("json", "");

    jsonDataReturned = json.decode(dataString);

    conceptArticulation = jsonDataReturned["Trivia"];

    allSources.clear();
    for (int outLoop = 0;
        outLoop < jsonDataReturned["Sources"].length;
        outLoop++) {
      allSources.add(jsonDataReturned["Sources"][outLoop].toString().trim());
    }

    return Future.value("Done");
  }

  Future<String> getPromptCompletion() async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var jsonDataReturned;

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

    final userData = await FirebaseFirestore.instance
        .collection('userProgressData')
        .doc(currentlyLoggedInUser.uid)
        .get();

    if (userData.exists) {
      _currentNuggetItem =
          int.parse(userData.data()!['currentNugget'].toString());
    } else {
      _currentNuggetItem = 0;
    }

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.0));

    final currentPrompt = '''
        You are an AI Guru and an expert in articulating complex concepts on AI in simpler terms. 

        Please do not hallucinate, if you are not aware, please say it so in courteous fashion.

        The following will be your task in steps
        Step 1) Imagine you have to explain the concept of ${topics[0].subTopics[_currentNuggetItem]} in $verboseSelected to $rolePlaySelected. 
        Step 2) For the information that was gathered as part of step 1 enclose all the source of information as a list

        Return the results in the format below and ensure JSON is valid. 
          "{
            "ExplainationOfConcept": str
            "Sources": []
          }"
    ''';

    content = [Content.text(currentPrompt)];

    try {
      response = await model.generateContent(content);
    } catch (error) {
      return Future.value(error.toString());
    }

    dataString = response.text.toString();
    dataString = dataString.replaceAll("```", "");
    dataString = dataString.replaceAll("json", "");

    jsonDataReturned = json.decode(dataString);

    conceptArticulation = jsonDataReturned["ExplainationOfConcept"];

    allSources.clear();
    for (int outLoop = 0;
        outLoop < jsonDataReturned["Sources"].length;
        outLoop++) {
      allSources.add(jsonDataReturned["Sources"][outLoop].toString().trim());
    }

    _currentItem = "nugget";

    return Future.value("Done");
  }

  @override
  Widget build(BuildContext context) {
    final _heightOfScreen = MediaQuery.of(context).size.height;

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
              widget.goToWidget("Landing");
              //Navigator.pop(context);

/*                 Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Landing())); */
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  widget.goToWidget("AuthScreen");

                  //Navigator.of(context, rootNavigator: true).pop(context);
                  //Navigator.of(context).pop(context);
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
          child: SizedBox(
            height: _heightOfScreen, // 800,
            width: 500, //_widthOfScreen,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
/*                         const SizedBox(
                          width: 10,
                        ),
                        FloatingActionButton(
                          heroTag: "refreshTopic",
                          onPressed: refreshTopic,
                          child: const Icon(Icons.refresh),
                        ), */
/*                         const SizedBox(
                          width: 10,
                        ), */
                      FloatingActionButton(
                        heroTag: "getThePreviousTopic",
                        onPressed: getThePreviousTopic,
                        child: const Icon(Icons.skip_previous_rounded),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Image.asset(
                        'assets/images/snailpace_logo_alt_2.png',
                        height: 80,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      FloatingActionButton(
                        heroTag: "getTheNextTopic",
                        onPressed: getTheNextTopic,
                        child: const Icon(
                          Icons.skip_next_rounded,
                        ),
                      ),
/*                         const SizedBox(
                          width: 5,
                        ), */
/*                         FloatingActionButton(
                          heroTag: "goToSettings",
                          onPressed: goToSettings,
                          child: const Icon(
                            Icons.settings,
                          ),
                        ), */
/*                         const SizedBox(
                          width: 5,
                        ), */
/*                         FloatingActionButton(
                          heroTag: "goToChat",
                          onPressed: goToChat,
                          child: const Icon(
                            Icons.chat_sharp,
                          ),
                        ), */
                    ],
                  ),
                  FutureBuilder(
                    future: _currentSelectionToShow == 0
                        ? getPromptCompletion()
                        : (_currentSelectionToShow == 1
                            ? getRandomTriviaOnAI()
                            : getAssessment()),
                    initialData:
                        "Gemini API is working on the request, please wait",
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          !snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /* Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/snailpace_logo_alt_2.png',
                                    height: 100,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "refreshTopic",
                                    onPressed: refreshTopic,
                                    child: const Icon(Icons.refresh),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "getThePreviousTopic",
                                    onPressed: getThePreviousTopic,
                                    child:
                                        const Icon(Icons.skip_previous_rounded),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "getTheNextTopic",
                                    onPressed: getTheNextTopic,
                                    child: const Icon(
                                      Icons.skip_next_rounded,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "accessTheSettings",
                                    onPressed: goToSettings,
                                    child: const Icon(
                                      Icons.settings,
                                    ),
                                  ),
                                ],
                              ), */
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Nugget : ${_currentNuggetItem + 1} of $totalNumberOfNuggets",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                            if (_currentSelectionToShow <= 1)
                              Nuggets(
                                titleData: _currentSelectionToShow == 0
                                    ? topics[0].subTopics[_currentNuggetItem]
                                    : "Random Trivia on A.I.",
                                descriptionData:
                                    conceptArticulation, //snapshot.data!,
                                sources: allSources,
                                nuggetType: _currentItem,
                                userSelectedRole: rolePlaySelected,
                                userSelectedVerbosity: verboseSelected,
                              ),
                            if (_currentSelectionToShow == 2)
                              QuizNuggets(
                                question:
                                    "${jsonDataReturned["Question"].toString()}, choose the most appropriate option",
                                answerOptions: allOptions,
                                correctAnswer:
                                    jsonDataReturned["Answer"].toString(),
                                reasoningForTheAnswer:
                                    jsonDataReturned["Reasoning"].toString(),
                                onSelectAnswer: (question, choosenAnswer,
                                    correctAnswer, reasoningForTheAnswer) {
                                  eventOnSelectedAnswer(question, choosenAnswer,
                                      correctAnswer, reasoningForTheAnswer);
                                },
                              ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /* Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/snailpace_logo_alt_2.png',
                                    height: 100,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "refreshTopic",
                                    onPressed: refreshTopic,
                                    child: const Icon(Icons.refresh),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "getThePreviousTopic",
                                    onPressed: getThePreviousTopic,
                                    child:
                                        const Icon(Icons.skip_previous_rounded),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "getTheNextTopic",
                                    onPressed: getTheNextTopic,
                                    child: const Icon(
                                      Icons.skip_next_rounded,
                                    ),
                                  ),
                                ],
                              ), */
                            Nuggets(
                              titleData:
                                  topics[0].subTopics[_currentNuggetItem],
                              descriptionData:
                                  '''Error fetching data from Gemini API, ${snapshot.data}. There was an unexpected error. Please use one of the navigation buttons to either referesh or move forward.''',
                              sources: [],
                              userSelectedRole: "",
                              userSelectedVerbosity: "",
                              nuggetType: "error",
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /* Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/snailpace_logo_alt_2.png',
                                    height: 100,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "refreshTopic",
                                    onPressed: refreshTopic,
                                    child: const Icon(Icons.refresh),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "getThePreviousTopic",
                                    onPressed: getThePreviousTopic,
                                    child:
                                        const Icon(Icons.skip_previous_rounded),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  FloatingActionButton(
                                    heroTag: "getTheNextTopic",
                                    onPressed: getTheNextTopic,
                                    child: const Icon(
                                      Icons.skip_next_rounded,
                                    ),
                                  ),
                                ],
                              ), */
                            Nuggets(
                              titleData:
                                  topics[0].subTopics[_currentNuggetItem],
                              descriptionData:
                                  "Gemini API is processing your request, please wait......",
                              sources: [],
                              nuggetType: "in-process",
                              userSelectedRole: "",
                              userSelectedVerbosity: "",
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    //);
    // Row View
  }
}

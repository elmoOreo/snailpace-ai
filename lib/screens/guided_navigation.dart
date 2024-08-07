import 'package:flutter/material.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:snailpace/widgets/custom_dialog.dart';
//import 'package:firebase_vertexai/firebase_vertexai.dart';

import 'package:snailpace/widgets/nuggets.dart';
import 'package:snailpace/data/topic_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'dart:convert';
import 'package:snailpace/widgets/quiz_nuggets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snailpace/widgets/quiz_nuggets_notes.dart';

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
String conceptBasedQuestion = "";
String answerToConceptBasedQuestion = "";
var isConceptSame;
var reasoningBehindTheConcept;

var conceptArticulation;
bool processInExecution = false;
double degreeOfSimilarity = 0.0;

typedef Future<T> FutureGenerator<T>();

class GuidedNavigation extends StatefulWidget {
  const GuidedNavigation({super.key, required this.goToWidget});

  final void Function(String widgetName) goToWidget;

  @override
  State<GuidedNavigation> createState() {
    // TODO: implement createState
    return _GuidedNavigationState();
  }
}

class _GuidedNavigationState extends State<GuidedNavigation> {
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
    processInExecution = true;
    _currentSelectionToShow = 0;
  }

  void refreshTopic() {
    processInExecution = true;

    setState(() {
      _currentItem = "nugget";
    });
  }

  void getTheNextTopic() {
    processInExecution = true;
    if (_currentSelectionToShow == 0) {
      _currentSelectionToShow = 1;
    } else if (_currentSelectionToShow == 1) {
      _currentSelectionToShow = 2;
    } else if (_currentSelectionToShow == 2) {
      _currentSelectionToShow = 3;
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
      } else if (_currentSelectionToShow == 2) {
        _currentItem = "multichoice-quiz";
      } else if (_currentSelectionToShow == 3) {
        _currentItem = "concept-quiz";
      }
    });
  }

  void getThePreviousTopic() {
    processInExecution = true;
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

  void logQuizData(question, choosenAnswer, correctAnswer,
      reasoningForTheAnswer, conceptEval) async {
    await FirebaseFirestore.instance.collection('quizData').add({
      'createdAt': Timestamp.now(),
      'userId': currentlyLoggedInUser.uid,
      'question': question,
      'choosenAnswer': choosenAnswer,
      'correctAnswer': correctAnswer,
      'reasoningForTheAnswer': reasoningForTheAnswer,
      'isCorrect': conceptEval
          ? degreeOfSimilarity
          : (choosenAnswer == correctAnswer ? 1 : 0),
      'typeOfQuiz': conceptEval ? "concept-quiz" : "multichoice-quiz"
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
        content: CustomDialog(
            question: question,
            choosenAnswer: choosenAnswer,
            correctAnswer: correctAnswer,
            degreeOfSimilarity: "",
            reasoningForTheAnswer: reasoningForTheAnswer),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                )),
          ),
        ],
      ),
    );

    logQuizData(
        question, choosenAnswer, correctAnswer, reasoningForTheAnswer, false);
    getTheNextTopic();
  }

  Future<String> retry<T>(int retries, FutureGenerator aFuture) async {
    try {
      return await aFuture();
    } catch (e) {
      if (retries > 1) {
        //print("retrying $retries");
        return retry(retries - 1, aFuture);
      }

      rethrow;
    }
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

    randomTopicNumber = _currentNuggetItem;

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.8));

/*     final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(temperature: 0.8)); */

    final currentPrompt = '''
        You are an AI Guru and an expert in AI literature. 
        
        Please do not hallucinate, if you are not aware, please say it so in courteous fashion. 
        Please do not share anything that can be construed as harmful.
        You are tasked with formulating a question and set of possible answers. 

        The following will be your task in steps
        Step 1) Ask a relevant question to $rolePlaySelected on the topic ${topics[0].subTopics[randomTopicNumber]}.
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

    processInExecution = false;
    setState(() {});

    return Future.value("Done");
  }

  void eventClickedToCheckAnswer(conceptBasedQuestion,
      answerToConceptBasedQuestion, answerSubmittedByTheUser) async {
    await checkTheAssessmentOnConcept(conceptBasedQuestion,
        answerToConceptBasedQuestion, answerSubmittedByTheUser);

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: isConceptSame == "true"
            ? Colors.greenAccent[100]
            : Colors.deepOrange[100],
        insetPadding: const EdgeInsets.all(1),
        title: const Text('Quiz Assessment Concept Result'),
        content: CustomDialog(
            question: conceptBasedQuestion,
            choosenAnswer: answerSubmittedByTheUser,
            correctAnswer: answerToConceptBasedQuestion,
            degreeOfSimilarity:
                '${(degreeOfSimilarity.toDouble() * 100).toString()} %',
            reasoningForTheAnswer: reasoningBehindTheConcept),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                )),
          ),
        ],
      ),
    );

    logQuizData(conceptBasedQuestion, answerSubmittedByTheUser,
        answerToConceptBasedQuestion, reasoningBehindTheConcept, true);
    getTheNextTopic();
  }

  Future<String> checkTheAssessmentOnConcept(
      String conceptBasedQuestion,
      String answerToConceptBasedQuestion,
      String answerSubmittedByTheUser) async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.0));

    final currentPrompt = '''
        You are an AI Guru and an expert in AI literature. 
        
        Please do not hallucinate, if you are not aware, please say it so in courteous fashion. 
        Please do not share anything that can be construed as harmful.
        You are tasked with checking the answer submitted by the User against the actual answer
        The data is delimited by ###

        The following is the sequence of steps
        Step 1) The following is the question ### $conceptBasedQuestion ###
        Step 2) The following is the actual answer  ### $answerToConceptBasedQuestion ### to the question posed in Step 1
        Step 3) The following is the answer submitted by the User ### $answerSubmittedByTheUser ###
        Step 4) Compare the answer in Step 2 and Step 3 from a conceptual perspective and check if they are conceptually the same.
        Step 5) If in Step 4 they are conceptually the same then return the result isConceptSame as true else false 
        Step 6) If in Step 4 they are conceptually the same then return the result degreeOfSimilarity, a score between 0 and 1, 0 being dissimilar, 1 being very similar and anywhere between 0 and 1 is somewhat similar
        Step 7) If in Step 4 they are conceptually the same or different then return the result reasoningBehindTheConcept as to why they are same or different
        
        Return the results in the format below and ensure JSON is valid. 
          "{
            "isConceptSame": bool
            "degreeOfSimilarity": double
            "reasoningBehindTheConcept": str
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

    isConceptSame = jsonDataReturned["isConceptSame"];

    try {
      degreeOfSimilarity = double.parse(
          jsonDataReturned["degreeOfSimilarity"].toString().trim());
    } catch (err) {
      degreeOfSimilarity = 0.0;
    }

    reasoningBehindTheConcept = jsonDataReturned["reasoningBehindTheConcept"];

    return Future.value("Done");
  }

  Future<String> getAssessmentOnConcept() async {
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

    randomTopicNumber = _currentNuggetItem;

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.8));

/*     final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(temperature: 0.8)); */

    final currentPrompt = '''
        You are an AI Guru and an expert in AI literature. 
        
        Please do not hallucinate, if you are not aware, please say it so in courteous fashion. 
        Please do not share anything that can be construed as harmful.
        You are tasked with formulating a question and also articulate the answer to the question. 

        The following will be your task in steps
        Step 1) Assuming you need to ask the question to a $rolePlaySelected. 
        Step 2) Ask a simple relevant question on the topic ${topics[0].subTopics[randomTopicNumber]} which the User needs to detail it out in note more than 5 lines.
        Step 3) Detail the answer to the question in Step 2.

        Return the results in the format below and ensure JSON is valid. 
          "{
            "conceptBasedQuestion": str
            "answerToConceptBasedQuestion": str
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

    //print(jsonDataReturned);

    conceptBasedQuestion = jsonDataReturned["conceptBasedQuestion"];
    answerToConceptBasedQuestion =
        jsonDataReturned["answerToConceptBasedQuestion"];

    processInExecution = false;
    setState(() {});

    return Future.value("Done");
  }

  Future<String> getRandomTriviaOnAI() async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var jsonDataReturned;

    final randomTriviaNumber = randomizer.nextInt(topics.length);

    // final randomTriviaNumber = randomizer.nextInt(triviaTopicList.length);

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(temperature: 0.8));

/*     final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(temperature: 0.8));
 */
    final currentPrompt = '''
        You are an AI Guru and an expert in AI literature. 

        Please do not hallucinate, if you are not aware, please say it so in courteous fashion. 
        Please do not share anything that can be construed as biased or harmful.

        The following will be your task in steps
        Step 1) Assuming your audience is $rolePlaySelected. 
        Step 2) Share any present or historical random trivia on ${triviaTopicList[randomTriviaNumber]} and its real time applications
        Step 3) For the information that was gathered as part of step 1 enclose all the source of information as a list

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

    processInExecution = false;
    setState(() {});

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
      rolePlaySelected = userSettingsData.data()!['roleforArticulation'] != null
          ? userSettingsData.data()!['roleforArticulation'].toString()
          : rolePlayList[0];
      verboseSelected =
          userSettingsData.data()!['verbosityforArticulation'] != null
              ? userSettingsData.data()!['verbosityforArticulation'].toString()
              : verboseList[1];
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

/*     final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(temperature: 0.0)); */

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

    processInExecution = false;
    setState(() {});

    return Future.value("Done");
  }

  @override
  Widget build(BuildContext context) {
    final heightOfScreen = MediaQuery.of(context).size.height;

    if (_currentSelectionToShow == 0 && processInExecution) {
      getPromptCompletion();
    } else if (_currentSelectionToShow == 1 && processInExecution) {
      getRandomTriviaOnAI();
    } else if (_currentSelectionToShow == 2 && processInExecution) {
      getAssessment();
    } else if (_currentSelectionToShow == 3 && processInExecution) {
      getAssessmentOnConcept();
    }

    // TODO: implement build
    return
/*     Center(
      child:  */
        Container(
      width: 500,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Center(child: Text('Snailpace-ai Learning')),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              widget.goToWidget("Landing");
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  widget.goToWidget("AuthScreen");
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
            height: heightOfScreen, // 800,
            width: 500, //_widthOfScreen,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/snailpace_logo_alt_2.png',
                        height: 80,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      FloatingActionButton(
                        heroTag: "refreshTopic",
                        onPressed: refreshTopic,
                        child: const Icon(Icons.refresh_outlined),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      FloatingActionButton(
                        heroTag: "getThePreviousTopic",
                        onPressed: getThePreviousTopic,
                        child: const Icon(Icons.skip_previous_rounded),
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
                    ],
                  ),
                  Text(
                    "Nugget : ${_currentNuggetItem + 1} of $totalNumberOfNuggets",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  if (processInExecution)
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.amber,
                      ),
                    ),
                  if (processInExecution == false &&
                      _currentSelectionToShow <= 1)
                    Nuggets(
                      titleData: _currentSelectionToShow == 0
                          ? topics[0].subTopics[_currentNuggetItem]
                          : "Random Trivia on A.I.",
                      descriptionData: conceptArticulation, //snapshot.data!,
                      sources: allSources,
                      nuggetType: _currentItem,
                      userSelectedRole: rolePlaySelected,
                      userSelectedVerbosity: verboseSelected,
                    ),
                  if (processInExecution == false &&
                      _currentSelectionToShow == 2)
                    if (jsonDataReturned != null)
                      QuizNuggets(
                        question:
                            "${jsonDataReturned["Question"].toString()}, choose the most appropriate option",
                        answerOptions: allOptions,
                        correctAnswer: jsonDataReturned["Answer"].toString(),
                        reasoningForTheAnswer:
                            jsonDataReturned["Reasoning"].toString(),
                        onSelectAnswer: (question, choosenAnswer, correctAnswer,
                            reasoningForTheAnswer) {
                          eventOnSelectedAnswer(question, choosenAnswer,
                              correctAnswer, reasoningForTheAnswer);
                        },
                      ),
                  if (processInExecution == false &&
                      _currentSelectionToShow == 3)
                    if (jsonDataReturned != null)
                      QuizNuggetsNotes(
                          queryFromGemini: conceptBasedQuestion,
                          answerToQueryFromGemini: answerToConceptBasedQuestion,
                          askSnailOnSubmission:
                              (answerByUser, answerToQueryFromGemini) {
                            setState(() {
                              processInExecution = true;
                            });
                            eventClickedToCheckAnswer(conceptBasedQuestion,
                                answerToQueryFromGemini, answerByUser);
                          }),
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

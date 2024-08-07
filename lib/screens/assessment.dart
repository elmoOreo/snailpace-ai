import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:snailpace/data/roleplay_data.dart';
import 'package:snailpace/data/topic_data.dart';
import 'package:snailpace/widgets/nuggets.dart';
import 'package:snailpace/widgets/quiz_nuggets.dart';
import 'package:snailpace/widgets/quiz_nuggets_notes.dart';

var jsonDataReturned;
var rolePlaySelected;
var verboseSelected;
List<String> allOptions = [];
final randomizer = Random();
String conceptBasedQuestion = "";
String answerToConceptBasedQuestion = "";
bool processInExecution = false;
int currentQuizItem = 0;
int totalQuizItems = 5;
int currentQuizType = 0;
String titleData = "";
var isConceptSame;
var reasoningBehindTheConcept;
int correctlyAnswered = 0;
int multiChoiceQuizItems = 0;
int multiChoiceQuizItemsCorrectlyAnswered = 0;
int conceptualQuizItems = 0;
int conceptualQuizItemsCorrectlyAnswered = 0;
DateTime startTime = DateTime.now();
int totalTimeSpent = 0;
var questionsAsked = [];
var conceptQuestionsAsked = [];
double degreeOfSimilarity = 0.0;

typedef Future<T> FutureGenerator<T>();

class Assessment extends StatefulWidget {
  const Assessment({super.key, required this.goToWidget});

  final void Function(String widgetName) goToWidget;

  @override
  State<Assessment> createState() {
    // TODO: implement createState
    return _AssessmentState();
  }
}

class _AssessmentState extends State<Assessment> {
  @override
  void initState() {
    // TODO: implement initState
    questionsAsked.clear();
    conceptQuestionsAsked.clear();
    startTime = DateTime.now();
    super.initState();
  }

  final currentlyLoggedInUser = FirebaseAuth.instance.currentUser!;

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

  Future<String> getAssessmentOnConcept() async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var randomTopicNumber;

    final userSettingsData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentlyLoggedInUser.uid)
        .get();

    if (userSettingsData.exists) {
      rolePlaySelected = userSettingsData.data()!['roleforArticulation'] == null
          ? rolePlayList[0]
          : userSettingsData.data()!['roleforArticulation'].toString();
    } else {
      rolePlaySelected = rolePlayList[0];
    }
    randomTopicNumber = randomizer.nextInt(topics.length);

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
        Step 2) Ask a relevant question on the topic ${topics[0].subTopics[randomTopicNumber]} which the User needs to detail it out in note more than 5 lines.
        Avoid the following questions which has already been asked
        $conceptQuestionsAsked
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

    conceptQuestionsAsked.add(conceptBasedQuestion);

    answerToConceptBasedQuestion =
        jsonDataReturned["answerToConceptBasedQuestion"];

    return Future.value("Done");
  }

  Future<String> getAssessment() async {
    var apiKey = dotenv.env["GEMINIKEY"];
    var response;
    var content;
    var dataString;
    var randomTopicNumber;

    final userSettingsData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentlyLoggedInUser.uid)
        .get();

    if (userSettingsData.exists) {
      rolePlaySelected = userSettingsData.data()!['roleforArticulation'] != null
          ? userSettingsData.data()!['roleforArticulation'].toString()
          : rolePlayList[0];
    } else {
      rolePlaySelected = rolePlayList[0];
    }
    randomTopicNumber = randomizer.nextInt(topics.length);

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
        Step 1) Ask a relevant question to $rolePlaySelected on the topic ${topics[0].subTopics[randomTopicNumber]}.
        Avoid the following questions which has already been asked
        $questionsAsked
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

    //print(currentPrompt);

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

    questionsAsked.add(jsonDataReturned["Question"].toString());

    allOptions.clear();
    for (int outLoop = 0;
        outLoop < jsonDataReturned["AllOptions"].length;
        outLoop++) {
      allOptions.add(jsonDataReturned["AllOptions"][outLoop]);
    }
    allOptions.shuffle();

    return Future.value("Done");
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

/*     final currentPrompt = '''
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
        Step 5) If in Step 4 they are conceptually the same the return the result conceptSame as true else false and also reasoning behind why they are same or different
        
        Return the results in the format below and ensure JSON is valid. 
          "{
            "isConceptSame": bool
            "reasoningBehindTheConcept": str
          }"
    '''; */

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

    if (isConceptSame == "true") {
      correctlyAnswered++;
      conceptualQuizItemsCorrectlyAnswered++;
    }

    return Future.value("Done");
  }

  void logQuizAggData() async {
    DateTime endTime = DateTime.now();
    totalTimeSpent = endTime.difference(startTime).inSeconds.abs();
    await FirebaseFirestore.instance.collection('assessmentData').add({
      'startTime': startTime,
      'endTime': endTime,
      'durationInSeconds': totalTimeSpent,
      'userId': currentlyLoggedInUser.uid,
      'correctAnswers': correctlyAnswered,
      'totalQuestions': totalQuizItems,
      'multiChoiceQuizItems': multiChoiceQuizItems,
      'conceptualQuizItems': conceptualQuizItems,
      'multiChoiceQuizItemsCorrectlyAnswered':
          multiChoiceQuizItemsCorrectlyAnswered,
      'conceptualQuizItemsCorrectlyAnswered':
          conceptualQuizItemsCorrectlyAnswered
    });
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
      'typeOfQuiz': conceptEval
          ? "assessment-concept-quiz"
          : "assessment-multichoice-quiz"
    });
  }

  void showResultsDialog() {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: correctlyAnswered > 0.5 * totalQuizItems
            ? Colors.greenAccent[100]
            : Colors.deepOrange[100],
        insetPadding: const EdgeInsets.all(1),
        title: const Text('Quiz Results'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                ColoredBox(
                  color: Colors.lightBlueAccent,
                  child: Text(
                    'Total Questions : $totalQuizItems',
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
                  'Multichoice Questions : $multiChoiceQuizItems',
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
                  'Concept Based Questions : $conceptualQuizItems',
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
                  'Total Time Spent in secs : $totalTimeSpent',
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
                    'Correctly Answered : $correctlyAnswered',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
/*           TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ), */
          TextButton(
            onPressed: () {
              conceptualQuizItems = 0;
              currentQuizItem = 0;
              currentQuizItem = 0;
              multiChoiceQuizItems = 0;
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
  }

  void eventClickedToCheckAnswer(conceptBasedQuestion,
      answerToConceptBasedQuestion, answerSubmittedByTheUser) async {
    conceptualQuizItems++;
    currentQuizItem++;

    await checkTheAssessmentOnConcept(conceptBasedQuestion,
        answerToConceptBasedQuestion, answerSubmittedByTheUser);

    logQuizData(conceptBasedQuestion, answerSubmittedByTheUser,
        answerToConceptBasedQuestion, reasoningBehindTheConcept, true);

    if (currentQuizItem > (totalQuizItems - 1)) {
      logQuizAggData();
      showResultsDialog();
      widget.goToWidget("Landing");
    } else {
      setState(() {});
    }
  }

  void eventOnSelectedAnswer(
      question, choosenAnswer, correctAnswer, reasoningForTheAnswer) {
    multiChoiceQuizItems++;
    currentQuizItem++;

    logQuizData(
        question, choosenAnswer, correctAnswer, reasoningForTheAnswer, false);

    // print(
    //     'choosen answer \n $choosenAnswer \n correctAnswer \n $correctAnswer');
    if (choosenAnswer == correctAnswer) {
      correctlyAnswered++;
      multiChoiceQuizItemsCorrectlyAnswered++;
    }

    if (currentQuizItem > (totalQuizItems - 1)) {
      logQuizAggData();
      showResultsDialog();
      widget.goToWidget("Landing");
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final heightOfScreen = MediaQuery.of(context).size.height;
    currentQuizType = randomizer.nextInt(2);
    titleData = (currentQuizItem <= (totalQuizItems - 1))
        ? "Quiz : ${(currentQuizItem + 1).toString()} of ${totalQuizItems.toString()}"
        : "Quiz Completed";

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
                      )
                    ],
                  ),
                  if (processInExecution)
                    const CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.amber,
                    ),
                  FutureBuilder(
                    future: retry(
                        2,
                        currentQuizType == 0
                            ? getAssessment
                            : getAssessmentOnConcept),
                    initialData:
                        "Gemini API is working on the request, please wait",
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          !snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                titleData,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                            if (currentQuizType == 0)
                              if (jsonDataReturned != null)
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
                                    eventOnSelectedAnswer(
                                        question,
                                        choosenAnswer,
                                        correctAnswer,
                                        reasoningForTheAnswer);
                                  },
                                ),
                            if (currentQuizType == 1)
                              if (jsonDataReturned != null)
                                QuizNuggetsNotes(
                                    queryFromGemini: conceptBasedQuestion,
                                    answerToQueryFromGemini:
                                        answerToConceptBasedQuestion,
                                    askSnailOnSubmission: (answerByUser,
                                        answerToQueryFromGemini) {
                                      setState(() {
                                        processInExecution = true;
                                      });
                                      eventClickedToCheckAnswer(
                                          conceptBasedQuestion,
                                          answerToQueryFromGemini,
                                          answerByUser);
                                      setState(() {
                                        processInExecution = false;
                                      });
                                    }),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Nuggets(
                              titleData: titleData,
                              descriptionData:
                                  '''Error fetching data from Gemini API, ${snapshot.data}. There was an unexpected error. Please use one of the  buttons to either referesh or move forward.''',
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
                            Nuggets(
                              titleData: titleData,
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
  }
}

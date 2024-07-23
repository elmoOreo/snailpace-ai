import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:snailpace/widgets/custom_dialog.dart';
import 'package:snailpace/widgets/nuggets.dart';
import 'package:snailpace/data/topic_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snailpace/widgets/custom_dropdown_filter.dart';
import 'dart:math';
import 'dart:convert';
import 'package:snailpace/widgets/quiz_nuggets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var _currentNuggetItem = 0;
var _currentItem = "in-process";
var _currentSelectionToShow = 0;
final randomizer = Random();
var _currentTriviaSelection = "Loading...";
var jsonDataReturned;
List<String> allOptions = [];
bool columnarView = true;
List<String> allSources = [];

var conceptArticulation;

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final currentlyLoggedInUser = FirebaseAuth.instance.currentUser!;

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
        if (_currentNuggetItem <
            topics[0].subTopics[_currentNuggetItem].length) {
          _currentNuggetItem++;
          logUserProgressData();
        }
        _currentItem = "nugget";
      } else if (_currentSelectionToShow == 1) {
        _currentItem = "trivia";
      }
    });
  }

  void getThePreviousTopic() {
    //_currentSelectionToShow = randomizer.nextInt(3);

    _currentSelectionToShow = 0;

/*     if (_currentSelectionToShow == 0) {
      _currentSelectionToShow = 1;
    } else if (_currentSelectionToShow == 1) {
      _currentSelectionToShow = 2;
    } else {
      _currentSelectionToShow = 0;
    } */

    setState(() {
      if (_currentSelectionToShow == 0) {
        if (_currentNuggetItem > 0) {
          _currentNuggetItem--;
        } else {
          _currentNuggetItem = 0;
        }
        _currentItem = "nugget";
        logUserProgressData();
      } else if (_currentSelectionToShow == 1) {
        _currentItem = "trivia";
      }
    });
  }

  Future<String> logUserProgressData() async {
    var returnValue = "No error";

    final userProgressData = <String, dynamic>{
      "userId": currentlyLoggedInUser.uid,
      "currentNugget": _currentNuggetItem,
      'lastUpdatedOn': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection("userProgressData")
        .doc(currentlyLoggedInUser.uid)
        .set(userProgressData)
        .then((value) => returnValue = "Data added successfully")
        .catchError((error) => returnValue = "Failed to add data: $error");

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

  void eventOnSelectedAnswer(question, choosenAnswer, correctAnswer) {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.deepOrange[300],
        title: const Text('Quiz Result'),
        content: CustomDialog(
            question: question,
            choosenAnswer: choosenAnswer,
            correctAnswer: correctAnswer),
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

    final randomTopicNumber = randomizer.nextInt(_currentNuggetItem);

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

        Return the results in the format below and ensure JSON is valid. 
          "{
            "Question": str
            "Answer": str
            "AllOptions":[]
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

/*     final currentPrompt = '''
        You are an AI Guru and an expert in articulating complex concepts on AI in simpler terms. 

        Please do not hallucinate, if you are not aware, please say it so in courteous fashion.

        Imagine you have to explain the concept of ${topics[0].subTopics[_currentNuggetItem]} in $verboseSelected to $rolePlaySelected. As part of the reply please enclose the source of the information.
    '''; */

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
    return Future.value("Done");
  }

  @override
  Widget build(BuildContext context) {
    //final _widthOfScreen = MediaQuery.of(context).size.width;
    final _heightOfScreen = MediaQuery.of(context).size.height;

/*     print("Height $_heightOfScreen");
    print("Width $_widthOfScreen"); */

    // TODO: implement build
    return columnarView
        ? Scaffold(
            appBar: AppBar(
              title: /* Center(
              child: Image.asset(
            'assets/images/snailpace_logo_alt_2.png',
            fit: BoxFit.contain,
            height: 100,
          )) */
                  const Center(child: Text('SnailPace Learning')),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomDropdownFilter(
                        dropDownTitle: 'Selected Role',
                        dropDownData: rolePlayList,
                        defaultValue: rolePlaySelected,
                        onSelectionOfOption: (selectedOption) {
                          setState(() {
                            rolePlaySelected = selectedOption;
                          });
                        },
                      ),
                      CustomDropdownFilter(
                        dropDownTitle: 'Articulate',
                        dropDownData: verboseList,
                        defaultValue: verboseSelected,
                        onSelectionOfOption: (selectedOption) {
                          setState(() {
                            verboseSelected = selectedOption;
                          });
                        },
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
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              !snapshot.hasError) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: getThePreviousTopic,
                                      child: const Icon(
                                          Icons.skip_previous_rounded),
                                    ),
                                    /* IconButton(
                                          onPressed: getThePreviousTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_previous_rounded,
                                            color: Colors.black,
                                          )), */
                                    /*                                   const SizedBox(
                                        width: 250,
                                      ), */
                                    Image.asset(
                                      'assets/images/snailpace_logo_alt_2.png',
                                      height: 100,
                                    ),
                                    /*                                 IconButton(
                                          onPressed: getTheNextTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_next_rounded,
                                            color: Colors.black,
                                          )) */
                                    FloatingActionButton(
                                      onPressed: getTheNextTopic,
                                      child: const Icon(
                                        Icons.skip_next_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_currentSelectionToShow <= 1)
                                  Nuggets(
                                    titleData: _currentSelectionToShow == 0
                                        ? topics[0]
                                            .subTopics[_currentNuggetItem]
                                        : "Random Trivia on A.I.",
                                    descriptionData:
                                        conceptArticulation, //snapshot.data!,
                                    sources: allSources,
                                    nuggetType: _currentItem,
                                  ),
                                if (_currentSelectionToShow == 2)
                                  QuizNuggets(
                                    question:
                                        "${jsonDataReturned["Question"].toString()}, choose the most appropriate option",
                                    answerOptions: allOptions,
                                    correctAnswer:
                                        jsonDataReturned["Answer"].toString(),
                                    onSelectAnswer: (question, choosenAnswer,
                                        correctAnswer) {
                                      eventOnSelectedAnswer(question,
                                          choosenAnswer, correctAnswer);
                                    },
                                  ),
                                /* Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: getThePreviousTopic,
                                      child: const Icon(
                                          Icons.skip_previous_rounded),
                                    ),
                                    /* IconButton(
                                          onPressed: getThePreviousTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_previous_rounded,
                                            color: Colors.black,
                                          )), */
                                    /*                                   const SizedBox(
                                        width: 250,
                                      ), */
                                    Image.asset(
                                      'assets/images/snailpace_logo_alt_2.png',
                                      height: 100,
                                    ),
                                    /*                                 IconButton(
                                          onPressed: getTheNextTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_next_rounded,
                                            color: Colors.black,
                                          )) */
                                    FloatingActionButton(
                                      onPressed: getTheNextTopic,
                                      child: const Icon(
                                        Icons.skip_next_rounded,
                                      ),
                                    ),
                                  ],
                                ) ,*/
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: getThePreviousTopic,
                                      child: const Icon(
                                          Icons.skip_previous_rounded),
                                    ),
                                    /* IconButton(
                                          onPressed: getThePreviousTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_previous_rounded,
                                            color: Colors.black,
                                          )), */
                                    /*                                   const SizedBox(
                                        width: 250,
                                      ), */
                                    Image.asset(
                                      'assets/images/snailpace_logo_alt_2.png',
                                      height: 100,
                                    ),
                                    /*                                 IconButton(
                                          onPressed: getTheNextTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_next_rounded,
                                            color: Colors.black,
                                          )) */
                                    FloatingActionButton(
                                      onPressed: getTheNextTopic,
                                      child: const Icon(
                                        Icons.skip_next_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                Nuggets(
                                  titleData:
                                      topics[0].subTopics[_currentNuggetItem],
                                  descriptionData:
                                      '''Error fetching data from Gemini API, ${snapshot.data}. There was an unexpected error.
                                      Please use the above navigation buttons to move onto the next topic.
                                      ''',
                                  sources: [],
                                  nuggetType: "error",
                                ),
                                /* Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: getThePreviousTopic,
                                      child: const Icon(
                                          Icons.skip_previous_rounded),
                                    ),
                                    /* IconButton(
                                          onPressed: getThePreviousTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_previous_rounded,
                                            color: Colors.black,
                                          )), */
                                    /*                                   const SizedBox(
                                        width: 250,
                                      ), */
                                    Image.asset(
                                      'assets/images/snailpace_logo_alt_2.png',
                                      height: 100,
                                    ),
                                    /*                                 IconButton(
                                          onPressed: getTheNextTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_next_rounded,
                                            color: Colors.black,
                                          )) */
                                    FloatingActionButton(
                                      onPressed: getTheNextTopic,
                                      child: const Icon(
                                        Icons.skip_next_rounded,
                                      ),
                                    ),
                                  ],
                                ), */
                              ],
                            ); /* Text(
                                  'Error fetching data from Gemini API, ${snapshot.data}'); */
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: getThePreviousTopic,
                                      child: const Icon(
                                          Icons.skip_previous_rounded),
                                    ),
                                    /* IconButton(
                                          onPressed: getThePreviousTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_previous_rounded,
                                            color: Colors.black,
                                          )), */
                                    /*                                   const SizedBox(
                                        width: 250,
                                      ), */
                                    Image.asset(
                                      'assets/images/snailpace_logo_alt_2.png',
                                      height: 100,
                                    ),
                                    /*                                 IconButton(
                                          onPressed: getTheNextTopic,
                                          icon: Icon(
                                            size: 50,
                                            Icons.skip_next_rounded,
                                            color: Colors.black,
                                          )) */
                                    FloatingActionButton(
                                      onPressed: getTheNextTopic,
                                      child: const Icon(
                                        Icons.skip_next_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                Nuggets(
                                  titleData:
                                      topics[0].subTopics[_currentNuggetItem],
                                  descriptionData:
                                      "Gemini API is processing your request, please wait......",
                                  sources: [],
                                  nuggetType: "in-process",
                                )
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
          )
        // Row View
        : Scaffold(
            appBar: AppBar(
              title: /* Center(
              child: Image.asset(
            'assets/images/snailpace_logo_alt_2.png',
            fit: BoxFit.contain,
            height: 100,
          )) */
                  const Center(child: Text('SnailPace Learning')),
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
                width: 650,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomDropdownFilter(
                      dropDownTitle: 'Selected Role',
                      dropDownData: rolePlayList,
                      defaultValue: rolePlaySelected,
                      onSelectionOfOption: (selectedOption) {
                        setState(() {
                          rolePlaySelected = selectedOption;
                        });
                      },
                    ),
                    CustomDropdownFilter(
                      dropDownTitle: 'Articulate',
                      dropDownData: verboseList,
                      defaultValue: verboseSelected,
                      onSelectionOfOption: (selectedOption) {
                        setState(() {
                          verboseSelected = selectedOption;
                        });
                      },
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
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FloatingActionButton(
                                    onPressed: getThePreviousTopic,
                                    child:
                                        const Icon(Icons.skip_previous_rounded),
                                  ),
                                  if (_currentSelectionToShow <= 1)
                                    Nuggets(
                                      titleData: _currentSelectionToShow == 0
                                          ? topics[0]
                                              .subTopics[_currentNuggetItem]
                                          : "Random Trivia on A.I.",
                                      descriptionData:
                                          conceptArticulation, //snapshot.data!,
                                      sources: allSources,
                                      nuggetType: _currentItem,
                                    ),
                                  if (_currentSelectionToShow == 2)
                                    QuizNuggets(
                                      question:
                                          "${jsonDataReturned["Question"].toString()}, choose the most appropriate option",
                                      answerOptions: allOptions,
                                      correctAnswer:
                                          jsonDataReturned["Answer"].toString(),
                                      onSelectAnswer: (question, choosenAnswer,
                                          correctAnswer) {
                                        logQuizData(question, choosenAnswer,
                                            correctAnswer);

                                        eventOnSelectedAnswer(question,
                                            choosenAnswer, correctAnswer);
                                      },
                                    ),
                                  FloatingActionButton(
                                    onPressed: getTheNextTopic,
                                    child: const Icon(
                                      Icons.skip_next_rounded,
                                    ),
                                  ),

                                  /* Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FloatingActionButton(
                                        onPressed: getThePreviousTopic,
                                        child:
                                            const Icon(Icons.skip_previous_rounded),
                                      ),
                                      /* IconButton(
                                            onPressed: getThePreviousTopic,
                                            icon: Icon(
                                              size: 50,
                                              Icons.skip_previous_rounded,
                                              color: Colors.black,
                                            )), */
                                      /*                                   const SizedBox(
                                          width: 250,
                                        ), */
                                      Image.asset(
                                        'assets/images/snailpace_logo_alt_2.png',
                                        height: 100,
                                      ),
                                      /*                                 IconButton(
                                            onPressed: getTheNextTopic,
                                            icon: Icon(
                                              size: 50,
                                              Icons.skip_next_rounded,
                                              color: Colors.black,
                                            )) */
                                      FloatingActionButton(
                                        onPressed: getTheNextTopic,
                                        child: const Icon(
                                          Icons.skip_next_rounded,
                                        ),
                                      ),
                                    ],
                                  ), */
                                ],
                              ),
                              Image.asset(
                                'assets/images/snailpace_logo_alt_2.png',
                                height: 100,
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Nuggets(
                                titleData:
                                    topics[0].subTopics[_currentNuggetItem],
                                descriptionData:
                                    'Error fetching data from Gemini API, ${snapshot.data}',
                                sources: [],
                                nuggetType: "error",
                              )
                            ],
                          ); /* Text(
                                'Error fetching data from Gemini API, ${snapshot.data}'); */
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Nuggets(
                                titleData:
                                    topics[0].subTopics[_currentNuggetItem],
                                descriptionData:
                                    "Gemini API is processing your request, please wait",
                                sources: [],
                                nuggetType: "in-process",
                              )
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

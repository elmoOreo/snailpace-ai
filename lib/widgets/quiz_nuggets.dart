import 'package:flutter/material.dart';
import 'package:snailpace/widgets/answer_button.dart';

class QuizNuggets extends StatefulWidget {
  QuizNuggets({
    super.key,
    required this.question,
    required this.answerOptions,
    required this.correctAnswer,
    required this.onSelectAnswer,
    required this.reasoningForTheAnswer,
  });

  final String question;
  final List<String> answerOptions;
  final String correctAnswer;
  final String reasoningForTheAnswer;
  final void Function(String question, String choosenAnswer,
      String correctAnswer, String reasoningForTheAnswer) onSelectAnswer;

  @override
  State<QuizNuggets> createState() {
    // TODO: implement createState
    return _QuizNuggetsState();
  }
}

class _QuizNuggetsState extends State<QuizNuggets> {
  void onTapOfTheButton(String question, String choosenAnswer,
      String correctAnswer, String reasoningForTheAnswer) {
    widget.onSelectAnswer(
        question, choosenAnswer, correctAnswer, reasoningForTheAnswer);
  }

  @override
  Widget build(BuildContext context) {
    final _heightOfScreen = MediaQuery.of(context).size.height;

    // TODO: implement build
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      color: Colors.cyanAccent[100],
      child: SizedBox(
        width: 500,
        height: _heightOfScreen * .75, //500
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Answer Buttons
                ...widget.answerOptions.map((item) {
                  return Column(
                    children: [
                      AnswerButton(
                        answerText: item,
                        onTap: () {
                          onTapOfTheButton(
                              widget.question,
                              item,
                              widget.correctAnswer,
                              widget.reasoningForTheAnswer);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

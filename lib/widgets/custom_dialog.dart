import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog(
      {super.key,
      required this.question,
      required this.choosenAnswer,
      required this.correctAnswer,
      required this.reasoningForTheAnswer});

  final String question;
  final String choosenAnswer;
  final String correctAnswer;
  final String reasoningForTheAnswer;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final _widthOfScreen = MediaQuery.of(context).size.width;
    final _heightOfScreen = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Card(
        elevation: 50,
        shadowColor: Colors.black,
        color: choosenAnswer == correctAnswer
            ? Colors.greenAccent[100]
            : Colors.deepOrange[100],
        child: SizedBox(
          width: _widthOfScreen, //500,
          height: _heightOfScreen * 0.6, //500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.05),
                child: Text(
                  'Question : $question',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.05),
                child: Text(
                  'Choosen Answer : $choosenAnswer',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.05),
                child: Text(
                  'Correct Answer : $correctAnswer',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.05),
                child: Text(
                  'Reasoning for the Answer : $reasoningForTheAnswer',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

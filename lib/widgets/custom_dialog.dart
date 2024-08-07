import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog(
      {super.key,
      required this.question,
      required this.choosenAnswer,
      required this.correctAnswer,
      required this.degreeOfSimilarity,
      required this.reasoningForTheAnswer});

  final String question;
  final String choosenAnswer;
  final String correctAnswer;
  final String reasoningForTheAnswer;
  final String degreeOfSimilarity;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return SingleChildScrollView(
      child: SizedBox(
        width: 500,
        child: Column(
          children: [
            ColoredBox(
              color: Colors.lightBlueAccent,
              child: Text(
                'Question : $question',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 15),
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
              'Your Answer : $choosenAnswer',
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 15),
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
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(
              height: 10,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ),
            if (degreeOfSimilarity != "")
              Column(
                children: [
                  Text(
                    'Degree of Similarity : $degreeOfSimilarity',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 2,
                    indent: 0,
                    endIndent: 0,
                    color: Colors.black,
                  ),
                ],
              ),
            ColoredBox(
              color: Colors.lightGreenAccent,
              child: Text(
                'Reasoning for the Answer : $reasoningForTheAnswer',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
    /* SingleChildScrollView(
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
    ); */
  }
}

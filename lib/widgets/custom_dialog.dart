import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  CustomDialog(
      {super.key,
      required this.question,
      required this.choosenAnswer,
      required this.correctAnswer});

  final String question;
  final String choosenAnswer;
  final String correctAnswer;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    //final _widthOfScreen = MediaQuery.of(context).size.width;
    //final _heightOfScreen = MediaQuery.of(context).size.height;
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      color: choosenAnswer == correctAnswer
          ? Colors.greenAccent[100]
          : Colors.deepOrange[100],
      child: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Question : $question',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 20),
              ),
            ),
/*             const Divider(
              height: 5,
              thickness: 5,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ), */
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'Choosen Answer : $choosenAnswer',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 20),
              ),
            ),
/*             const Divider(
              height: 5,
              thickness: 5,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ), */

            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'Correct Answer : $correctAnswer',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 20),
              ),
            ),
/*             const Divider(
              height: 5,
              thickness: 5,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ), */
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton(
      {super.key, required this.answerText, required this.onTap});

  final String answerText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: 50,
      width: 400,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.amber,
        ),
        icon: const Icon(Icons.add_task),
        label: Text(
          answerText,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

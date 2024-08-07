import 'package:flutter/material.dart';

class QuizNuggetsNotes extends StatefulWidget {
  QuizNuggetsNotes(
      {super.key,
      required this.queryFromGemini,
      required this.answerToQueryFromGemini,
      required this.askSnailOnSubmission});

  final String queryFromGemini;
  final String answerToQueryFromGemini;
  final void Function(String answerByUser, String answerToQueryFromGemini)
      askSnailOnSubmission;

  @override
  State<QuizNuggetsNotes> createState() {
    // TODO: implement createState
    return _QuizNuggetsNotesState();
  }
}

class _QuizNuggetsNotesState extends State<QuizNuggetsNotes> {
  final TextEditingController conceptArticulatedByUser =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    final heightOfScreen = MediaQuery.of(context).size.height;

    // TODO: implement build
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      color: Colors.cyanAccent[100],
      child: SizedBox(
        width: 500,
        height: heightOfScreen * .75, //500
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  widget.queryFromGemini,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  autocorrect: true,
                  autofocus: true,
/*                   onTap: () {
                    conceptArticulatedByUser.text = "";
                  }, */
                  style: const TextStyle(color: Colors.black),
                  maxLines: 8,
                  controller: conceptArticulatedByUser,
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 244, 196, 132),
                          width: 5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 244, 196, 132),
                          width: 5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 244, 196, 132),
                          width: 5.0),
                    ),
                    labelText: 'Answer the Query',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.askSnailOnSubmission(conceptArticulatedByUser.text,
                      widget.answerToQueryFromGemini);
                  /*                 if (conceptArticulatedByUser.text.trim().isEmpty) {
                    conceptArticulatedByUser.text = "Please answer to the query";
                  } else {
                    widget.askSnailOnSubmission(
                        conceptArticulatedByUser.text
                            .replaceAll("Please answer to the query", ""),
                        widget.answerToQueryFromGemini);
                  } */
                },
                icon: const Icon(
                  Icons.arrow_circle_right_sharp,
                  color: Colors.black,
                  size: 40,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

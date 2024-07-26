import 'package:flutter/material.dart';
//import 'package:linkify_text/linkify_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:string_validator/string_validator.dart';

class Nuggets extends StatelessWidget {
  const Nuggets(
      {super.key,
      required this.titleData,
      required this.descriptionData,
      required this.sources,
      required this.nuggetType,
      required this.userSelectedRole,
      required this.userSelectedVerbosity});

  final String titleData;
  final String descriptionData;
  final String nuggetType;
  final List<String> sources;
  final String userSelectedRole;
  final String userSelectedVerbosity;
  @override
  Widget build(BuildContext context) {
    //final _widthOfScreen = MediaQuery.of(context).size.width;
    final _heightOfScreen = MediaQuery.of(context).size.height;
    var linkCount = 0;

    // TODO: implement build
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      color: nuggetType == "nugget"
          ? Colors.greenAccent[100]
          : (nuggetType == "trivia"
              ? Colors.yellowAccent[100]
              : (nuggetType == "in-process"
                  ? Colors.blueAccent[100]
                  : Colors.redAccent[300])),
      child: SizedBox(
        width: 500, //_widthOfScreen
        height: _heightOfScreen * .75, //500,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  titleData,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                ),
                if (nuggetType == "in-process")
                  const SizedBox(
                      height: 100,
                      width: 100,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.amber,
                      )),
                if (nuggetType == "nugget")
                  Text(
                    "Articulated for a $userSelectedRole in less than $userSelectedVerbosity",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  descriptionData,
                  style: TextStyle(
                    fontSize: nuggetType == "error" ? 25 : 20,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ...sources.map(
                  (item) {
                    linkCount++;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () => isURL(item)
                                ? launchUrl(Uri.parse(item))
                                : () {},
                            child: Text(
                              isURL(item)
                                  ? "Source Link $linkCount : : $item"
                                  : item,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                ),
                if (nuggetType == "nugget")
                  const Text(
                    "***Note*** You can change the style of narration, both role and length using the user settings on the top left corner. Hit the refresh button once you make the change.",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      required this.nuggetType});

  final String titleData;
  final String descriptionData;
  final String nuggetType;
  final List<String> sources;
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
        height: _heightOfScreen * .60, //500,
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
                const SizedBox(
                  height: 5,
                ),
/*                 LinkifyText(
                  descriptionData,
                  fontColor: Colors.black,
                  fontSize: 15,
                ), */
                Text(
                  descriptionData,
                  style: TextStyle(
                    fontSize: nuggetType == "error" ? 25 : 15,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ...sources.map((item) {
                  linkCount++;
                  return
/*                   InkWell(
                    onTap: () =>
                        isURL(item) ? launchUrl(Uri.parse(item)) : () {},
                    child: Text(
                      "Source Link $linkCount",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.black),
                    ),
                  ); */
                      Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () =>
                              isURL(item) ? launchUrl(Uri.parse(item)) : () {},
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
                        height: 2,
                      ),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

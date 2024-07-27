import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatNuggets extends StatelessWidget {
  ChatNuggets(
      {super.key,
      required this.dataCountNuggets,
      required this.userChatShowList,
      required this.modelChatShowList,
      required this.modelChatSourceList});

  final int dataCountNuggets;
  final List<dynamic> userChatShowList;
  final List<dynamic> modelChatShowList;
  final List<List<dynamic>> modelChatSourceList;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var linkCount = 0;
    var dataCount = dataCountNuggets;

    return Column(
      children: [
        ...userChatShowList.map((item) {
          dataCount--;
          linkCount = 0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 500,
                child: Row(
                  children: [
                    Card(
                        elevation: 50,
                        shadowColor: Colors.black,
                        color: Colors.amberAccent[100],
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            userChatShowList[dataCount],
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    const Expanded(
                      child: SizedBox(
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 500,
                child: Card(
                    elevation: 50,
                    shadowColor: Colors.black,
                    color: Colors.greenAccent[200],
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(modelChatShowList[dataCount],
                          style: TextStyle(fontSize: 15)),
                    )),
              ),
              ...modelChatSourceList[dataCount].map((item) {
                linkCount++;
                return SizedBox(
                  width: 500,
                  child: Card(
                    elevation: 50,
                    shadowColor: Colors.black,
                    color: Colors.greenAccent[300],
                    child: InkWell(
                      onTap: () =>
                          isURL(item) ? launchUrl(Uri.parse(item)) : () {},
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
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
                  ),
                );
              })
            ],
          );
        })
      ],
    );
  }
}

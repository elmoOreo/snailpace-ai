//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Container(
        width: 500,
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('Snailpace-ai Learning')),
            actions: [
/*               IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context, rootNavigator: true).pop(context);
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).colorScheme.primary,
                  )) */
            ],
          ),
          //drawer: CustomDrawer(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 20,
                    right: 20,
                  ),
                  width: 150,
                  child: Image.asset('assets/images/snailpace_logo_alt_2.png'),
                ),
                const Text(
                  "What data is collected as part of Snailpace-AI?",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  child: Text(
                    '''1) Firebase is the backend used for this app\n\n2) As part of the registration process the user emailid is recorded and the credentials are managed by Firebase. The data collected within the app is managed by Firebase Firestrore Database\n\n3) This application articulates 100+ topics referred to as Nuggets in a personalized tone as selected by the end user\n\n4) As part of the data collection process, the current nugget item number, is recorded so that the application knows the place to re-start, the next time the User logs in. Internally the User is referenced by a system generated UID and has no mapping to the emailid of the User\n\n5) As part of the data collection process, the Quiz and the User selection is recorded for only scoring purposes\n\n6) The logs generated while learning Nuggets and the Quiz attendance is converted to an AiIQ score as internally defined\n\n7) The app interacts with Gemini API through well crafted safe prompts that generate safe completions. No personal information is shared with Gemini API at any point in time\n\n8) Please email us for any specific clarification''',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    softWrap: true,
                  ),
                ),
                SelectableText(
                  "snailpaceai@gmail.com",
                  showCursor: true,
                  cursorWidth: 2,
                  cursorColor: Colors.black,
                  cursorRadius: Radius.circular(2),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  onTap: () =>
                      launchUrl(Uri.parse("mailto:snailpaceai@gmail.com")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

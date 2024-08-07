//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_linkify/flutter_linkify.dart';
//import 'package:linkify_text/linkify_text.dart';

class About extends StatelessWidget {
  const About({super.key});

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
                  "What is Snailpace-AI",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Text(
                    'Snailpace-AI  2.1 is your pocket-sized professor. Learn complex topics on AI effortlessly with our AI-driven microlearning platform. Enjoy personalized content, interactive quizzes, and bite-sized summaries. Accelerate your knowledge with Snailpace-AI. Please drop a note to the email id for any clarification',
                    style: TextStyle(fontSize: 20, color: Colors.white),
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
                const Text(
                  "Our Vision is to",
                  style: TextStyle(color: Colors.orange, fontSize: 20),
                ),
                const Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  child: Text(
                    'Democratize knowledge by making learning accessible, engaging, and efficient for everyone, anytime, anywhere.',
                    style: TextStyle(fontSize: 20, color: Colors.orange),
                    softWrap: true,
                  ),
                ),
                const Text(
                  "We are on a Mission to",
                  style: TextStyle(color: Colors.amber, fontSize: 20),
                ),
                const Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 5),
                  child: Text(
                    'Deliver personalized, engaging learning experiences that empower individuals to acquire new knowledge efficiently and effectively.',
                    style: TextStyle(fontSize: 20, color: Colors.amber),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

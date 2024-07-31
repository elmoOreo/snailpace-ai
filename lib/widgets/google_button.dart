import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snailpace/screens/master_screen.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final _firebase = FirebaseAuth.instance;

String? name;
String? imageUrl;
var uid;
var userEmail;

class GoogleButton extends StatefulWidget {
  @override
  State<GoogleButton> createState() {
    // TODO: implement createState
    return _GoogleButtonState();
  }
}

class _GoogleButtonState extends State<GoogleButton> {
  Future<User?> signInWithGoogle() async {
    User? user;

    // The `GoogleAuthProvider` can only be used while running on the web
    GoogleAuthProvider authProvider = GoogleAuthProvider();
    try {
      final UserCredential userCredential =
          await _firebase.signInWithPopup(authProvider);

      user = userCredential.user;
    } catch (e) {
      return null;
    }
    if (user != null) {
      uid = user.uid;
      name = user.displayName;
      userEmail = user.email;
      imageUrl = user.photoURL;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('auth', true);
    }

    return user;
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    await _firebase.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auth', false);

    uid = null;
    name = null;
    userEmail = null;
    imageUrl = null;
  }

  bool _isProcessing = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey, width: 3),
        ),
        color: Colors.white,
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.blueGrey, width: 3),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          setState(() {
            _isProcessing = true;
          });
          await signInWithGoogle().then((result) {
/*             print('-----------------');
            print(result);
            print('-----------------'); */
          }).catchError((error) {
/*             print('-----------------');
            print('Registration Error: $error');
            print('-----------------'); */
          });
          setState(() {
            _isProcessing = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: _isProcessing
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blueGrey,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 20,
                      child: Image.asset('assets/images/googlelogo.png'),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}

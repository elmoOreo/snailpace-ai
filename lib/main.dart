import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snailpace/firebase_options.dart';
import 'package:snailpace/screens/auth.dart';
import 'package:snailpace/screens/home.dart';
import 'package:snailpace/screens/landing.dart';
import 'package:snailpace/screens/master_screen.dart';
import 'package:snailpace/screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load(fileName: "randomfile.env");
    runApp(const App());
  }, (exception, stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SnailPace',
        theme: ThemeData().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 63, 17, 177),
//              Color.fromARGB(255, 63, 17, 177)
//              Color.fromARGB(255, 3, 230, 246),
//              Color.fromARGB(255, 213, 234, 95),
          ),
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (snapshot.hasData) {
                //return Landing();
                return MasterScreen();
              }

              return const AuthScreen();
            }));
  }
}

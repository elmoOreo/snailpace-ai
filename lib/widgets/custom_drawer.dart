import 'package:flutter/material.dart';
import 'package:snailpace/screens/user_settings.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('User Settings'),
            onTap: () {
              UserSettings();
            },
          ),
        ],
      ),
    );
  }
}

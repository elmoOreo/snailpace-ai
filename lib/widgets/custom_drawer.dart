import 'package:flutter/material.dart';
import 'package:snailpace/screens/chat.dart';
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
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Image.asset('assets/images/snailpace_logo_alt_2.png'),
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.settings),
                SizedBox(
                  width: 20,
                ),
                Text('User Settings')
              ],
            ),
            onTap: () {
              Navigator.pop(context);

/*               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserSettings()),
              ); */
            },
          ),
          ListTile(
            title: const Row(
              children: [
                Icon(Icons.chat),
                SizedBox(
                  width: 20,
                ),
                Text('Ask Snail')
              ],
            ),
            onTap: () {
              Navigator.pop(context);

/*               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              ); */
            },
          ),
        ],
      ),
    );
  }
}

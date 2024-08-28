import 'package:flutter/material.dart';

bool _topicSelected = false;

class ChatFilter extends StatefulWidget {
  ChatFilter(
      {super.key,
      required this.selectedTopicForDiscussion,
      required this.getInitialCompletion,
      required this.topicForSelection,
      required this.askSnail});

  String selectedTopicForDiscussion;
  final List<String> topicForSelection;
  final void Function(String item) getInitialCompletion;
  final void Function(String queryFromUser) askSnail;

  @override
  State<ChatFilter> createState() {
    // TODO: implement createState
    return _ChatFilterState();
  }
}

class _ChatFilterState extends State<ChatFilter> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController queryFromUser = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 500,
          child: Row(
            children: [
              Image.asset(
                'assets/images/snailpace_logo_alt_2.png',
                height: 100,
              ),
              Expanded(
                child: DropdownMenu<String>(
                  initialSelection: widget.selectedTopicForDiscussion,
                  enableFilter: true,
                  enableSearch: true,
                  leadingIcon: const Icon(Icons.search),
                  inputDecorationTheme: const InputDecorationTheme(
                    fillColor: Colors.amber,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  controller: itemController,
                  requestFocusOnTap: true,
                  label: const Text('Select a topic for chat'),
                  onSelected: (item) {
                    widget.selectedTopicForDiscussion = item!;
                    widget.getInitialCompletion(item);
                    _topicSelected = true;
                    setState(() {});
                  },
                  dropdownMenuEntries: widget.topicForSelection
                      .map<DropdownMenuEntry<String>>((String item) {
                    return DropdownMenuEntry<String>(
                      value: item,
                      label: item,
                      style: MenuItemButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 500,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  enabled: _topicSelected ? true : false,
                  maxLines: 3,
                  controller: queryFromUser,
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    labelText: _topicSelected
                        ? 'AskSnail : Please ask anything on the topic'
                        : 'AskSnail : Please select a Topic to start the conversation',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    String askSnailText = "";
                    if (_topicSelected &&
                        queryFromUser.text.trim().isNotEmpty) {
                      askSnailText = queryFromUser.text;
                      queryFromUser.text = "";
                      widget.askSnail(askSnailText);
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ))
            ],
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CustomDropdownFilter extends StatefulWidget {
  CustomDropdownFilter(
      {super.key,
      required this.dropDownTitle,
      required this.dropDownData,
      required this.defaultValue,
      required this.onSelectionOfOption});

  final List<String> dropDownData;
  final String dropDownTitle;
  final String defaultValue;
  final void Function(String selectedOption) onSelectionOfOption;

  @override
  State<CustomDropdownFilter> createState() {
    // TODO: implement createState
    return _DropDownFilterState();
  }
}

class _DropDownFilterState extends State<CustomDropdownFilter> {
  var currentSelectedOption = "Loading...";
  List<String> dataListForDropDown = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentSelectedOption = widget.defaultValue;
    dataListForDropDown = widget.dropDownData;
  }

  void onDropDownSelectionChange(String selectedOption) {
    widget.onSelectionOfOption(selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      elevation: 50,
      shadowColor: Colors.black,
      color: Colors.greenAccent[100],
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(widget.dropDownTitle,
                style: TextStyle(color: Colors.black, fontSize: 20)),
          ),
          SizedBox(width: 20),
          DropdownButton(
            // Initial Value
            value: currentSelectedOption,

            // Down Arrow Icon
            icon: const Icon(Icons.keyboard_arrow_down),

            // Array list of items
            items: dataListForDropDown.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(
                  items,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              );
            }).toList(),
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (String? newValue) {
              onDropDownSelectionChange(newValue!);
              setState(() {
                currentSelectedOption = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}

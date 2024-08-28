import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingOptions extends StatelessWidget {
  LandingOptions(
      {super.key,
      required this.blockTitle,
      required this.blockColor,
      required this.onBlockTap,
      required this.iconClass});

  final String blockTitle;
  final Color blockColor;
  final IconData iconClass;
  final void Function() onBlockTap;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: onBlockTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              blockColor.withOpacity(0.55),
              blockColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              iconClass,
              size: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child:
/*               Flexible(
                child:  */
                  Text(
                blockTitle,
                softWrap: true,
                style: GoogleFonts.robotoSlab(
                    textStyle: TextStyle(color: Colors.white, fontSize: 15)),
/*                 style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ), */
              ),
//              ),
            ),
          ],
        ),
      ),
    );
  }
}

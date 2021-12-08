import 'package:flutter/material.dart';
import 'package:flutter_fight_club/resources/fight_club_colors.dart';

class SecondaryActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const SecondaryActionButton(
      {Key? key, required this.onTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: FightClubColors.darkGreyText,
          ),
          color: FightClubColors.background,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 40.0,
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
              fontSize: 16, color: FightClubColors.darkGreyText),
        ),
      ),
    );
  }
}

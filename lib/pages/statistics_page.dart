import 'package:flutter/material.dart';
import 'package:flutter_fight_club/pages/main_page.dart';
import 'package:flutter_fight_club/resources/fight_club_colors.dart';
import 'package:flutter_fight_club/widgets/secondary_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FightClubColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 16.0, top: 24.0, right: 16.0),
              child: const Text(
                'Statistics',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: FightClubColors.darkGreyText),
                textAlign: TextAlign.center,
              ),
            ),
            const Expanded(child: SizedBox()),
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox();
                }
                final SharedPreferences sp = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Won: ${sp.getInt('stats_won') ?? 0}',
                      style: const TextStyle(
                          fontSize: 16, color: FightClubColors.darkGreyText),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lost: ${sp.getInt('stats_lost') ?? 0}',
                      style: const TextStyle(
                          fontSize: 16, color: FightClubColors.darkGreyText),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Draw: ${sp.getInt('stats_draw') ?? 0}',
                      style: const TextStyle(
                          fontSize: 16, color: FightClubColors.darkGreyText),
                    ),
                  ],
                );
              },
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: SecondaryActionButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MainPage(),
                      ),
                    );
                  },
                  text: 'Back'),
            ),
          ],
        ),
      ),
    );
  }
}

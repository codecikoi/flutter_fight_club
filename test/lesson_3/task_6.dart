import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fight_club/fight_result.dart';
import 'package:flutter_fight_club/main.dart';
import 'package:flutter_fight_club/pages/fight_page.dart';
import 'package:flutter_fight_club/widgets/action_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/test_helpers.dart';

///
/// 6. Добавить статистику битв
///    Используем SharedPreferences для сохранения дополнительных результатов.
///    Отображаем статистику на экране StatisticsPage
///    (4 балла - необязательное)
///
/// - Когда мы на экране с битвой заканчиваем битву, то записывать в
///   SharedPreferences информацию о том, сколько стало данных результатов.
/// - Например, если мы победили в первый раз, то сохранить в поле "stats_won"
///   1 типа int.
/// - Если мы победили во второй раз, то мы должны взять текущее сохраненное
///   количество, увеличить его на 1 и сохранить опять в поле "stats_won",
///   теперь уже 2.
/// - Соотношение результата и названия поля:
///   -- Выиграли — stats_won
///   -- Проиграли — stats_lost
///   -- Ничья — stats_draw
/// - Сохраняем данные в числовом формате int!
/// - Добавляем на страницу StatisticsPage статистику:
///   -- По центру экрана добавляем Column, с 3 текстовыми виджетами:
///     --- "Won: {количество_побед}"
///     --- "Lost: {количество_поражений}"
///     --- "Draw: {количество_ничьих}"
/// - Если данных в SharedPreferences еще нет, то есть мы еще не сыграли игру с
///   таким результатом, то количество должно быть равно 0
/// - Макеты взять из Фигмы
///

void runTestLesson3Task6() {
  setUpAll(() {
    final values = <String, dynamic>{};
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return values; // set initial values here if desired
      } else if (methodCall.method.startsWith("set")) {
        values[methodCall.arguments["key"]] = methodCall.arguments["value"];
        return true;
      } else if (methodCall.method == "getInt") {
        return values[methodCall.arguments["key"]];
      }
      return null;
    });
  });

  testWidgets('module6', (WidgetTester tester) async {
    // Testing that on widget appears on the main screen
    // and appears only if there are value in SharedPreferences

    await tester.pumpWidget(MyApp());

    await _testOneCase(tester, FightResult.draw);
    await _testOneCase(tester, FightResult.won);
    await _testOneCase(tester, FightResult.lost);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int draws = 5;
    final int won = 4;
    final int lost = 10;

    await prefs.setInt("stats_${FightResult.draw.result.toLowerCase()}", draws);
    await prefs.setInt("stats_${FightResult.won.result.toLowerCase()}", won);
    await prefs.setInt("stats_${FightResult.lost.result.toLowerCase()}", lost);

    await tester.pumpAndSettle();

    await tester.tap(find.text("STATISTICS"));
    await tester.pumpAndSettle();

    _testThatWidgetsShowCorrectDataFromPrefs(tester, FightResult.draw, draws);
    _testThatWidgetsShowCorrectDataFromPrefs(tester, FightResult.lost, lost);
    _testThatWidgetsShowCorrectDataFromPrefs(tester, FightResult.won, won);
  });
}

_testThatWidgetsShowCorrectDataFromPrefs(
    final WidgetTester tester, final FightResult fightResult, final int value) {
  final resultsFinder = find.byWidgetPredicate(
    (widget) => widget is Text && widget.data != null && widget.data!.contains(fightResult.result),
  );
  expect(
    resultsFinder,
    findsOneWidget,
    reason: "There are only one widget with info about ${fightResult.result.toLowerCase()} count",
  );
  final Text text = tester.widget(resultsFinder);
  final String countText = text.data!.replaceAll("${fightResult.result}: ", "");
  final int? realCount = int.tryParse(countText);
  expect(
    realCount,
    isNotNull,
    reason: "Number near the text '${fightResult.result}: ' is int",
  );
  expect(
    realCount,
    value,
    reason: "There should be $value ${fightResult.result.toLowerCase()} at the moment",
  );
}

Future<void> _testOneCase(final WidgetTester tester, final FightResult fightResult) async {
  final startButtonFinder =
      findTypeByTextOnlyInParentType(ActionButton, "Start".toUpperCase(), Column);
  expect(
    startButtonFinder,
    findsOneWidget,
    reason: "There should be an ActionButton with text 'START' in Column",
  );

  await tester.tap(startButtonFinder);
  await tester.pumpAndSettle();

  expect(
    find.byType(FightPage),
    findsOneWidget,
    reason: "FightPage should be opened after tap on 'STATISTICS' button",
  );
  FightPageState state = tester.state(find.byType(FightPage));

  int rounds = state.enemysLives;

  while (rounds > 0) {
    final attack = generateBodyPart(
      fightResult == FightResult.lost,
      state.whatEnemyDefends,
    );

    final defend = generateBodyPart(
      fightResult == FightResult.won,
      state.whatEnemyAttacks,
    );
    await tester.tap(
      find.widgetWithText(GestureDetector, attack.name.toUpperCase()).last,
    );
    await tester.pump();

    await tester.tap(
      find.widgetWithText(GestureDetector, defend.name.toUpperCase()).first,
    );
    await tester.pump();
    await tester.tap(find.text("GO"));
    await tester.pump();
    rounds--;
  }

  await tester.pumpAndSettle();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  _testSharedPrefsFightResultField(prefs, FightResult.won, fightResult == FightResult.won);
  _testSharedPrefsFightResultField(prefs, FightResult.draw, fightResult == FightResult.draw);
  _testSharedPrefsFightResultField(prefs, FightResult.lost, fightResult == FightResult.lost);

  prefs.setInt('stats_${fightResult.result.toLowerCase()}', 0);

  await tester.tap(find.text("BACK"));
  await tester.pumpAndSettle();
}

void _testSharedPrefsFightResultField(
    final SharedPreferences prefs, final FightResult fightResult, final bool shouldBeOne) {
  expect(
    prefs.getInt('stats_${fightResult.result.toLowerCase()}'),
    shouldBeOne ? 1 : isOneOrAnother(0, null),
    reason: "SharedPreferences should have ${shouldBeOne ? "1" : "null"} "
        "in ${fightResult.result.toLowerCase()} field",
  );
}

BodyPart generateBodyPart(final bool shouldMatch, final BodyPart selectedByEnemy) {
  if (shouldMatch) {
    return selectedByEnemy;
  }
  return otherBodyPart(selectedByEnemy);
}

BodyPart otherBodyPart(final BodyPart currentBodyPart) {
  if (currentBodyPart == BodyPart.legs) {
    return BodyPart.head;
  } else if (currentBodyPart == BodyPart.head) {
    return BodyPart.torso;
  } else {
    return BodyPart.legs;
  }
}

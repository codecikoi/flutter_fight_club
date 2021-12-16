import 'package:flutter/material.dart';
import 'package:flutter_fight_club/fight_result.dart';
import 'package:flutter_fight_club/main.dart';
import 'package:flutter_fight_club/widgets/fight_result_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/container_checks.dart';
import '../shared/image_checks.dart';
import '../shared/test_helpers.dart';
import '../shared/text_checks.dart';

///
/// 5. Создать виджет на главном экране с результатами последней битвы
///    Создаем новый виджет, добавляем его на главный экран, добавляем подпись
///    над виджетом, используем знания в декорировании, полученные во время
///    занятия.
///    (3 балл - необязательное)
///
/// - Создать файл в папке widgets fight_result_widget.dart и добавить туда
///   StatelessWidget с именем FightResultWidget
/// - На вход в FightResultWidget добавить обязательный параметр fightResult
///   типа FightResult
/// - Для виджета с центральным текстом won, draw и lost использовать Container
///   с правильно настроенными параметрами
/// - Текст “Last fight result” в этот виджет не добавлять!
/// - Если в поле last_fight_result в SharedPreferences есть данные, то на
///   главном экране показывать вместо текущего текста won, draw, lost только
///   что созданный виджет и сверху над ним текст "Last fight result"
/// - Подсказка — чтобы корректно отображать FightResultWidget и текст
///   "Last fight result" возвращайте "маленький" Column с двумя виджетами.
/// - Макет смотреть в фигме. Размеры важны! Все цвета и стили текстов тоже!
///

void runTestLesson3Task5() {
  testWidgets('module5', (WidgetTester tester) async {
    // Testing that on widget appears on the main screen
    // and appears only if there are value in SharedPreferences

    await tester.pumpWidget(MyApp());

    final String text = "Last fight result";
    final lastGameResultsTextFinder = find.text(text);
    final fightResultWidgetFinder = find.byType(FightResultWidget);

    expect(
      lastGameResultsTextFinder,
      findsNothing,
      reason: "There should be no Text widget with text '$text' before we've played any rounds",
    );

    expect(
      fightResultWidgetFinder,
      findsNothing,
      reason: "There should be no FightResultWidget on MainPage before we've played any rounds",
    );

    SharedPreferences.setMockInitialValues({
      "last_fight_result": "Won",
    });

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(
      lastGameResultsTextFinder,
      findsOneWidget,
      reason: "There are should be a Text widget with text '$text'",
    );

    checkTextProperties(
      textWidget: tester.widget<Text>(lastGameResultsTextFinder),
      text: text,
      fontSize: 14,
      textColor: const Color(0xFF161616),
    );

    expect(
      fightResultWidgetFinder,
      findsOneWidget,
      reason: "There should be FightResultWidget on MainPage",
    );

    // Starting to test FightResultWidget

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FightResultWidget(fightResult: FightResult.won)),
      ),
    );

    // Testing that height of the widget set correctly

    final sizedBoxesFinder = find.descendant(
      of: find.byType(FightResultWidget),
      matching: find.byType(SizedBox),
    );
    final containersFinder = find.descendant(
      of: find.byType(FightResultWidget),
      matching: find.byType(Container),
    );
    final Iterable<SizedBox> sizedBoxes = tester.widgetList(sizedBoxesFinder);
    final Iterable<Container> containers = tester.widgetList(containersFinder);

    final Iterable<SizedBox> sizedBoxesWith140Height =
        sizedBoxes.where((element) => element.height == 140);
    final Iterable<Container> containersWith140Height =
        containers.where((element) => element.constraints == BoxConstraints.tightFor(height: 140));
    expect(
      sizedBoxesWith140Height.length + containersWith140Height.length,
      1,
      reason: "In the FightResultWidget should be one and only one widget with height 140",
    );

    // Testing that won tag at the center has correct background color

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FightResultWidget(fightResult: FightResult.won)),
      ),
    );

    final wonContainerFinder = findTypeByTextOnlyInParentType(Container, "won", Row);
    expect(
      wonContainerFinder,
      findsOneWidget,
      reason: "There should be a Container widget inside Row that have Text widget as a child",
    );

    final Container wonContainer = tester.widget(wonContainerFinder);
    checkContainerDecorationColor(
      container: wonContainer,
      color: const Color(0xFF038800),
    );

    // Testing that lost tag at the center has correct background color

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FightResultWidget(fightResult: FightResult.lost)),
      ),
    );

    final lostContainerFinder = findTypeByTextOnlyInParentType(Container, "lost", Row);
    expect(
      lostContainerFinder,
      findsOneWidget,
      reason: "There should be a Container widget inside Row that have Text widget as a child",
    );

    final Container lostContainer = tester.widget(lostContainerFinder);
    checkContainerDecorationColor(
      container: lostContainer,
      color: const Color(0xFFEA2C2C),
    );

    // Testing that lost tag at the center has correct background color

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FightResultWidget(fightResult: FightResult.draw)),
      ),
    );

    final drawContainerFinder = findTypeByTextOnlyInParentType(Container, "draw", Row);
    expect(
      drawContainerFinder,
      findsOneWidget,
      reason: "There should be a Container widget inside Row that have Text widget as a child",
    );

    final Container drawContainer = tester.widget(drawContainerFinder);
    checkContainerDecorationColor(
      container: drawContainer,
      color: const Color(0xFF1C79CE),
    );

    // Testing that container has correct border radius

    checkContainerDecorationBorderRadius(
      container: drawContainer,
      borderRadius: BorderRadius.circular(22),
    );

    //Testing that Text with 'draw' has correct style

    final drawTextFinder = find.text("draw");
    expect(drawTextFinder, findsOneWidget);

    final Text drawText = tester.widget(drawTextFinder);
    checkTextProperties(
      textWidget: drawText,
      text: "draw",
      fontSize: 16,
      textColor: Colors.white,
    );

    // Testing that avatars has correct sized and sources

    final String youAvatarPath = "assets/images/you-avatar.png";
    final String enemyAvatarPath = "assets/images/enemy-avatar.png";
    final youImageFinder = find.descendant(
      of: find.descendant(
        of: find.byType(FightResultWidget),
        matching: find.ancestor(
          of: find.text("You"),
          matching: find.byType(Column),
        ),
      ),
      matching: find.byType(Image),
    );
    expect(
      youImageFinder,
      findsOneWidget,
      reason: "There should be an Image with you avatar inside Column",
    );
    final Image youImage = tester.widget(youImageFinder);
    checkImageProperties(
      image: youImage,
      height: 92,
      width: 92,
      imageProvider: AssetImage(youAvatarPath),
    );

    final enemyImageFinder = find.descendant(
      of: find.descendant(
        of: find.byType(FightResultWidget),
        matching: find.ancestor(
          of: find.text("Enemy"),
          matching: find.byType(Column),
        ),
      ),
      matching: find.byType(Image),
    );
    expect(
      enemyImageFinder,
      findsOneWidget,
      reason: "There should be an Image with enemy avatar inside Column",
    );
    final Image enemyImage = tester.widget(enemyImageFinder);
    checkImageProperties(
      image: enemyImage,
      height: 92,
      width: 92,
      imageProvider: AssetImage(enemyAvatarPath),
    );
  });
}

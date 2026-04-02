import 'package:flutter_test/flutter_test.dart';

import 'package:todo/main.dart';

void main() {
  testWidgets('Todo app renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Todo App'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}

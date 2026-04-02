import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo/data/services/todo_local_storage.dart';
import 'package:todo/main.dart';

void main() {
  testWidgets('Todo app renders empty state on first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storageService = await TodoLocalStorageService.create();

    await tester.pumpWidget(TodoApp(storageService: storageService));
    await tester.pumpAndSettle();

    expect(find.text('Todo Flow'), findsOneWidget);
    expect(find.text('Create your first task'), findsOneWidget);
    expect(find.text('Add Task'), findsOneWidget);
  });
}

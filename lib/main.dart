import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/todo_local_storage.dart';
import 'presentation/controllers/todo_controller.dart';
import 'presentation/screens/todo_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await TodoLocalStorageService.create();
  runApp(TodoApp(storageService: storageService));
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.storageService});

  final TodoLocalStorageService storageService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoController(storageService)..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo Flow',
        theme: AppTheme.lightTheme,
        home: const TodoHomeScreen(),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svg_editor/screen/svg_editor_screen.dart';
import 'package:svg_editor/service/svg_editor_service.dart';
import 'package:svg_editor/utils/app_theme.dart' show AppTheme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SvgEditorProvider(),
      child: MaterialApp(
        title: 'SVG Color Editor',
        theme: AppTheme.lightTheme,
        home: const SvgEditorScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

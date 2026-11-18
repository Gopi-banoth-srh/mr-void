import 'package:material_ui/material_ui.dart';
import 'package:mr_void/targets_screen.dart';

void main() {
  runApp(const MrVoidApp());
}

class MrVoidApp extends StatelessWidget {
  const MrVoidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MR VOID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      home: const TargetsScreen(),
    );
  }
}
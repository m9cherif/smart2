import 'package:flutter/material.dart';

import 'package:smart_student_ai/home_screen.dart';

class LaunchGate extends StatelessWidget {
  const LaunchGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen(key: ValueKey('home'));
  }
}

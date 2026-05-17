import 'package:flutter_test/flutter_test.dart';
import 'package:focusflow/main.dart';
import 'package:focusflow/providers/pomodoro_provider.dart';
import 'package:focusflow/providers/task_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('FocusFlow renders the dashboard title', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        ],
        child: const FocusFlowApp(),
      ),
    );

    expect(find.text('FocusFlow'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}

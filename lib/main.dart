import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/local_repository.dart';
import 'data/practice_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(repo: await LocalRepository.open(), practice: LocalPracticeService());
  runApp(ChangeNotifierProvider.value(value: state, child: const ConfidenceLabApp()));
  await state.load();
}

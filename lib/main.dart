import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'routing/router.dart';
import 'core/app_state.dart';

import 'data/profile_service.dart';
import 'data/reminders_service.dart';
import 'data/analysis_service.dart';
import 'data/community_service.dart';
import 'data/vault_service.dart';
import 'data/roadmap_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await ProfileService.init();
  await RemindersService.init();
  await AnalysisService.init();
  await CommunityService.init();
  await VaultService.init();
  await RoadmapService.init();
  runApp(const SafeaApp());
}

class SafeaApp extends StatelessWidget {
  const SafeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            title: 'Safea',
            theme: AppTheme.darkTheme,
            routerConfig: createRouter(appState),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

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

  final profileService = ProfileService();
  await profileService.init();

  final remindersService = RemindersService();
  await remindersService.init();

  final analysisService = AnalysisService();
  await analysisService.init();

  final communityService = CommunityService();
  await communityService.init();

  final vaultService = VaultService();
  await vaultService.init();

  final roadmapService = RoadmapService();
  await roadmapService.init();

  runApp(SafeaApp(
    profileService: profileService,
    remindersService: remindersService,
    analysisService: analysisService,
    communityService: communityService,
    vaultService: vaultService,
    roadmapService: roadmapService,
  ));
}

class SafeaApp extends StatelessWidget {
  final ProfileService profileService;
  final RemindersService remindersService;
  final AnalysisService analysisService;
  final CommunityService communityService;
  final VaultService vaultService;
  final RoadmapService roadmapService;

  const SafeaApp({
    super.key,
    required this.profileService,
    required this.remindersService,
    required this.analysisService,
    required this.communityService,
    required this.vaultService,
    required this.roadmapService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider.value(value: profileService),
        ChangeNotifierProvider.value(value: remindersService),
        ChangeNotifierProvider.value(value: analysisService),
        ChangeNotifierProvider.value(value: communityService),
        ChangeNotifierProvider.value(value: vaultService),
        ChangeNotifierProvider.value(value: roadmapService),
      ],
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

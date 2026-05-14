import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/secure_vault_service.dart';
import 'services/point_notifier.dart';
import 'ui_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure vault for encrypted storage
  await SecureVaultService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointNotifier()..loadPoints()),
      ],
      child: const SafeaAppDemo(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// removed: import 'package:provider/provider.dart' as provider;
// removed: import 'providers/app_state_provider.dart';

import 'package:intl/date_symbol_data_local.dart';
// removed: import 'providers/stock_provider.dart';
// removed: import 'providers/service_history_provider.dart';
// removed: import 'providers/device_provider.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'core/providers/firebase_providers.dart';
import 'screens/home_page.dart';

// removed: import 'repositories/forms_repository.dart';
// removed: import 'domain/repositories/device_repository.dart';
// removed: import 'domain/repositories/service_history_repository.dart';
// removed: import 'domain/repositories/stock_part_repository.dart';
// removed: import 'domain/repositories/forms_repository.dart';
// removed: import 'repositories/firestore_device_repository_v2.dart';
// removed: import 'repositories/firestore_service_history_repository_v2.dart';
// removed: import 'repositories/firestore_stock_repository_v2.dart';
// removed: import 'repositories/forms_repository_v2.dart';
// removed: import 'repositories/adapters/device_repository_adapter.dart';
// removed: import 'repositories/adapters/service_history_repository_adapter.dart';
// removed: import 'repositories/adapters/stock_part_repository_adapter.dart';
// removed: import 'repositories/adapters/forms_repository_adapter.dart';
// removed: import 'models/device.dart';
// removed: import 'models/service_history.dart';
// removed: import 'models/stock_part.dart';

const bool kUseEmulators = bool.fromEnvironment('USE_EMULATORS', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('tr_TR', null);
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  if (kUseEmulators) {
    final host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(rp.ProviderScope(child: const MyApp()));
}

class MyApp extends rp.ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(appSettingsProvider).themeMode,
      home: ref.watch(authUserChangesProvider).when(
        data: (user) => user != null ? const HomePage() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}

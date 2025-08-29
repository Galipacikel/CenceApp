import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'core/providers/firebase_providers.dart';
import 'package:cence_app/features/home/presentation/screens/home_page.dart';
import 'package:cence_app/features/auth/presentation/screens/login_screen.dart';

import 'package:provider/provider.dart' as provider;
import 'providers/app_state_provider.dart';
import 'providers/device_provider.dart';
import 'providers/service_history_provider.dart';

import 'repositories/firestore_device_repository_v2.dart';
import 'repositories/firestore_service_history_repository_v2.dart';

const bool kUseEmulators = bool.fromEnvironment(
  'USE_EMULATORS',
  defaultValue: false,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('tr_TR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kUseEmulators) {
    // Eğer derleme zamanında --dart-define=USE_EMULATORS=true geçilirse
    // Firebase servisleri yerel emülatörlere yönlenir. Web/Prod’da false bırakın.
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    rp.ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider<AppStateProvider>(
            create: (_) => AppStateProvider(),
          ),
          provider.ChangeNotifierProvider<DeviceProvider>(
            create: (_) => DeviceProvider(
              repository: FirestoreDeviceRepositoryV2(),
            ),
          ),
          provider.ChangeNotifierProvider<ServiceHistoryProvider>(
            create: (_) => ServiceHistoryProvider(
              repository: FirestoreServiceHistoryRepositoryV2(),
            ),
          ),

        ],
        child: const MyApp(),
      ),
    ),
  );
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
      supportedLocales: const [Locale('tr', 'TR')],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(appSettingsProvider).themeMode,
      home: ref
          .watch(authUserChangesProvider)
          .when(
            data: (user) =>
                user != null ? const HomePage() : const LoginScreen(),
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const LoginScreen(),
          ),
    );
  }
}

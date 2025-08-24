import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart' as provider;
import 'providers/app_state_provider.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'providers/stock_provider.dart';
import 'providers/service_history_provider.dart';
// import 'models/service_history.dart';
import 'providers/device_provider.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;

import 'repositories/forms_repository.dart';
// V2 domain repository arayüzleri
import 'domain/repositories/device_repository.dart';
import 'domain/repositories/service_history_repository.dart';
import 'domain/repositories/stock_part_repository.dart';
import 'domain/repositories/forms_repository.dart';
// V2 Firestore implementasyonları
import 'repositories/firestore_device_repository_v2.dart';
import 'repositories/firestore_service_history_repository_v2.dart';
import 'repositories/firestore_stock_repository_v2.dart';
import 'repositories/forms_repository_v2.dart';
// Adapters to bridge V1 UI to V2 repositories
import 'repositories/adapters/device_repository_adapter.dart';
import 'repositories/adapters/service_history_repository_adapter.dart';
import 'repositories/adapters/stock_part_repository_adapter.dart';
import 'repositories/adapters/forms_repository_adapter.dart';
import 'models/device.dart';
import 'models/service_history.dart';
import 'models/stock_part.dart';
// USE_EMULATORS=true ile derlendiğinde Firebase servislerini yerel emülatörlere yönlendirir
const bool kUseEmulators = bool.fromEnvironment('USE_EMULATORS', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('tr_TR', null);
  // iOS/Android'de platform konfigürasyon dosyalarını kullan (google-services.json / GoogleService-Info.plist)
  // Web ve macOS'ta firebase_options.dart değerleriyle başlat.
  if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  // Emülatör kullanımını etkinleştir
  if (kUseEmulators) {
    final host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
    // Firestore
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    // Auth
    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    // Storage (kullanılıyorsa)
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(rp.ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        // V1 UI -> V2 repository bridge via adapters
        provider.Provider<DeviceRepository>(
          create: (_) => DeviceRepositoryAdapter(FirestoreDeviceRepositoryV2()),
        ),
        provider.Provider<ServiceHistoryRepository>(
          create: (_) => ServiceHistoryRepositoryAdapter(FirestoreServiceHistoryRepositoryV2()),
        ),
        provider.Provider<StockPartRepository>(
          create: (_) => StockPartRepositoryAdapter(FirestoreStockRepositoryV2()),
        ),
        provider.Provider<FormsRepositoryBase>(
          create: (_) => FormsRepositoryAdapter(FormsRepositoryV2Impl()),
        ),
         // V2 repository provider kayıtları
         provider.Provider<DeviceRepositoryV2>(create: (_) => FirestoreDeviceRepositoryV2()),
         provider.Provider<ServiceHistoryRepositoryV2>(create: (_) => FirestoreServiceHistoryRepositoryV2()),
         provider.Provider<StockPartRepositoryV2>(create: (_) => FirestoreStockRepositoryV2()),
         provider.Provider<FormsRepositoryV2>(create: (_) => FormsRepositoryV2Impl()),
         provider.ChangeNotifierProvider(create: (_) => AppStateProvider()..initAuth()),
        provider.ChangeNotifierProvider(
          create: (ctx) => StockProvider(repository: ctx.read<StockPartRepositoryV2>()),
        ),
        provider.ChangeNotifierProvider(
          create: (ctx) => ServiceHistoryProvider(repository: ctx.read<ServiceHistoryRepositoryV2>()),
        ),
        provider.ChangeNotifierProvider(
          create: (ctx) => DeviceProvider(repository: ctx.read<DeviceRepositoryV2>()),
        ),
      ],
      child: MaterialApp(
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
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}

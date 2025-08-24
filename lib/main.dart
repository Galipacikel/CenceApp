import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => ServiceHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

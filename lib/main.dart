import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'providers/stock_provider.dart';
import 'providers/service_history_provider.dart';
import 'models/service_history.dart';
import 'providers/device_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await Firebase.initializeApp();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => ServiceHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()), // <-- EKLENDİ
      ],
      child: Builder(
        builder: (context) {
          // Mock veriyi provider'a yükle
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final mockList = await MockServiceHistoryRepository().getAll();
            Provider.of<ServiceHistoryProvider>(context, listen: false).loadMockData(mockList);
          });
          return Consumer<AppStateProvider>(
            builder: (context, appState, _) {
              return MaterialApp(
                title: 'Cence App',
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: appState.appSettings.themeMode,
                home: const LoginScreen(),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('tr', 'TR'),
                  Locale('en', 'US'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

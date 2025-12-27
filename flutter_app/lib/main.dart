import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/main_screen.dart';
import 'screens/doctor/doctor_main_screen.dart';
import 'screens/pharmacist/pharmacist_main_screen.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/common/api_config_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          Widget homeScreen;
          if (appState.isAuthenticated) {
            if (appState.isDoctor) {
              homeScreen = const DoctorMainScreen();
            } else if (appState.isPharmacist) {
              homeScreen = const PharmacistMainScreen();
            } else {
              homeScreen = const MainScreen();
            }
          } else {
            homeScreen = const LoginScreen();
          }
          
          return MaterialApp(
            title: 'Rural Health Connect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            locale: appState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
              Locale('mr'), // Marathi
              Locale('pa'), // Punjabi
            ],
            navigatorObservers: [ApiConfigOverlay()],
            builder: (context, child) {
              // Add overlay entry after MaterialApp is built
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ApiConfigOverlay.addOverlay(context);
              });
              return child ?? const SizedBox();
            },
            home: homeScreen,
          );
        },
      ),
    );
  }
}

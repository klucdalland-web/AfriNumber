import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/localization_service.dart';
import 'core/services/firebase_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialisation Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error\n$stackTrace');
  }

  // Handler FCM background (doit être enregistré avant runApp)
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (error, stackTrace) {
    debugPrint('FCM handler registration failed: $error\n$stackTrace');
  }

  await GetStorage.init();

  runApp(const AfriNumberApp());
}

class AfriNumberApp extends StatelessWidget {
  const AfriNumberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AfriNumber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),
      locale: LocalizationService.currentLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
    );
  }
}

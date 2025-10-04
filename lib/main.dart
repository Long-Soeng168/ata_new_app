import 'package:ata_new_app/pages/main_page.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:ata_new_app/themes/light_mode.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('km'),
      ],
      path: 'lib/assets/translations', // ⚡ don't put "lib/" here
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => CartProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,

      // 👇 these 3 are REQUIRED for translations to switch
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      home: const MainPage(),
    );
  }
}

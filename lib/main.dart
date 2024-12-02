import 'package:ata_new_app/pages/main_page.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:ata_new_app/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MyApp(),
    ),
  );
}
// Set [isPersistenceSupportEnabled] to true to turn on the cart persistence
  //  void main() async {
  //    WidgetsFlutterBinding.ensureInitialized();
  //    var cart = FlutterCart();
  //    await cart.initializeCart(isPersistenceSupportEnabled: true);
  //    runApp(
  //   ChangeNotifierProvider(
  //     create: (_) => CartProvider(),
  //     child: MyApp(),
  //   ),
  // );
  //  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: const MainPage(),
    );
  }
}


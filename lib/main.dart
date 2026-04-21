import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kathoram_app/local_storage/shared_pref.dart';
import 'package:kathoram_app/routes/route_pages.dart';
import 'package:kathoram_app/routes/route_path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RoutePath.splash,
      getPages: RoutePages.routes,
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather_app/city_location_page.dart';
import 'package:weather_app/weather_page.dart';

import 'first_time_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await EasyLocalization.ensureInitialized();

  final isFirstTime = await FirstTimeChecker.isFirstTime();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  initializeDateFormatting('zh_CN', null).then((_) {
    runApp(WeatherApp(isFirstTime: isFirstTime));
  });
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key, required this.isFirstTime});

  final bool isFirstTime;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isFirstTime ? const CityLocationPage() : const WeatherPage(),
      initialRoute: '/',
      routes: {
        '/weather_page': (context) => const WeatherPage(),
        '/city_location_page': (context) => const CityLocationPage(),
      },
    );
  }
}

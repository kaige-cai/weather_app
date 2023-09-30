import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './util.dart';
import './weather_data.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  BannerAd? _bannerAd;

  final String _adUnitId =
      Platform.isAndroid ? 'ca-app-pub-9275143816186195/7092152699' : '';

  double longitude = 0.0;
  double latitude = 0.0;
  String address = '';
  String pois = '';

  @override
  void initState() {
    super.initState();
    loadData();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<WeatherData> _fetchWeatherData({
    required double longitude,
    required double latitude,
  }) async {
    try {
      Dio dio = Dio();
      final Map<String, dynamic> queryParams = {
        'location': '$longitude,$latitude',
        'key': 'a008fc18ddda40558ce9df9f3a14508e',
        'lang': 'zh',
        'unit': 'm',
      };

      Response response = await dio.get(
        'https://api.qweather.com/v7/grid-weather/now',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        WeatherData weatherData = WeatherData.fromJson(data);
        return weatherData;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }
    // 如果出现错误或异常，返回一个默认的 WeatherData 对象，或者根据您的需求返回适当的默认值
    return WeatherData(
      code: '',
      updateTime: '',
      fxLink: '',
      now: NowData(
        obsTime: '',
        temp: '',
        feelsLike: '',
        icon: '',
        text: '',
        wind360: '',
        windDir: '',
        windScale: '',
        windSpeed: '',
        humidity: '',
        precip: '',
        pressure: '',
        cloud: '',
        dew: '',
      ),
      refer: Refer(
        sources: [],
        license: [],
      ),
    );
  }

  // 存储数据
  void saveData(
    double longitude,
    double latitude,
    String address,
    String pois,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('longitude', longitude);
    await prefs.setDouble('latitude', latitude);
    await prefs.setString('address', address);
    await prefs.setString('pois', pois);
  }

  // 检索数据
  Future<Map<String, dynamic>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedLongitude = prefs.getDouble('longitude') ?? 0.0;
    final loadedLatitude = prefs.getDouble('latitude') ?? 0.0;
    final loadedAddress = prefs.getString('address') ?? '';
    final loadedPois = prefs.getString('pois') ?? '';

    // 更新类成员变量
    setState(() {
      longitude = loadedLongitude;
      latitude = loadedLatitude;
      address = loadedAddress;
      pois = loadedPois;
    });

    return {
      'longitude': loadedLongitude,
      'latitude': loadedLatitude,
      'address': loadedAddress,
      'pois': loadedPois,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      longitude = args['longitude'];
      latitude = args['latitude'];
      address = args['address'];
      pois = args['pois'];
      // 存储数据到SharedPreferences
      saveData(longitude, latitude, address, pois);
    }

    return Scaffold(
      body: FutureBuilder<WeatherData>(
        future: _fetchWeatherData(longitude: longitude, latitude: latitude),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            WeatherData weatherData = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Column(
                  children: [
                    Text(pois),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      '/city_location_page',
                    );
                  },
                  icon: const Icon(CupertinoIcons.add),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.location_solid),
                  )
                ],
              ),
              body: Stack(
                children: [
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        child: SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('天气：${weatherData.now.text}'),
                        Text('温度：${weatherData.now.temp}°C'),
                        Text('湿度：${weatherData.now.humidity}%'),
                        Text('风力：${weatherData.now.windScale}级'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('没有数据'),
            );
          }
        },
      ),
    );
  }
}

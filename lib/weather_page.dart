import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:weather_app/weather_data.dart';

import 'main.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  late Future<WeatherData> _weatherDataFuture;
  BannerAd? _bannerAd;

  final String _adUnitId =
      Platform.isAndroid ? 'ca-app-pub-9275143816186195/7092152699' : '';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _weatherDataFuture = _fetchWeatherData();
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

  Future<WeatherData> _fetchWeatherData() async {
    try {
      Dio dio = Dio();
      final Map<String, dynamic> queryParams = {
        'location': '118.149635,33.783051',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<WeatherData>(
        future: _weatherDataFuture,
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
                title: const Column(
                  children: [
                    Text('陈宝庄'),
                    Text(
                      '中国江苏省徐州市睢宁县凌城镇孙薛村',
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/city_location_page');
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
            // 在连接状态为 done 但没有数据时显示一个默认视图
            return const Center(
              child: Text('没有数据'),
            );
          }
        },
      ),
    );
  }
}

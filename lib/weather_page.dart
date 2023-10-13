import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart' show BMFMapSDK;
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/data.dart';
import 'package:weather_app/model/air_quality_daily_data.dart';
import 'package:weather_app/model/weather_hourly_data.dart';

import './util.dart';
import 'model/air_quality_now_data.dart';
import 'model/weather_daily3_data.dart';
import 'model/weather_month_data.dart';
import 'model/weather_now_data.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  BannerAd? _bannerAd;

  final String _adUnitId = Platform.isAndroid ? 'ca-app-pub-9275143816186195/7092152699' : '';

  double longitude = 0.0;
  double latitude = 0.0;
  String address = '';
  String pois = '';

  BaiduLocation _locationResult = BaiduLocation();
  final LocationFlutterPlugin _locPlugin = LocationFlutterPlugin();

  @override
  void initState() {
    super.initState();
    loadData();
    _loadBannerAd();
    requestPermission();
    _locPlugin.setAgreePrivacy(true);
    BMFMapSDK.setAgreePrivacy(true);
    // 接受定位回调
    _locPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
      setState(() {
        _locationResult = result;
        if (result.address!.isNotEmpty) {
          _stopLocation();
        }
      });
    });
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
    _stopLocation();
    super.dispose();
  }

  Future<WeatherNowData> _fetchNowWeatherData({
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
        WeatherNowData weatherData = WeatherNowData.fromJson(data);
        return weatherData;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 WeatherData 对象
    return WeatherNowData(
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

  Future<WeatherDaily3Data> _fetchDailyWeatherData({
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
        'https://api.qweather.com/v7/grid-weather/3d',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        WeatherDaily3Data weatherData = WeatherDaily3Data.fromJson(data);
        return weatherData;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 WeatherData 对象
    return WeatherDaily3Data(
      code: '',
      updateTime: '',
      fxLink: '',
      daily: <DailyForecast>[],
      refer: DailyRefer(
        sources: [],
        license: [],
      ),
    );
  }

  Future<WeatherMonthData> _fetchMonthWeatherData({
    required double longitude,
    required double latitude,
  }) async {
    if (longitude == 0.0 || latitude == 0.0) {
      longitude = -74.18819;
      latitude = 42.93869;
    }

    try {
      Dio dio = Dio();

      final Map<String, dynamic> queryParams = {
        'location': '$longitude,$latitude',
        'key': 'a008fc18ddda40558ce9df9f3a14508e',
        'lang': 'zh',
        'unit': 'm',
      };

      Response response = await dio.get(
        'https://api.qweather.com/v7/weather/30d',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        WeatherMonthData weatherData = WeatherMonthData.fromJson(data);
        return weatherData;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 WeatherMonthData 对象
    return WeatherMonthData(
      code: '',
      updateTime: '',
      fxLink: '',
      daily: <DailyWeather>[],
      refer: MonthRefer(
        sources: [],
        license: [],
      ),
    );
  }

  Future<WeatherHourlyData> _fetchHourlyWeatherData({
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
        'https://api.qweather.com/v7/grid-weather/24h',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        WeatherHourlyData weatherData = WeatherHourlyData.fromJson(data);
        return weatherData;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 WeatherHourlyData 对象
    return WeatherHourlyData(
      code: '',
      updateTime: '',
      fxLink: '',
      hourly: <HourlyData>[],
      refer: HourlyRefer(
        sources: [],
        license: [],
      ),
    );
  }

  Future<AirQualityDaily> _fetchAirQualityDailyData({
    required double longitude,
    required double latitude,
  }) async {
    try {
      Dio dio = Dio();

      final Map<String, dynamic> queryParams = {
        'location': '$longitude,$latitude',
        'key': 'a008fc18ddda40558ce9df9f3a14508e',
        'lang': 'zh',
      };

      Response response = await dio.get(
        'https://api.qweather.com/v7/air/5d',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        if (data['code'] != '200') {
          return AirQualityDaily(
            code: '',
            updateTime: '',
            fxLink: '',
            daily: List.generate(
              5,
              (index) => AirQualityData(
                fxDate: '',
                aqi: '0',
                level: '',
                category: 'N/A',
                primary: '',
              ),
            ),
            refer: AirQualityDailyRefer(
              sources: [],
              license: [],
            ),
          );
        }
        AirQualityDaily airQualityDaily = AirQualityDaily.fromJson(data);
        return airQualityDaily;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 AirQualityDaily 对象
    return AirQualityDaily(
      code: '',
      updateTime: '',
      fxLink: '',
      daily: <AirQualityData>[],
      refer: AirQualityDailyRefer(
        sources: [],
        license: [],
      ),
    );
  }

  Future<AirQuality> _fetchAirQualityNowData({
    required double longitude,
    required double latitude,
  }) async {
    try {
      Dio dio = Dio();

      final Map<String, dynamic> queryParams = {
        'location': '$longitude,$latitude',
        'key': 'a008fc18ddda40558ce9df9f3a14508e',
        'lang': 'zh',
      };

      Response response = await dio.get(
        'https://api.qweather.com/v7/air/now',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        if (data['code'] != '200') {
          return AirQuality(
            code: '',
            updateTime: '',
            fxLink: '',
            now: AirQualityNow(
                pubTime: '',
                aqi: '0',
                level: '',
                category: 'N/A',
                primary: '',
                pm10: '',
                pm2p5: '',
                no2: '',
                so2: '',
                co: '',
                o3: ''),
            refer: AirQualityNowRefer(
              sources: [],
              license: [],
            ),
          );
        }
        AirQuality airQuality = AirQuality.fromJson(data);
        return airQuality;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 AirQuality 对象
    return AirQuality(
      code: '',
      updateTime: '',
      fxLink: '',
      now: AirQualityNow(
          pubTime: '',
          aqi: '',
          level: '',
          category: '',
          primary: '',
          pm10: '',
          pm2p5: '',
          no2: '',
          so2: '',
          co: '',
          o3: ''),
      refer: AirQualityNowRefer(
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('longitude', longitude);
    await prefs.setDouble('latitude', latitude);
    await prefs.setString('address', address);
    await prefs.setString('pois', pois);
  }

  // 检索数据
  Future<Map<String, dynamic>> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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

  Widget _weatherRiveAnimation({required String status, required String iconCode}) {
    switch (status) {
      case '晴':
        return Transform.scale(
          scale: 1.3,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '100' ? RiveFiles.sunnyDay : RiveFiles.sunnyDay,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '多云':
      case '少云':
      case '晴间多云':
        return Transform.scale(
          scale: 2.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '101' ? RiveFiles.cloudyDay : RiveFiles.cloudyDay,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '阴':
        return Transform.scale(
          scale: 1.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '100' ? RiveFiles.cloudy : RiveFiles.cloudy,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '雨':
      case '阵雨':
      case '强阵雨':
      case '雷阵雨':
      case '强雷阵雨':
      case '雷阵雨伴有冰雹':
      case '小雨':
      case '中雨':
      case '大雨':
      case '极端降雨':
      case '毛毛雨/细雨':
      case '暴雨':
      case '大暴雨':
      case '特大暴雨':
      case '冻雨':
      case '小到中雨':
      case '中到大雨':
      case '大到暴雨':
      case '暴雨到大暴雨':
      case '大暴雨到特大暴雨':
        return Transform.scale(
          scale: 1.3,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '399' ? RiveFiles.rainDayH : RiveFiles.rainDayH,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '雪':
      case '小雪':
      case '中雪':
      case '大雪':
      case '暴雪':
      case '雨夹雪':
      case '雨雪天气':
      case '阵雨夹雪':
      case '阵雪':
      case '小到中雪':
      case '中到大雪':
      case '大到暴雪':
        return Transform.scale(
          scale: 1.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '499' ? RiveFiles.snow : RiveFiles.snow,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '雾':
      case '薄雾':
      case '浓雾':
      case '强浓雾':
      case '大雾':
      case '特强浓雾':
      case '霾':
      case '中度霾':
      case '重度霾':
      case '严重霾':
        return Transform.scale(
          scale: 1.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '499' ? RiveFiles.cloudyDay : RiveFiles.cloudyDay,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '扬沙':
      case '浮尘':
      case '沙尘暴':
      case '强沙尘暴':
        return Transform.scale(
          scale: 1.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '499' ? RiveFiles.cloudyDay : RiveFiles.cloudyDay,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '热':
        return Transform.scale(
          scale: 1.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '499' ? RiveFiles.hot : RiveFiles.hot,
              fit: BoxFit.contain,
            ),
          ),
        );
      case '冷':
        return Transform.scale(
          scale: 1.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '499' ? RiveFiles.cold : RiveFiles.cold,
              fit: BoxFit.contain,
            ),
          ),
        );
      default:
        return Transform.scale(
          scale: 2.0,
          child: SizedBox(
            width: 320.0,
            height: 320.0,
            child: RiveAnimation.network(
              iconCode == '101' ? RiveFiles.cloudyDay : RiveFiles.cloudyDay,
              fit: BoxFit.contain,
            ),
          ),
        );
    }
  }

  void showLoadingDialog(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: true, // 允许点击外部关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 调整此值以更改圆角半径
          ),
          title: const LoadingTextAnimation(), // 等待中...动画文本
        );
      },
    );

    // 模拟定位完成后，关闭对话框
    await Future.delayed(const Duration(seconds: 2));
    if (_locationResult.address != null) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      longitude = args['longitude'] ?? 0.0;
      latitude = args['latitude'] ?? 0.0;
      address = args['address'] ?? '';
      pois = args['pois'] ?? '';
      // 存储数据到SharedPreferences
      saveData(longitude, latitude, address, pois);
    }

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _fetchNowWeatherData(longitude: longitude, latitude: latitude),
          _fetchDailyWeatherData(longitude: longitude, latitude: latitude),
          _fetchAirQualityDailyData(longitude: longitude, latitude: latitude),
          _fetchAirQualityNowData(longitude: longitude, latitude: latitude),
          _fetchHourlyWeatherData(longitude: longitude, latitude: latitude),
          _fetchMonthWeatherData(longitude: longitude, latitude: latitude),
        ]),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            List<dynamic>? results = snapshot.data;

            WeatherNowData weathernowData = results?[0];
            WeatherDaily3Data dailyData = results?[1];
            AirQualityDaily airQualityDaily = results?[2];
            AirQuality airQuality = results?[3];
            WeatherHourlyData hourlyData = results?[4];
            WeatherMonthData monthData = results?[5];

            String dateString = weathernowData.updateTime.substring(
              0,
              weathernowData.updateTime.indexOf('+'),
            );
            DateTime dateTime = DateTime.parse(dateString);
            DateFormat dateFormat = DateFormat('y年MM月dd日 ah:mm ', 'zh_CN'); // 创建一个格式化器
            String formattedDate = dateFormat.format(dateTime); // 格式化日期时间

            final List<String> weatherInfo = generateWeatherInfo(weathernowData);

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
                  icon: const Icon(CupertinoIcons.add),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      '/city_location_page',
                    );
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.location_solid),
                    onPressed: () async {
                      setState(() {
                        showLoadingDialog(context);
                      });

                      final NavigatorState navigator = Navigator.of(context);

                      _locationAction();
                      _startLocation();

                      setState(() {
                        longitude = _locationResult.longitude ?? 0.0;
                        latitude = _locationResult.latitude ?? 0.0;
                        address = _locationResult.address ?? '正在定位...';
                        pois = _locationResult.pois?[1].name ?? '请重试...';

                        if (pois.isNotEmpty && pois != '请重试...') {
                          _stopLocation();
                        }
                      });

                      if (_locationResult.address != null) {
                        await _fetchNowWeatherData(longitude: longitude, latitude: latitude);
                        await _fetchDailyWeatherData(longitude: longitude, latitude: latitude);
                        await _fetchAirQualityDailyData(longitude: longitude, latitude: latitude);
                        await _fetchAirQualityNowData(longitude: longitude, latitude: latitude);
                        await _fetchHourlyWeatherData(longitude: longitude, latitude: latitude);
                        await _fetchMonthWeatherData(longitude: longitude, latitude: latitude);
                      }

                      await navigator.pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return const WeatherPage();
                          },
                          transitionDuration: const Duration(seconds: 0), // 设置过渡时间为0秒
                        ),
                      );

                      if (_locationResult.address != null) {
                        _stopLocation();
                      }

                      saveData(longitude, latitude, address, pois);
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _fetchNowWeatherData(longitude: longitude, latitude: latitude);
                    _fetchDailyWeatherData(longitude: longitude, latitude: latitude);
                    _fetchAirQualityDailyData(longitude: longitude, latitude: latitude);
                    _fetchAirQualityNowData(longitude: longitude, latitude: latitude);
                    _fetchHourlyWeatherData(longitude: longitude, latitude: latitude);
                    _fetchMonthWeatherData(longitude: longitude, latitude: latitude);
                  });
                },
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification? overscroll) {
                    overscroll?.disallowIndicator();
                    return true;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '数据更新时间：$formattedDate',
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                      _weatherRiveAnimation(
                        status: weathernowData.now.text,
                        iconCode: weathernowData.now.icon,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${weathernowData.now.temp}°C',
                            style: const TextStyle(
                              fontSize: 115.0,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          SizedBox(
                            width: 180.0,
                            child: Center(
                              child: Text(
                                weathernowData.now.text,
                                style: TextStyle(
                                  fontSize: weathernowData.now.text.length <= 2 ? 100.0 : 50.0,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        height: 169.0,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 2 / 1,
                          ),
                          itemCount: weatherInfo.length + 1,
                          itemBuilder: (context, index) {
                            if (index == weatherInfo.length) {
                              return Card(
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                color: getAqiColor(int.parse(airQuality.now.aqi)),
                                child: Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '空气质量：\n${airQuality.now.category}'
                                      '   '
                                      '${airQuality.now.aqi}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Card(
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    child: Text(weatherInfo[index]),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        height: 120.0,
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final dailyWeatherData = dailyData.daily[index];
                            final airQualityDailyData = airQualityDaily.daily[index];

                            String status = dailyWeatherData.textDay == dailyWeatherData.textNight
                                ? dailyWeatherData.textDay
                                : '${dailyWeatherData.textDay}转${dailyWeatherData.textNight}';

                            String day;
                            switch (index) {
                              case 0:
                                day = '今天';
                                break;
                              case 1:
                                day = '明天';
                                break;
                              case 2:
                                day = '后天';
                                break;
                              default:
                                day = ''; // 在实际使用中处理超出范围的情况
                                break;
                            }
                            return DailyForecastCard(
                              day: day,
                              status: status,
                              temp: '${dailyWeatherData.tempMin}~${dailyWeatherData.tempMax}',
                              aqi: airQualityDailyData.aqi,
                              lv: airQualityDailyData.category,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '24小时预报',
                              style: TextStyle(fontSize: 30.0),
                            ),
                            const SizedBox(width: 100.0),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.sunrise, size: 15.0),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${monthData.daily[0].sunrise} ',
                                  style: const TextStyle(height: 1.8),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.sunset, size: 15.0),
                                const SizedBox(width: 4.0),
                                Text(
                                  monthData.daily[0].sunset,
                                  style: const TextStyle(height: 1.8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      HourlyChart(data: hourlyData.hourly),
                      const Row(
                        children: [
                          SizedBox(width: 16.0),
                          Text(
                            '30日预报',
                            style: TextStyle(fontSize: 30.0),
                          ),
                        ],
                      ),
                      MonthChart(data: monthData.daily),
                      const SizedBox(height: 120.0),
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
                    ],
                  ),
                ),
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

  // 启动定位
  Future<void> _startLocation() async {
    await _locPlugin.startLocation();
  }

  // 设置android端和ios端定位参数
  void _locationAction() async {
    Map iosMap = _initIOSOptions().getMap();
    Map androidMap = _initAndroidOptions().getMap();
    await _locPlugin.prepareLoc(androidMap, iosMap);
  }

  // 设置地图参数
  BaiduLocationAndroidOption _initAndroidOptions() {
    BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
      coorType: 'bd09ll',
      locationMode: BMFLocationMode.hightAccuracy,
      isNeedAddress: true,
      isNeedAltitude: true,
      isNeedLocationPoiList: true,
      isNeedNewVersionRgc: true,
      isNeedLocationDescribe: true,
      openGps: true,
      scanspan: 4000,
      coordType: BMFLocationCoordType.bd09ll,
    );
    return options;
  }

  BaiduLocationIOSOption _initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
      coordType: BMFLocationCoordType.bd09ll,
      BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
      desiredAccuracy: BMFDesiredAccuracy.best,
      allowsBackgroundLocationUpdates: true,
      pausesLocationUpdatesAutomatically: false,
    );
    return options;
  }

  // 停止定位
  void _stopLocation() async {
    await _locPlugin.stopLocation();
    logger.i('停止连续定位');
  }
}

class DailyForecastCard extends StatelessWidget {
  const DailyForecastCard({
    super.key,
    required this.day,
    required this.status,
    required this.temp,
    required this.aqi,
    required this.lv,
  });

  final String day;
  final String status;
  final String temp;
  final String aqi;
  final String lv;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                day,
                style: const TextStyle(fontSize: 32.0),
              ),
              Text(
                status,
                style: const TextStyle(fontSize: 18.0),
              )
            ],
          ),
          Text(
            '$temp°C',
            style: const TextStyle(fontSize: 38.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '空气质量：',
                style: TextStyle(fontSize: 12.0),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: 40.0,
                  height: 18.0,
                  color: getAqiColor(int.parse(aqi)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: lv.length <= 2 ? 10.0 : 20.0,
                        child: Text(
                          lv,
                          style: TextStyle(
                            fontSize: lv.length <= 3 ? 12.0 : 8.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        aqi,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: lv.length <= 3 ? 12.0 : 10.0,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 动态申请定位权限
void requestPermission() async {
  // 申请权限
  bool hasLocationPermission = await requestLocationPermission();
  if (hasLocationPermission) {
    // 权限申请通过
  } else {}
}

// 申请定位权限 授予定位权限返回true， 否则返回false
Future<bool> requestLocationPermission() async {
  //获取当前的权限
  var status = await Permission.location.status;
  if (status == PermissionStatus.granted) {
    //已经授权
    return true;
  } else {
    //未授权则发起一次申请
    status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

Color getAqiColor(aqi) {
  final Color color = aqi >= 0 && aqi <= 50
      ? Colors.green
      : aqi <= 100
          ? Colors.yellow
          : aqi <= 150
              ? Colors.orange
              : aqi <= 200
                  ? Colors.red
                  : aqi <= 300
                      ? Colors.purple
                      : const Color.fromARGB(255, 105, 0, 26);
  return color;
}

class HourlyChart extends StatelessWidget {
  const HourlyChart({super.key, required this.data});

  final List<HourlyData> data;

  String extractHour(String dateTimeString) {
    // 使用正则表达式匹配时间部分（hh:mm）
    final regExp = RegExp(r'(\d{2}:\d{2})');
    final match = regExp.firstMatch(dateTimeString);

    // 如果找到匹配项，返回匹配到的时间部分
    if (match != null) {
      return match.group(0)!; // 使用 ! 来断言匹配到的值非空
    } else {
      return ''; // 如果没有匹配项，返回空字符串或其他默认值
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前时间
    DateTime currentTime = DateTime.now();
    int currentIndex = 0;

    // 找到当前时间对应的 HourlyData
    for (int i = 0; i < data.length; i++) {
      DateTime entryTime = DateTime.parse(data[i].fxTime);
      if (entryTime.isAfter(currentTime)) {
        currentIndex = i;
        break;
      }
    }

    ScrollController scrollController = ScrollController(initialScrollOffset: currentIndex * 60.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      child: Row(
        children: data.asMap().entries.map(
          (MapEntry<int, HourlyData> entry) {
            return Column(
              children: [
                Container(
                  width: 60.0,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Text('${entry.value.temp}°C'),
                      Text(entry.value.text),
                      Text(
                        entry.value.windDir,
                        style: const TextStyle(fontSize: 8.0),
                      ),
                      Text('${entry.value.windScale}级'),
                      Text(extractHour(entry.value.fxTime)),
                    ],
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}

class MonthChart extends StatelessWidget {
  const MonthChart({super.key, required this.data});

  final List<DailyWeather> data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: data.asMap().entries.map(
          (MapEntry<int, DailyWeather> entry) {
            return Column(
              children: [
                Container(
                  width: 120.0,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Text('${entry.value.tempMin}~${entry.value.tempMax}°C'),
                      Row(
                        children: [
                          const SizedBox(width: 32.0),
                          Icon(Icons.sunny, size: 12.0, color: Colors.yellow.shade500),
                          Text(
                            entry.value.textDay,
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 32.0),
                          Icon(Icons.nightlight, size: 12.0, color: Colors.yellow.shade500),
                          Text(
                            entry.value.textNight,
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                      Text(
                        entry.value.windDirDay,
                        style: const TextStyle(fontSize: 8.0),
                      ),
                      Text('${entry.value.windScaleDay}级'),
                      Text(entry.value.fxDate),
                    ],
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}

class LoadingTextAnimation extends StatefulWidget {
  const LoadingTextAnimation({super.key});

  @override
  LoadingTextAnimationState createState() => LoadingTextAnimationState();
}

class LoadingTextAnimationState extends State<LoadingTextAnimation> {
  String loadingText = '';

  @override
  void initState() {
    super.initState();
    startLoadingAnimation();
  }

  startLoadingAnimation() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        if (loadingText == '') {
          loadingText = '.';
        } else if (loadingText == '.') {
          loadingText = '..';
        } else if (loadingText == '..') {
          loadingText = '...';
        } else {
          loadingText = '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '正在定位中$loadingText',
      style: const TextStyle(fontSize: 16.0),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

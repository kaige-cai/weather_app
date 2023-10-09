import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK;
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './util.dart';
import 'model/weather_data.dart';

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
        logger.i('经纬度：${result.longitude},${result.latitude}');
        _startLocation();
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

    // 如果出现错误或异常，返回一个默认的 WeatherData 对象
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
                      _locationAction();
                      await _startLocation();

                      setState(() {
                        longitude = _locationResult.longitude ?? 0.0;
                        latitude = _locationResult.latitude ?? 0.0;
                        address = _locationResult.address ?? '正在定位...';
                        pois = _locationResult.pois?[1].name ?? '请重试...';

                        if (longitude != 0.0 && latitude != 0.0) {
                          _fetchWeatherData(
                            longitude: longitude,
                            latitude: latitude,
                          ).then((value) => {_stopLocation()});

                          _stopLocation();
                        }

                        saveData(longitude, latitude, address, pois);
                      });
                    },
                  ),
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
                        Text('更新时间：${weatherData.updateTime}'),
                        Text('观测时间：${weatherData.now.obsTime}'),
                        Text('天气：${weatherData.now.text}'),
                        Text('温度：${weatherData.now.temp}°C'),
                        Text('体感：${weatherData.now.feelsLike}°C'),
                        Text('湿度：${weatherData.now.humidity}%'),
                        Text('风力：${weatherData.now.windScale}级'),
                        Text('云量：${weatherData.now.cloud}'),
                        Text('风向360°：${weatherData.now.wind360}'),
                        Text('露点温度：${weatherData.now.dew}'),
                        Text('当前小时累计降水量：${weatherData.now.precip}mm'),
                        Text('大气压强：${weatherData.now.pressure}百帕'),
                        Text('风向：${weatherData.now.windDir}')
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

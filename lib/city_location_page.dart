import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK;
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:weather_app/main.dart';

class CityLocationPage extends StatefulWidget {
  const CityLocationPage({super.key});

  @override
  State<CityLocationPage> createState() => _CityLocationPageState();
}

class _CityLocationPageState extends State<CityLocationPage> {
  BaiduLocation _locationResult = BaiduLocation();
  final LocationFlutterPlugin _locPlugin = LocationFlutterPlugin();

  @override
  void initState() {
    _locPlugin.setAgreePrivacy(true);
    BMFMapSDK.setAgreePrivacy(true);
    // 接受定位回调
    _locPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
      setState(() {
        _locationResult = result;
        debugPrint('经纬度：${result.longitude},${result.latitude}');
      });
    });
    _locationAction();
    _startLocation();
    super.initState();
  }

  @override
  void dispose() {
    _stopLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextButton(
              onPressed: () {
                _locationAction();
                _startLocation();
              },
              child: const Text('点击')),
          Text('${_locationResult.longitude},${_locationResult.latitude}'),
        ],
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
        coordType: BMFLocationCoordType.bd09ll);
    return options;
  }

  BaiduLocationIOSOption _initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
        coordType: BMFLocationCoordType.bd09ll,
        BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
        desiredAccuracy: BMFDesiredAccuracy.best,
        allowsBackgroundLocationUpdates: true,
        pausesLocationUpdatesAutomatically: false);
    return options;
  }

  // 停止定位
  void _stopLocation() async {
    await _locPlugin.stopLocation();
    logger.i('停止连续定位');
  }
}

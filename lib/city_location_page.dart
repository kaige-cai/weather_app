import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK;
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/util.dart';

import 'first_time_checker.dart';

class CityLocationPage extends StatefulWidget {
  const CityLocationPage({super.key});

  @override
  State<CityLocationPage> createState() => _CityLocationPageState();
}

class _CityLocationPageState extends State<CityLocationPage> {
  BaiduLocation _locationResult = BaiduLocation();
  final LocationFlutterPlugin _locPlugin = LocationFlutterPlugin();

  bool _locationDataLoaded = false; // 是否已加载定位数据
  bool _isLoading = false;

  @override
  void initState() {
    requestPermission();
    _locPlugin.setAgreePrivacy(true);
    BMFMapSDK.setAgreePrivacy(true);
    // 接受定位回调
    _locPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
      setState(() {
        _locationResult = result;
        logger.i('经纬度：${result.longitude},${result.latitude}');
        if (result.pois != null) {
          _stopLocation();
          _locationDataLoaded = true; // 标记定位数据已加载
        }
      });
    });
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              _locationAction();
              _startLocation();

              setState(() {
                _isLoading = true;
              });

              // 使用Future来模拟等待数据加载
              // 等待数据加载完毕
              while (!_locationDataLoaded) {
                await Future.delayed(const Duration(milliseconds: 100));
              }

              // 数据加载完毕
              setState(() {
                _isLoading = false;
              });

              await FirstTimeChecker.setNotFirstTime();

              navigator.pushReplacementNamed(
                '/weather_page',
                arguments: {
                  'longitude': _locationResult.longitude,
                  'latitude': _locationResult.latitude,
                  'address': _locationResult.address,
                  'pois': _locationResult.pois?[1].name
                },
              );
            },
            child: const Text('点击开始定位所在城市或区域'),
          ),
          // 根据 _isLoading 显示进度圈或经纬度信息
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Text(
                    '${_locationResult.longitude ?? ''} '
                    '${_locationResult.latitude ?? ''}',
                  ),
                ),
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

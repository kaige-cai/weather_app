import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart' show BMFMapSDK;
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/model/location_data.dart';
import 'package:weather_app/util.dart';

import 'data.dart';
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

  final TextEditingController _textEditingController = TextEditingController();

  bool _isVisible = false; // 控制清空按钮的可见性

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
    _textEditingController.addListener(_onTextChanged);
    super.initState();
  }

  void _onTextChanged() {
    setState(() {
      _isVisible = _textEditingController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _stopLocation();
    _textEditingController.dispose();
    super.dispose();
  }

  Future<LocationData> _fetchLocationData({required String? area}) async {
    try {
      Dio dio = Dio();

      final Map<String, dynamic> queryParams = {
        'location': area,
        'key': 'a008fc18ddda40558ce9df9f3a14508e',
        'lang': 'zh',
        'unit': 'm',
      };

      Response response = await dio.get(
        'https://geoapi.qweather.com/v2/city/lookup',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        if (data['code'] != '200') {
          data['location'] = [];
        } else {
          LocationData locationData = LocationData.fromJson(data);
          return locationData;
        }
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 LocationData 对象
    return LocationData(
      code: '',
      location: [],
      refer: Refer(
        sources: [],
        license: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: "搜索全球城市及地区...",
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Visibility(
                visible: _isVisible, // 控制可见性
                child: IconButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    _textEditingController.clear(); // 清空文本字段
                  },
                  icon: const Icon(
                    Icons.clear,
                    size: 18.0,
                  ),
                ),
              ),
              IconButton(
                color: Colors.blueAccent,
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
      body: _isVisible
          ? FutureBuilder<LocationData>(
              future: _fetchLocationData(area: _textEditingController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('发生错误: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.location.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.only(top: 32.0),
                    alignment: Alignment.topCenter,
                    child: const Text('暂无数据'),
                  );
                }

                LocationData? data = snapshot.data;

                return ListView.builder(
                  itemCount: data?.location.length ?? 0,
                  itemBuilder: (context, index) {
                    if (index >= 0 && index < data!.location.length) {
                      return GestureDetector(
                        onTap: () {
                          Location location = data.location[index];
                          double longitude = double.parse(location.lon);
                          double latitude = double.parse(location.lat);
                          String address = '${location.country}'
                              '${location.adm1}'
                              '${location.adm2}';

                          Navigator.of(context).popAndPushNamed(
                            '/weather_page',
                            arguments: {
                              'longitude': longitude,
                              'latitude': latitude,
                              'address': address,
                              'pois': location.name
                            },
                          );
                        },
                        child: Center(
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                '${data.location[index].name}·'
                                '${data.location[index].adm1}·'
                                '${data.location[index].country}',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const Center(child: Text('无效的索引'));
                  },
                );
              },
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
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

                      navigator.popAndPushNamed(
                        '/weather_page',
                        arguments: {
                          'longitude': _locationResult.longitude,
                          'latitude': _locationResult.latitude,
                          'address': _locationResult.address,
                          'pois': _locationResult.pois?[1].name
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_rounded),
                        Text('点击定位所在城市或区域'),
                      ],
                    ),
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
                  CityCard(title: '热门城市', data: cities),
                  CityCard(title: '国际城市', data: globalCities),
                ],
              ),
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

class CityCard extends StatelessWidget {
  final List<String> data;
  final String title;

  const CityCard({super.key, required this.title, required this.data});

  Future<LocationData> _fetchLocationData({required int index}) async {
    try {
      Dio dio = Dio();

      final Map<String, dynamic> queryParams = {
        'location': data[index],
        'key': 'a008fc18ddda40558ce9df9f3a14508e',
        'lang': 'zh',
        'unit': 'm',
      };

      Response response = await dio.get(
        'https://geoapi.qweather.com/v2/city/lookup',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        LocationData locationData = LocationData.fromJson(data);
        return locationData;
      } else {
        logger.e('请求失败：${response.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('请求发生异常: $e', error: e, stackTrace: stackTrace);
    }

    // 如果出现错误或异常，返回一个默认的 LocationData 对象
    return LocationData(
      code: '',
      location: [],
      refer: Refer(
        sources: [],
        license: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 2 / 1,
            ),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () async {
                  double longitude = 0.0;
                  double latitude = 0.0;
                  String address = '';

                  final navigator = Navigator.of(context);

                  await _fetchLocationData(index: index).then(
                    (LocationData value) {
                      longitude = double.parse(value.location[0].lon);
                      latitude = double.parse(value.location[0].lat);
                      Location location = value.location[0];

                      switch (data[index]) {
                        case '巴塞罗那':
                        case '首尔':
                        case '新加坡':
                        case '巴黎':
                        case '芝加哥':
                          address = '${value.location[1].country}'
                              '${value.location[1].adm1}'
                              '${value.location[1].adm2}';
                          return;
                        case '堪培拉':
                          address = '${value.location[2].country}'
                              '${value.location[2].adm1}'
                              '${value.location[2].adm2}';
                          return;
                        case '伦敦':
                          address = '${value.location[3].country}'
                              '${value.location[3].adm1}'
                              '${value.location[3].name}';
                          return;
                        default:
                          address = '${location.country}'
                              '${location.adm1}'
                              '${location.adm2}';
                      }
                    },
                  );

                  navigator.popAndPushNamed(
                    '/weather_page',
                    arguments: {
                      'longitude': longitude,
                      'latitude': latitude,
                      'address': address,
                      'pois': data[index]
                    },
                  );
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Text(data[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

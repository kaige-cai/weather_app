import 'package:json_annotation/json_annotation.dart';

part 'weather_now_data.g.dart'; // 生成的字段映射代码将保存在该文件中

@JsonSerializable()
class WeatherNowData {
  final String code;
  final String updateTime;
  final String fxLink;
  final NowData now;
  final Refer refer;

  WeatherNowData({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.now,
    required this.refer,
  });

  factory WeatherNowData.fromJson(Map<String, dynamic> json) => _$WeatherNowDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherNowDataToJson(this);
}

@JsonSerializable()
class NowData {
  final String obsTime;
  final String temp;
  final String feelsLike;
  final String icon;
  final String text;
  final String wind360;
  final String windDir;
  final String windScale;
  final String windSpeed;
  final String humidity;
  final String precip;
  final String pressure;
  final String cloud;
  final String dew;

  NowData({
    required this.obsTime,
    required this.temp,
    required this.feelsLike,
    required this.icon,
    required this.text,
    required this.wind360,
    required this.windDir,
    required this.windScale,
    required this.windSpeed,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.cloud,
    required this.dew,
  });

  factory NowData.fromJson(Map<String, dynamic> json) => _$NowDataFromJson(json);

  Map<String, dynamic> toJson() => _$NowDataToJson(this);
}

@JsonSerializable()
class Refer {
  final List<String> sources;
  final List<String> license;

  Refer({
    required this.sources,
    required this.license,
  });

  factory Refer.fromJson(Map<String, dynamic> json) => _$ReferFromJson(json);

  Map<String, dynamic> toJson() => _$ReferToJson(this);
}

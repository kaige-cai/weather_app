import 'package:json_annotation/json_annotation.dart';

part 'weather_hourly_data.g.dart'; // 这个文件是通过build_runner生成的

@JsonSerializable()
class WeatherHourlyData {
  final String code;
  final String updateTime;
  final String fxLink;
  final List<HourlyData> hourly;
  final HourlyRefer refer;

  WeatherHourlyData({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.hourly,
    required this.refer,
  });

  factory WeatherHourlyData.fromJson(Map<String, dynamic> json) =>
      _$WeatherHourlyDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherHourlyDataToJson(this);
}

@JsonSerializable()
class HourlyData {
  final String fxTime;
  final String temp;
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

  HourlyData({
    required this.fxTime,
    required this.temp,
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

  factory HourlyData.fromJson(Map<String, dynamic> json) => _$HourlyDataFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyDataToJson(this);
}

@JsonSerializable()
class HourlyRefer {
  final List<String> sources;
  final List<String> license;

  HourlyRefer({
    required this.sources,
    required this.license,
  });

  factory HourlyRefer.fromJson(Map<String, dynamic> json) => _$HourlyReferFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyReferToJson(this);
}

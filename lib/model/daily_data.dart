import 'package:json_annotation/json_annotation.dart';

part 'daily_data.g.dart'; // 自动生成的文件

@JsonSerializable()
class DailyWeatherData {
  final String code;
  final String updateTime;
  final String fxLink;
  final List<DailyForecast> daily;
  final DailyRefer refer;

  DailyWeatherData({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.daily,
    required this.refer,
  });

  factory DailyWeatherData.fromJson(Map<String, dynamic> json) => _$DailyWeatherDataFromJson(json);

  Map<String, dynamic> toJson() => _$DailyWeatherDataToJson(this);
}

@JsonSerializable()
class DailyForecast {
  final String fxDate;
  final String tempMax;
  final String tempMin;
  final String iconDay;
  final String iconNight;
  final String textDay;
  final String textNight;
  final String wind360Day;
  final String windDirDay;
  final String windScaleDay;
  final String windSpeedDay;
  final String wind360Night;
  final String windDirNight;
  final String windScaleNight;
  final String windSpeedNight;
  final String humidity;
  final String precip;
  final String pressure;
  final String cloud;

  DailyForecast(
    this.fxDate,
    this.tempMax,
    this.tempMin,
    this.iconDay,
    this.iconNight,
    this.textDay,
    this.textNight,
    this.wind360Day,
    this.windDirDay,
    this.windScaleDay,
    this.windSpeedDay,
    this.wind360Night,
    this.windDirNight,
    this.windScaleNight,
    this.windSpeedNight,
    this.humidity,
    this.precip,
    this.pressure,
    this.cloud,
  );

  factory DailyForecast.fromJson(Map<String, dynamic> json) => _$DailyForecastFromJson(json);

  Map<String, dynamic> toJson() => _$DailyForecastToJson(this);
}

@JsonSerializable()
class DailyRefer {
  final List<String> sources;
  final List<String> license;

  DailyRefer({required this.sources, required this.license});

  factory DailyRefer.fromJson(Map<String, dynamic> json) => _$DailyReferFromJson(json);

  Map<String, dynamic> toJson() => _$DailyReferToJson(this);
}

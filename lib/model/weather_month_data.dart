import 'package:json_annotation/json_annotation.dart';

part 'weather_month_data.g.dart';

@JsonSerializable()
class WeatherMonthData {
  final String code;
  final String updateTime;
  final String fxLink;
  final List<DailyWeather> daily;
  final MonthRefer refer;

  WeatherMonthData({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.daily,
    required this.refer,
  });

  factory WeatherMonthData.fromJson(Map<String, dynamic> json) => _$WeatherMonthDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherMonthDataToJson(this);
}

@JsonSerializable()
class DailyWeather {
  final String fxDate;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final String moonPhaseIcon;
  final String tempMax;
  final String tempMin;
  final String iconDay;
  final String textDay;
  final String iconNight;
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
  final String vis;
  final String cloud;
  final String uvIndex;

  DailyWeather({
    required this.fxDate,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonPhaseIcon,
    required this.tempMax,
    required this.tempMin,
    required this.iconDay,
    required this.textDay,
    required this.iconNight,
    required this.textNight,
    required this.wind360Day,
    required this.windDirDay,
    required this.windScaleDay,
    required this.windSpeedDay,
    required this.wind360Night,
    required this.windDirNight,
    required this.windScaleNight,
    required this.windSpeedNight,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.vis,
    required this.cloud,
    required this.uvIndex,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) => _$DailyWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$DailyWeatherToJson(this);
}

@JsonSerializable()
class MonthRefer {
  final List<String> sources;
  final List<String> license;

  MonthRefer({required this.sources, required this.license});

  factory MonthRefer.fromJson(Map<String, dynamic> json) => _$MonthReferFromJson(json);

  Map<String, dynamic> toJson() => _$MonthReferToJson(this);
}

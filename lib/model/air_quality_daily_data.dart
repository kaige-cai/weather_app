import 'package:json_annotation/json_annotation.dart';

part 'air_quality_daily_data.g.dart';

@JsonSerializable()
class AirQualityDaily {
  final String code;
  final String updateTime;
  final String fxLink;
  final List<AirQualityData> daily;
  final AirQualityDailyRefer refer;

  AirQualityDaily({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.daily,
    required this.refer,
  });

  factory AirQualityDaily.fromJson(Map<String, dynamic> json) => _$AirQualityDailyFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityDailyToJson(this);
}

@JsonSerializable()
class AirQualityData {
  final String fxDate;
  final String aqi;
  final String level;
  final String category;
  final String primary;

  AirQualityData({
    required this.fxDate,
    required this.aqi,
    required this.level,
    required this.category,
    required this.primary,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) => _$AirQualityDataFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityDataToJson(this);
}

@JsonSerializable()
class AirQualityDailyRefer {
  final List<String> sources;
  final List<String> license;

  AirQualityDailyRefer({
    required this.sources,
    required this.license,
  });

  factory AirQualityDailyRefer.fromJson(Map<String, dynamic> json) =>
      _$AirQualityDailyReferFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityDailyReferToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'air_quality_now_data.g.dart';

@JsonSerializable()
class AirQuality {
  final String code;
  final String updateTime;
  final String fxLink;
  final AirQualityNow now;
  final AirQualityNowRefer refer;

  AirQuality({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.now,
    required this.refer,
  });

  factory AirQuality.fromJson(Map<String, dynamic> json) => _$AirQualityFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityToJson(this);
}

@JsonSerializable()
class AirQualityNow {
  final String pubTime;
  final String aqi;
  final String level;
  final String category;
  final String primary;
  final String pm10;
  final String pm2p5;
  final String no2;
  final String so2;
  final String co;
  final String o3;

  AirQualityNow({
    required this.pubTime,
    required this.aqi,
    required this.level,
    required this.category,
    required this.primary,
    required this.pm10,
    required this.pm2p5,
    required this.no2,
    required this.so2,
    required this.co,
    required this.o3,
  });

  factory AirQualityNow.fromJson(Map<String, dynamic> json) => _$AirQualityNowFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityNowToJson(this);
}

@JsonSerializable()
class AirQualityNowRefer {
  final List<String> sources;
  final List<String> license;

  AirQualityNowRefer({
    required this.sources,
    required this.license,
  });

  factory AirQualityNowRefer.fromJson(Map<String, dynamic> json) =>
      _$AirQualityNowReferFromJson(json);

  Map<String, dynamic> toJson() => _$AirQualityNowReferToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'air_quality_now_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirQuality _$AirQualityFromJson(Map<String, dynamic> json) => AirQuality(
      code: json['code'] as String,
      updateTime: json['updateTime'] as String,
      fxLink: json['fxLink'] as String,
      now: AirQualityNow.fromJson(json['now'] as Map<String, dynamic>),
      refer: AirQualityNowRefer.fromJson(json['refer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AirQualityToJson(AirQuality instance) => <String, dynamic>{
      'code': instance.code,
      'updateTime': instance.updateTime,
      'fxLink': instance.fxLink,
      'now': instance.now,
      'refer': instance.refer,
    };

AirQualityNow _$AirQualityNowFromJson(Map<String, dynamic> json) => AirQualityNow(
      pubTime: json['pubTime'] as String,
      aqi: json['aqi'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      primary: json['primary'] as String,
      pm10: json['pm10'] as String,
      pm2p5: json['pm2p5'] as String,
      no2: json['no2'] as String,
      so2: json['so2'] as String,
      co: json['co'] as String,
      o3: json['o3'] as String,
    );

Map<String, dynamic> _$AirQualityNowToJson(AirQualityNow instance) => <String, dynamic>{
      'pubTime': instance.pubTime,
      'aqi': instance.aqi,
      'level': instance.level,
      'category': instance.category,
      'primary': instance.primary,
      'pm10': instance.pm10,
      'pm2p5': instance.pm2p5,
      'no2': instance.no2,
      'so2': instance.so2,
      'co': instance.co,
      'o3': instance.o3,
    };

AirQualityNowRefer _$AirQualityNowReferFromJson(Map<String, dynamic> json) => AirQualityNowRefer(
      sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      license: (json['license'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AirQualityNowReferToJson(AirQualityNowRefer instance) => <String, dynamic>{
      'sources': instance.sources,
      'license': instance.license,
    };

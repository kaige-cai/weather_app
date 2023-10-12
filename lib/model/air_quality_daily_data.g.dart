// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'air_quality_daily_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirQualityDaily _$AirQualityDailyFromJson(Map<String, dynamic> json) => AirQualityDaily(
      code: json['code'] as String,
      updateTime: json['updateTime'] as String,
      fxLink: json['fxLink'] as String,
      daily: (json['daily'] as List<dynamic>)
          .map((e) => AirQualityData.fromJson(e as Map<String, dynamic>))
          .toList(),
      refer: AirQualityDailyRefer.fromJson(json['refer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AirQualityDailyToJson(AirQualityDaily instance) => <String, dynamic>{
      'code': instance.code,
      'updateTime': instance.updateTime,
      'fxLink': instance.fxLink,
      'daily': instance.daily,
      'refer': instance.refer,
    };

AirQualityData _$AirQualityDataFromJson(Map<String, dynamic> json) => AirQualityData(
      fxDate: json['fxDate'] as String,
      aqi: json['aqi'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      primary: json['primary'] as String,
    );

Map<String, dynamic> _$AirQualityDataToJson(AirQualityData instance) => <String, dynamic>{
      'fxDate': instance.fxDate,
      'aqi': instance.aqi,
      'level': instance.level,
      'category': instance.category,
      'primary': instance.primary,
    };

AirQualityDailyRefer _$AirQualityDailyReferFromJson(Map<String, dynamic> json) =>
    AirQualityDailyRefer(
      sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      license: (json['license'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AirQualityDailyReferToJson(AirQualityDailyRefer instance) =>
    <String, dynamic>{
      'sources': instance.sources,
      'license': instance.license,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyWeatherData _$DailyWeatherDataFromJson(Map<String, dynamic> json) => DailyWeatherData(
      code: json['code'] as String,
      updateTime: json['updateTime'] as String,
      fxLink: json['fxLink'] as String,
      daily: (json['daily'] as List<dynamic>)
          .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      refer: DailyRefer.fromJson(json['refer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailyWeatherDataToJson(DailyWeatherData instance) => <String, dynamic>{
      'code': instance.code,
      'updateTime': instance.updateTime,
      'fxLink': instance.fxLink,
      'daily': instance.daily,
      'refer': instance.refer,
    };

DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) => DailyForecast(
      json['fxDate'] as String,
      json['tempMax'] as String,
      json['tempMin'] as String,
      json['iconDay'] as String,
      json['iconNight'] as String,
      json['textDay'] as String,
      json['textNight'] as String,
      json['wind360Day'] as String,
      json['windDirDay'] as String,
      json['windScaleDay'] as String,
      json['windSpeedDay'] as String,
      json['wind360Night'] as String,
      json['windDirNight'] as String,
      json['windScaleNight'] as String,
      json['windSpeedNight'] as String,
      json['humidity'] as String,
      json['precip'] as String,
      json['pressure'] as String,
      json['cloud'] as String,
    );

Map<String, dynamic> _$DailyForecastToJson(DailyForecast instance) => <String, dynamic>{
      'fxDate': instance.fxDate,
      'tempMax': instance.tempMax,
      'tempMin': instance.tempMin,
      'iconDay': instance.iconDay,
      'iconNight': instance.iconNight,
      'textDay': instance.textDay,
      'textNight': instance.textNight,
      'wind360Day': instance.wind360Day,
      'windDirDay': instance.windDirDay,
      'windScaleDay': instance.windScaleDay,
      'windSpeedDay': instance.windSpeedDay,
      'wind360Night': instance.wind360Night,
      'windDirNight': instance.windDirNight,
      'windScaleNight': instance.windScaleNight,
      'windSpeedNight': instance.windSpeedNight,
      'humidity': instance.humidity,
      'precip': instance.precip,
      'pressure': instance.pressure,
      'cloud': instance.cloud,
    };

DailyRefer _$DailyReferFromJson(Map<String, dynamic> json) => DailyRefer(
      sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      license: (json['license'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DailyReferToJson(DailyRefer instance) => <String, dynamic>{
      'sources': instance.sources,
      'license': instance.license,
    };

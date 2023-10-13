// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_hourly_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherHourlyData _$WeatherHourlyDataFromJson(Map<String, dynamic> json) => WeatherHourlyData(
      code: json['code'] as String,
      updateTime: json['updateTime'] as String,
      fxLink: json['fxLink'] as String,
      hourly: (json['hourly'] as List<dynamic>)
          .map((e) => HourlyData.fromJson(e as Map<String, dynamic>))
          .toList(),
      refer: HourlyRefer.fromJson(json['refer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeatherHourlyDataToJson(WeatherHourlyData instance) => <String, dynamic>{
      'code': instance.code,
      'updateTime': instance.updateTime,
      'fxLink': instance.fxLink,
      'hourly': instance.hourly,
      'refer': instance.refer,
    };

HourlyData _$HourlyDataFromJson(Map<String, dynamic> json) => HourlyData(
      fxTime: json['fxTime'] as String,
      temp: json['temp'] as String,
      icon: json['icon'] as String,
      text: json['text'] as String,
      wind360: json['wind360'] as String,
      windDir: json['windDir'] as String,
      windScale: json['windScale'] as String,
      windSpeed: json['windSpeed'] as String,
      humidity: json['humidity'] as String,
      precip: json['precip'] as String,
      pressure: json['pressure'] as String,
      cloud: json['cloud'] as String,
      dew: json['dew'] as String,
    );

Map<String, dynamic> _$HourlyDataToJson(HourlyData instance) => <String, dynamic>{
      'fxTime': instance.fxTime,
      'temp': instance.temp,
      'icon': instance.icon,
      'text': instance.text,
      'wind360': instance.wind360,
      'windDir': instance.windDir,
      'windScale': instance.windScale,
      'windSpeed': instance.windSpeed,
      'humidity': instance.humidity,
      'precip': instance.precip,
      'pressure': instance.pressure,
      'cloud': instance.cloud,
      'dew': instance.dew,
    };

HourlyRefer _$HourlyReferFromJson(Map<String, dynamic> json) => HourlyRefer(
      sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      license: (json['license'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$HourlyReferToJson(HourlyRefer instance) => <String, dynamic>{
      'sources': instance.sources,
      'license': instance.license,
    };

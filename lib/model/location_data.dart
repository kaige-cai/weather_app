import 'package:json_annotation/json_annotation.dart';

part 'location_data.g.dart';

@JsonSerializable()
class LocationData {
  final String code;
  final List<Location> location;
  final Refer refer;

  LocationData({
    required this.code,
    required this.location,
    required this.refer,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}

@JsonSerializable()
class Location {
  final String name;
  final String id;
  final String lat;
  final String lon;
  final String adm2;
  final String adm1;
  final String country;
  final String tz;
  final String utcOffset;
  final String isDst;
  final String type;
  final String rank;
  final String fxLink;

  Location({
    required this.name,
    required this.id,
    required this.lat,
    required this.lon,
    required this.adm2,
    required this.adm1,
    required this.country,
    required this.tz,
    required this.utcOffset,
    required this.isDst,
    required this.type,
    required this.rank,
    required this.fxLink,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class Refer {
  final List<String> sources;
  final List<String> license;

  Refer({required this.sources, required this.license});

  factory Refer.fromJson(Map<String, dynamic> json) => _$ReferFromJson(json);

  Map<String, dynamic> toJson() => _$ReferToJson(this);
}

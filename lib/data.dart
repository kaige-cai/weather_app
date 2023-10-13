import 'model/weather_now_data.dart';

final List<String> cities = [
  '上海',
  '北京',
  '深圳',
  '广州',
  '香港',
  '澳门',
  '台北',
  '淄博',
  '成都',
  '重庆',
  '杭州',
  '武汉',
  '苏州',
  '西安',
  '南京',
  '长沙',
  '天津',
  '郑州',
  '东莞',
  '青岛',
  '昆明',
  '宁波',
  '合肥',
  '洛阳',
];

final List<String> globalCities = [
  '纽约',
  '巴黎',
  '东京',
  '迪拜',
  '伦敦',
  '阿姆斯特丹',
  '首尔',
  '堪培拉',
  '新加坡',
  '洛杉矶',
  '悉尼',
  '柏林',
  '芝加哥',
  '维也纳',
  '莫斯科',
  '曼谷',
  '巴塞罗那',
  '开罗',
];

class RiveFiles {
  static const String cloudyDay =
      'https://public.rive.app/community/runtime-files/3098-6535-copy-weathericon.riv';
  static const String sunnyDay =
      'https://public.rive.app/community/runtime-files/1351-2585-weather.riv';
  static const String cloudy =
      'https://public.rive.app/community/runtime-files/2741-5623-cloud-and-sun.riv';
  static const String rainDayH =
      'https://public.rive.app/community/runtime-files/6262-12153-rain-30-70.riv';
  static const String snow =
      'https://public.rive.app/community/runtime-files/3186-6731-snow-icon.riv';
  static const String hot =
      'https://public.rive.app/community/runtime-files/3420-7173-rive-fire.riv';
  static const String cold =
      'https://public.rive.app/community/runtime-files/1465-2853-sea-salt-ice-cream.riv';
}

List<String> generateWeatherInfo(WeatherNowData weatherData) {
  return [
    '体感：${weatherData.now.feelsLike}°C',
    '湿度：${weatherData.now.humidity}%',
    '云量：${weatherData.now.cloud}',
    '风力：${weatherData.now.windScale}级',
    '风向：${weatherData.now.wind360}°',
    '露点：${weatherData.now.dew}°C',
    '降水：\n${weatherData.now.precip}毫米',
    '气压：\n${weatherData.now.pressure}百帕',
    '风向：\n${weatherData.now.windDir}',
  ];
}

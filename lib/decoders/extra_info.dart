

import 'dart:convert';
import 'dart:ui';

import 'package:weathify/decoders/decode_OM.dart';

import '../api_key.dart';
import '../caching.dart';

import '../ui_helper.dart';
import '../weather_refact.dart';
import 'decode_wapi.dart';


Color BackColorCorrection(String text) {
  //return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  return accentColors[text] ?? WHITE;
}

Color PrimaryColorCorrection(String text) {
  return textBackColor[text] ?? BLACK;
}

List<int> ColorPopCorrection(String text) {
  return colorPop[text] ?? [0, 0];
}

class WeatherData {
  final Map<String, String> settings;
  final String place;
  final String provider;
  final String real_loc;

  final double lat;
  final double lng;

  final days;
  final current;
  final aqi;
  final sunstatus;
  final radar;

  final fetch_datetime;

  WeatherData({
    required this.place,
    required this.settings,
    required this.provider,
    required this.real_loc,
    required this.lat,
    required this.lng,
    required this.sunstatus,
    required this.aqi,
    required this.radar,
    required this.days,
    required this.current,
    required this.fetch_datetime,
  });

  static Future<WeatherData> getFullData(settings, placeName, real_loc, latlong, provider) async {

    List<String> split = latlong.split(",");
    double lat = double.parse(split[0]);
    double lng = double.parse(split[1]);

    //gets the json response for weatherapi.com
    final params = {
      'key': wapi_Key,
      'q': latlong,
      'days': '3',
      'aqi': 'yes',
      'alerts': 'no',
    };
    final url = Uri.http('api.weatherapi.com', 'v1/forecast.json', params);

    var file = await cacheManager2.getSingleFile(url.toString(), key: "$real_loc, weatherapi.com")
        .timeout(const Duration(seconds: 6));

    DateTime fetch_datetime = await file.lastModified();

    var response = await file.readAsString();

    var wapi_body = jsonDecode(response);

    var timenow = wapi_body["location"]["localtime_epoch"];
    String real_time = wapi_body["location"]["localtime"];

    WapiSunstatus sunstatus = WapiSunstatus.fromJson(wapi_body, settings);

    if (provider == 'weatherapi.com') {
      List<WapiDay> days = [];

      for (int n = 0; n < wapi_body["forecast"]["forecastday"].length; n++) {
        days.add(WapiDay.fromJson(
            wapi_body["forecast"]["forecastday"][n], n, settings, timenow));
      }

      return WeatherData(
        place: placeName,
        settings: settings,
        provider: "weatherapi.com",
        real_loc: real_loc,

        lat: lat,
        lng: lng,

        current: WapiCurrent.fromJson(wapi_body, settings,),
        days: days,
        sunstatus: sunstatus,
        aqi: WapiAqi.fromJson(wapi_body),
        radar: await RainviewerRadar.getData(),

        fetch_datetime: fetch_datetime,
      );
    }
    else {
      final oMParams = {
        "latitude": lat.toString(),
        "longitude": lng.toString(),
        "current": ["temperature_2m", "relative_humidity_2m", "apparent_temperature", "weather_code", "wind_speed_10m", 'wind_direction_10m'],
        "hourly": ["temperature_2m", "precipitation", "weather_code", "wind_speed_10m"],
        "daily": ["weather_code", "temperature_2m_max", "temperature_2m_min", "uv_index_max", "precipitation_sum", "precipitation_probability_max", "wind_speed_10m_max", "wind_direction_10m_dominant"],
        "timezone": "auto",
        "forecast_days": "14"
      };
      final oMUrl = Uri.https("api.open-meteo.com", 'v1/forecast', oMParams);

      var oMFile = await cacheManager2.getSingleFile(oMUrl.toString(), key: "$real_loc, open-meteo").timeout(const Duration(seconds: 6));
      var oMResponse = await oMFile.readAsString();
      var oMBody = jsonDecode(oMResponse);

      List<OMDay> days = [];
      for (int n = 0; n < 14; n++) {
        OMDay x = OMDay.build(oMBody, settings, n, sunstatus);
        days.add(x);
      }

      return WeatherData(
        radar: await RainviewerRadar.getData(),
        aqi: WapiAqi.fromJson(wapi_body),
        sunstatus: WapiSunstatus.fromJson(wapi_body, settings),

        current: OMCurrent.fromJson(oMBody, settings, sunstatus, real_time),
        days: days,

        lat: lat,
        lng: lng,

        place: placeName,
        settings: settings,
        provider: "open-meteo",
        real_loc: real_loc,

        fetch_datetime: fetch_datetime,
      );
    }
  }
}

class RainviewerRadar {
  final List<String> images;
  final List<String> times;

  const RainviewerRadar({
    required this.images,
    required this.times
  });

  static RainviewerRadar fromJson(images, times) => RainviewerRadar(
      images: images,
      times: times
  );

  static Future<RainviewerRadar> getData() async {
  const String url = 'https://api.rainviewer.com/public/weather-maps.json';

  var file = await cacheManager2.getSingleFile(url.toString());
  var response = await file.readAsString();
  final Map<String, dynamic> data = json.decode(response);

  final String host = data["host"];

  int timenow = DateTime.now().toUtc().microsecond;

  List<String> images = [];
  List<String> times = [];

  final past = data["radar"]["past"];
  final future = data["radar"]["nowcast"];

  for (var x in past) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(x["time"]);
    //print("${time.hour}h ${time.minute}m");
    //print(host + x["path"]);
    images.add(host + x["path"]);
    times.add("${time.hour}h ${time.minute}m");
  }

  for (var x in future) {
    int dif = x["time"] * 1000 - timenow;
    DateTime time = DateTime.fromMicrosecondsSinceEpoch(dif);
    images.add(host + x["path"]);
    times.add("${time.hour}h ${time.minute}m");
  }

  return RainviewerRadar.fromJson(images, times);
  }
}

class WapiSunstatus {
  final String sunrise;
  final String sunset;
  final double sunstatus;
  final String absoluteSunriseSunset;

  const WapiSunstatus({
    required this.sunrise,
    required this.sunstatus,
    required this.sunset,
    required this.absoluteSunriseSunset,
  });

  static WapiSunstatus fromJson(item, settings) => WapiSunstatus(
    sunrise: settings["Time mode"] == "24 hour"
        ? convertTime(item["forecast"]["forecastday"][0]["astro"]["sunrise"])
        : amPmTime(item["forecast"]["forecastday"][0]["astro"]["sunrise"]),
    sunset: settings["Time mode"] == "24 hour"
        ? convertTime(item["forecast"]["forecastday"][0]["astro"]["sunset"])
        : amPmTime(item["forecast"]["forecastday"][0]["astro"]["sunset"]),
    absoluteSunriseSunset: "${convertTime(item["forecast"]["forecastday"][0]["astro"]["sunrise"])}/"
        "${convertTime(item["forecast"]["forecastday"][0]["astro"]["sunset"])}",
    sunstatus: getSunStatus(item["forecast"]["forecastday"][0]["astro"]["sunrise"],
        item["forecast"]["forecastday"][0]["astro"]["sunset"], item["current"]["last_updated"]),
  );
}

class WapiAqi {
  final int aqi_index;
  final double pm2_5;
  final double pm10;
  final double o3;
  final double no2;

  const WapiAqi({
    required this.no2,
    required this.o3,
    required this.pm2_5,
    required this.pm10,
    required this.aqi_index,
  });

  static WapiAqi fromJson(item) => WapiAqi(
    aqi_index: item["current"]["air_quality"]["us-epa-index"],
    pm10: item["current"]["air_quality"]["pm10"],
    pm2_5: item["current"]["air_quality"]["pm2_5"],
    o3: item["current"]["air_quality"]["o3"],
    no2: item["current"]["air_quality"]["no2"],
  );
}
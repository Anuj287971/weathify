

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weathify/search_screens.dart';
import 'package:weathify/ui_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'caching.dart';
import 'decoders/extra_info.dart';
import 'main_ui.dart';
import 'package:flutter/services.dart';

import 'settings_page.dart';

void main() {
  //runApp(const MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  final data = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
  final ratio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  if (data.shortestSide / ratio < 600) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) => runApp(const MyApp()));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool startup = true;

  Future<Widget> getDays(bool recall, proposedLoc, backupName) async {

    try {

      Map<String, String> settings = await getSettingsUsed();
      String weather_provider = await getWeatherProvider();
      //print(weather_provider);

      if (startup) {
        List<String> n = await getLastPlace();  //loads the last place you visited
        print(n);
        proposedLoc = n[1];
        backupName = n[0];
        startup = false;
      }

      String absoluteProposed = proposedLoc;
      bool isItCurrentLocation = false;

      if (backupName == 'CurrentLocation') {
        print("almost therre");
        String loc_status = await isLocationSafe();
        print("got past");
        if (loc_status == "enabled") {
          Position position;
          try {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium, timeLimit: const Duration(seconds: 2));
          } on TimeoutException {
            try {
              position = (await Geolocator.getLastKnownPosition())!;
            } on Error {
              return dumbySearch(errorMessage: translation(
                  "Unable to locate device", settings["Language"]!),
                updateLocation: updateLocation,
                icon: Icons.gps_off,
                place: backupName,
                settings: settings, provider: weather_provider, latlng: absoluteProposed);
            }
          } on LocationServiceDisabledException {
            return dumbySearch(errorMessage: translation("location services are disabled.", settings["Language"]!),
              updateLocation: updateLocation,
              icon: Icons.gps_off,
              place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
          }

          backupName = '${position.latitude},${position.longitude}';
          proposedLoc = 'search';
          isItCurrentLocation = true;
          print('True');
        }
        else {
          return dumbySearch(errorMessage: translation(loc_status, settings["Language"]!),
            updateLocation: updateLocation,
            icon: Icons.gps_off,
            place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
        }
      }
      if (proposedLoc == 'search') {
        
        //List<dynamic> x = await getRecommend(backupName, "weatherapi", settings);

        List<String> s_cord = backupName.split(",");

        try {

          List<Placemark> placemarks = await placemarkFromCoordinates(
              double.parse(s_cord[0]), double.parse(s_cord[1]));
          Placemark place = placemarks[0];

          String city = '${place.locality}';

          absoluteProposed = s_cord.join(', ');
          backupName = city;
        } on FormatException {
          return dumbySearch(
            errorMessage: '${translation('Place not found', settings["Language"]!)}: \n $backupName',
            updateLocation: updateLocation,
            icon: Icons.location_disabled,
            place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
        } on PlatformException {
          absoluteProposed = backupName;
          backupName = "${double.parse(s_cord[0]).toStringAsFixed(2)}, ${double.parse(s_cord[1]).toStringAsFixed(2)}";
        }

      }

      if (proposedLoc == 'query') {
        List<dynamic> x = await getRecommend(backupName, settings["Search provider"], settings);
        if (x.length > 0) {
          var split = json.decode(x[0]);
          absoluteProposed = "${split["lat"]},${split["lon"]}";
          backupName = split["name"];
        }
        else {
          return dumbySearch(
            errorMessage: '${translation('Place not found', settings["Language"]!)}: \n $backupName',
            updateLocation: updateLocation,
            icon: Icons.location_disabled,
            place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
        }
      }

      String RealName = backupName.toString();
      if (isItCurrentLocation) {
        backupName = 'CurrentLocation';
      }

      var weatherdata;

      try {
        weatherdata = await WeatherData.getFullData(settings, RealName, backupName, absoluteProposed, weather_provider);

      } on TimeoutException {
        return dumbySearch(errorMessage: translation("Weak or no wifi connection", settings["Language"]!),
          updateLocation: updateLocation,
          icon: Icons.wifi_off,
          place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
      } on HttpExceptionWithStatus catch (hihi){
        print(hihi.toString());
        return dumbySearch(errorMessage: "general error at place 1: ${hihi.toString()}", updateLocation: updateLocation,
          icon: Icons.bug_report,
          place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
      } on SocketException {
        return dumbySearch(errorMessage: translation("Not connected to the internet", settings["Language"]!),
          updateLocation: updateLocation,
          icon: Icons.wifi_off,
          place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
      } on Error catch (e, stacktrace) {
        print(stacktrace);
        return dumbySearch(errorMessage: "general error at place 2: $e", updateLocation: updateLocation,
          icon: Icons.bug_report,
          place: backupName, settings: settings, provider: weather_provider, latlng: absoluteProposed,);
      }

      print("temp:${weatherdata.current.temp}");

      await setLastPlace(backupName, absoluteProposed);  // if the code didn't fail
                                // then this will be the new startup

      return WeatherPage(data: weatherdata, updateLocation: updateLocation);

    } catch (e, stacktrace) {
      Map<String, String> settings = await getSettingsUsed();
      String weather_provider = await getWeatherProvider();

      print("ERRRRRRRRROR");
      print(stacktrace);

      cacheManager2.emptyCache();

      if (recall) {
        return dumbySearch(errorMessage: "general error at place X: $e", updateLocation: updateLocation,
          icon: Icons.bug_report,
          place: backupName, settings: settings, provider: weather_provider, latlng: 'search',);
      }
      else {
        return getDays(true, proposedLoc, backupName);
      }
    }
  }

  late Widget w1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    w1 = Container();
    //defaults to new york when no previous location was found
    updateLocation('40.7128, 74.0060', "New York", time: 0);
  }

  Future<void> updateLocation(proposedLoc, backupName, {time = 500}) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: time));

    try {
      Widget screen = await getDays(false, proposedLoc, backupName);

      setState(() {
        w1 = screen;
      });

      await Future.delayed(Duration(milliseconds: (800 - time).toInt()));

      setState(() {
        isLoading = false;
      });

    } catch (error) {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = getStartBackColor();

    final EdgeInsets systemGestureInsets = MediaQuery.of(context).systemGestureInsets;
    print(('hihi', systemGestureInsets.left));
    if (systemGestureInsets.left > 0) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: WHITE,
        body: Stack(
          children: [
            w1,
            if (isLoading) Container(
              color: startup ? colors[0] : const Color.fromRGBO(0, 0, 0, 0.7),
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: startup ? colors[1] : WHITE,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Color> getStartBackColor() {
  var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  print(brightness);
  bool isDarkMode = brightness == Brightness.dark;
  Color back = isDarkMode ? BLACK : WHITE;
  Color front = isDarkMode ? const Color.fromRGBO(250, 250, 250, 0.7) : const Color.fromRGBO(0, 0, 0, 0.3);
  return [back, front];
}
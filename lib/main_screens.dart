import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weathify/settings_page.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'main_ui.dart';
import 'ui_helper.dart';

Widget NewMain(data, updateLocation, context) {
  FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
  Size size = view.physicalSize / view.devicePixelRatio;

  final FloatingSearchBarController controller = FloatingSearchBarController();

  return Scaffold(
    backgroundColor: data.current.backcolor,
    drawer: MyDrawer(primary: data.current.backup_primary, back: data.current.backup_backcolor,
        settings: data.settings, image: data.current.backdrop,),
    body: StretchyHeader.listView(
      displacement: 130,
      onRefresh: () async {
        await updateLocation("${data.lat}, ${data.lng}", data.real_loc);
      },
      headerData: HeaderData(
        //backgroundColor: WHITE,
          blurContent: false,
          headerHeight: max(size.height * 0.57, 400), //we don't want it to be smaller than 400
          header: ParrallaxBackground(imagePath1: data.current.backdrop, key: Key(data.place),
          color: data.current.backcolor == BLACK ? BLACK
              : lightAccent(data.current.backcolor, 5000)),
          overlay: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25,
                    top: MediaQuery.of(context).padding.top + 20, right: 25, bottom: 30
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 0, bottom: 5),
                      child: comfortatext("${data.current.temp}°", 68, data.settings,
                          color: data.current.colorpop, weight: FontWeight.w300),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: comfortatext(data.current.text, 32, data.settings,
                      weight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              MySearchParent(updateLocation: updateLocation,
                color: data.current.backcolor, place: data.place,
                controller: controller, settings: data.settings, real_loc: data.real_loc,
                secondColor: data.current.primary, textColor: data.current.textcolor,
                highlightColor: data.current.highlight, key: Key("${data.place}, ${data.current.backdrop}"),),
            ],
          )
      ),
      children: [
        Stack(
          children: [
            UpdatedNotifier(data: data, time: DateTime.now(), key: Key(DateTime.now().toString()),),
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if(constraints.maxWidth > 500.0) {
                    return Circles(500, data, 0.5, data.current.primary);
                  } else {
                    return Circles(constraints.maxWidth * 0.97, data, 0.5, data.current.primary);
                  }
                }
            ),
          ],
        ),
        NewTimes(data, true),
        buildHihiDays(data),
        buildGlanceDay(data),
        providerSelector(data.settings, updateLocation, data.current.textcolor, data.current.highlight,
        data.current.primary, data.provider, "${data.lat}, ${data.lng}", data.real_loc),
        const Padding(padding: EdgeInsets.only(bottom: 20))
      ],
    ),
  );
}

Widget TabletLayout(data, updateLocation, context) {

  final FloatingSearchBarController controller = FloatingSearchBarController();

  FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;

  Size size = view.physicalSize / view.devicePixelRatio;

  double toppad = MediaQuery.of(context).viewPadding.top;

  double width = size.width - min(max(size.width * 0.4, 400), 450);
  double heigth = min(max(width / 1.5, 450), 510);

  return Scaffold(
    backgroundColor: data.current.backcolor,
    drawer: MyDrawer(primary: data.current.backup_primary, back: data.current.backup_backcolor,
        settings: data.settings, image: data.current.backdrop),
    body: RefreshIndicator(
      onRefresh: () async {
        await updateLocation("${data.lat}, ${data.lng}", data.real_loc);
      },
      backgroundColor: WHITE,
      color: data.current.backcolor,
      displacement: 100,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 10, bottom: 10, top: toppad + 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: Column(
                  children: [
                    SizedBox(
                      height: heigth * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 100),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ParrallaxBackground(imagePath1: data.current.backdrop, key: Key(data.place),
                                    color: darken(data.current.backcolor, 0.1),),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 100, left: 30, bottom: 31),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0, bottom: 0),
                                        child: comfortatext("${data.current.temp}°", 65, data.settings,
                                            color: data.current.colorpop, weight: FontWeight.w200),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: comfortatext(data.current.text, 25, data.settings, color: data.current.colorpop),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              LayoutBuilder(
                                  builder: (BuildContext context, BoxConstraints constraints) {
                                    if(constraints.maxWidth > 400.0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: Circles(400, data, 0.6, data.current.colorpop, align: Alignment.centerRight),
                                      );
                                    } else {
                                      return Circles(constraints.maxWidth * 0.90, data, 1, data.current.primary);
                                    }
                                  }
                              ),
                              MySearchParent(updateLocation: updateLocation,
                                color: data.current.highlight, place: data.place,
                                controller: controller, settings: data.settings, real_loc: data.real_loc,
                                secondColor: data.current.primary, textColor: data.current.textcolor,
                                highlightColor: data.current.primary, key: Key(data.place),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    buildHihiDays(data),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 50),
                  child: Column(
                    children: [
                      NewTimes(data, false),
                      buildGlanceDay(data),
                      providerSelector(data.settings, updateLocation, data.current.textcolor, data.current.highlight, data.current.primary,
                          data.provider, "${data.lat}, ${data.lng}", data.real_loc),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    )
  );
}

import 'package:flutter/material.dart';
import 'package:weathify/settings_page.dart';
import 'package:weathify/ui_helper.dart';

import 'package:url_launcher/url_launcher.dart';

final imageText = [
  'Clear Night',
  'Partly Cloudy',
  'Clear Sky',
  'Overcast',
  'Haze',
  'Rain',
  'Sleet',
  'Drizzle',
  'Thunderstorm',
  'Heavy Snow',
  'Fog',
  'Snow',
  'Heavy Rain',
  'Cloudy Night',
  'Error Screen'
];

final imageLink = [
  'https://unsplash.com/photos/time-lapse-photography-of-stars-at-nighttime-YvOT1lJ0NPQ',
  'https://unsplash.com/photos/ocean-under-clouds-Plkff-dVfNM',
  'https://unsplash.com/photos/blue-and-white-sky-d12K_FkCUN8',
  'https://unsplash.com/photos/view-of-calm-sea-nQM2oClouhY',
  'https://unsplash.com/photos/silhouette-of-trees-and-sea-L-HxY2XlaaY',
  'https://unsplash.com/photos/water-droplets-on-clear-glass-1YHXFeOYpN0',
  'https://unsplash.com/photos/snow-covered-trees-and-road-during-daytime-wyM1KmMUSbA',
  'https://unsplash.com/photos/a-view-of-a-plane-through-a-rain-covered-window-UsYOap7yIMg',
  'https://unsplash.com/photos/lightning-strike-on-the-sky-ley4Kf2iG7Y',
  'https://unsplash.com/photos/snowy-forest-on-mountainside-during-daytime-t4hA-zCALUQ',
  'https://unsplash.com/photos/green-trees-on-mountain-under-white-clouds-during-daytime-obQacWYxB1I',
  'https://unsplash.com/photos/bokeh-photography-of-snows-SH4GNXNj1RA',
  'https://unsplash.com/photos/dew-drops-on-glass-panel-bWtd1ZyEy6w',
  'https://unsplash.com/photos/blue-and-white-starry-night-sky-NpF9JLGYfeQ',
  'https://unsplash.com/photos/snow-covered-grass-at-daytime-KQWEuSh_VR0',
];
class InfoPage extends StatefulWidget {
  final Color primary;
  final Color back;
  final settings;

  const InfoPage({Key? key, required this.primary, required this.settings, required this.back})
      : super(key: key);

  @override
  _InfoPageState createState() =>
      _InfoPageState(primary: primary, settings: settings, back: back);
}

class _InfoPageState extends State<InfoPage> {
  final primary;
  final settings;
  final back;

  _InfoPageState({required this.primary, required this.settings, required this.back});

  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    List<Color> colors = getColors(primary, back, settings, 0);
    Color link = colors[1];

    return Scaffold(
        backgroundColor: colors[0],
        appBar: AppBar(
            toolbarHeight: 65,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            elevation: 0,
            leadingWidth: 50,
            backgroundColor: colors[0],
            title: comfortatext(translation('About', settings["Language"]), 25, settings,
                color: colors[2]),
            leading: IconButton(
              onPressed: () {
                goBack();
              },
              icon: Icon(
                Icons.arrow_back,
                color: colors[2],
              ),
            )),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: Container(
                    height: 150.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/icons/vulogo.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                comfortatext(
                    translation(
                        'Weathify is a beautiful minimalist weather app.',
                        settings["Language"]),
                    22, settings, color: colors[2], align: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: colors[5],
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                            child: comfortatext(
                                translation('Features:', settings["Language"]), 20, settings, color: colors[2]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              comfortatext(
                                  '\u2022${translation('accurate weather forecast', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('open source', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('no ads', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('no data collected', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('minimalist design', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('dynamically adapting color scheme', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('languages support', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('place search', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('weather for current location', settings["Language"])}',
                                  22, settings, color: colors[2]),
                              comfortatext(
                                  '\u2022${translation('unit swapping', settings["Language"])}',
                                  22, settings, color: colors[2]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: colors[5],
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                            child: comfortatext(
                                translation('Developed by:', settings["Language"]), 20, settings,
                                color: colors[2]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: comfortatext('Anuj, Kush, Mohit (Group 2', 22, settings, color: colors[2]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: comfortatext(
                                    '(adhungel00@gmail.com)', 18, settings, color: colors[2]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                      onPressed: () async {
                                        await _launchUrl(
                                            'https://github.com/anuj287971/weathify');
                                      },
                                      child: comfortatext('source code', 20, settings,
                                          color: link)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ])),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: colors[5],
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                          child: comfortatext(
                              translation('Weather data from:', settings["Language"]),
                              20, settings, color: colors[2]),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            await _launchUrl(
                                'https://open-meteo.com');
                          },
                          child: comfortatext('open-meteo.com', 20, settings,
                              color: link)),
                      TextButton(
                          onPressed: () async {
                            await _launchUrl(
                                'https://www.rainviewer.com/api.html');
                          },
                          child: comfortatext('www.rainviewer.com', 20, settings,
                              color: link)),
                      TextButton(
                          onPressed: () async {
                            await _launchUrl('https://www.weatherapi.com/');
                          },
                          child: comfortatext('www.weatherapi.com', 20, settings,
                              color: link))
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: colors[5],
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                              const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                              child: comfortatext(
                                  translation('Images used:', settings["Language"]), 20, settings,
                                  color: colors[2]),
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: imageText.length,
                            itemExtent: 40,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      _launchUrl(imageLink[index]);
                                    },
                                    child: comfortatext(
                                        translation(
                                            imageText[index], settings["Language"]),
                                        20, settings,
                                        color: link),
                                  ),
                                ),
                              );
                            },
                          )
                        ]),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}



Future<void> _launchUrl(String url) async {
  final Uri _url = Uri.parse(url);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
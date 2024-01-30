import 'package:flutter/material.dart';
import 'package:myweatherapp/locale_provider.dart';
import 'package:myweatherapp/models.dart';
import 'package:myweatherapp/service.dart';
import 'package:myweatherapp/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/all_locales.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>(
      create: (_) => LocaleProvider(),
      builder: (context, child) {
        return MaterialApp(
          title: 'myweatherApp',
          supportedLocales: AllLocales.all,
          locale: Provider.of<LocaleProvider>(context).locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final cityTextController = TextEditingController();
  final dataService = DataService(apiKey: '5c48dee52002a621e87a74b0c4dfb2c8', defaultLanguage: "ru");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Align(
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context)!.appname,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30,
              fontFamily: 'instagram',
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // Language Buttons
          Align(
            alignment: const Alignment(-0.9, 0.9),
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              onPressed: () {
                // Toggle between EN and RU
                final isEnglish = Provider.of<LocaleProvider>(context, listen: false).locale == AllLocales.all[0];
                Locale newLocale = isEnglish ? AllLocales.all[1] : AllLocales.all[0];
                Provider.of<LocaleProvider>(context, listen: false).setLocale(newLocale);
              },
              child: Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  return Text(
                    localeProvider.locale == AllLocales.all[0] ? "EN" : "RU",
                  );
                },
              ),
            ),
          ),

          // Weather Information and Search
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                // Trigger the FutureBuilder to reload with new data
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                fixedSize: const Size(50, 50),
              ),
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use FutureBuilder for handling the asynchronous API call
                FutureBuilder<WeatherResponse>(
                  future: dataService.getWeather(cityTextController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while waiting
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final response = snapshot.data!;
                      return Column(
                        children: [
                          Text(
                            cityTextController.text,
                            style: const TextStyle(fontSize: 30, color: Colors.black),
                          ),
                          Text(
                            '${response.tempInfo.temperature}°',
                            style: response.tempInfo.temperature < 15
                                ? const TextStyle(fontSize: 30, color: Colors.blue)
                                : const TextStyle(fontSize: 30, color: Colors.orange),
                          ),
                          Text(
                            response.weatherInfo.description,
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                          Image.network(response.iconUrl),
                        ],
                      );
                    } else {
                      return Container(); // Return an empty container if there's no data
                    }
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: cityTextController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.city.toString(),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
  const MyApp({super.key});

  // This widget is the root of your application.
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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final cityTextController = TextEditingController();
  final dataService = DataService();
  WeatherResponse? _response;

  void search() async {
    final response = await dataService.getWeather(cityTextController.text, context);
    setState(() => _response = response);
  }

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
              child: const Text("EN"),
              onPressed: () => Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(AllLocales.all[0]),
            ),
          ),
          Align(
            alignment: const Alignment(0.9, 0.9),
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              child: const Text("RU"),
              onPressed: () => Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(AllLocales.all[1]),
            ),
          ),

          // Weather Information and Search
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_response != null)
                  Column(
                    children: [
                      Text(
                        cityTextController.text,
                        style: const TextStyle(fontSize: 30, color: Colors.black),
                      ),
                      Text(
                        '${_response!.tempInfo.temperature}°',
                        style: _response!.tempInfo.temperature < 15
                            ? const TextStyle(fontSize: 30, color: Colors.blue)
                            : const TextStyle(fontSize: 30, color: Colors.orange),
                      ),
                      Text(
                        _response!.weatherInfo.description,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      Image.network(_response!.iconUrl),
                    ],
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
                ElevatedButton(
                  onPressed: search,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    fixedSize: Size(200, 50),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.search.toString(),
                    style: TextStyle(color: Colors.white),
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
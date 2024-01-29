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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final cityTextController = TextEditingController();
    final dataService = DataService();

    return Stack(
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
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherInfo(context, cityTextController, dataService),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(BuildContext context, TextEditingController cityTextController, DataService dataService) {
    return FutureBuilder<WeatherResponse>(
      future: dataService.getWeather(cityTextController.text, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while waiting for data
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
    );
  }
}

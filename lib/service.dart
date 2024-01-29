import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myweatherapp/models.dart';
import 'package:myweatherapp/flutter_gen/gen_l10n/app_localizations.dart';

class DataService {
  Future<WeatherResponse> getWeather(String city, BuildContext context) async {
    try {
      final queryParameters = {
        'q': city,
        'appid': '5c48dee52002a621e87a74b0c4dfb2c8',
        'units': 'metric',
        'lang': AppLocalizations.of(context)!.language,
      };

      final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherResponse.fromJson(json);
      } else {
        // Handle non-200 status codes
        print('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Handle other exceptions
      print('An error occurred: $e');
      throw Exception('Failed to load weather data');
    }
  }
}

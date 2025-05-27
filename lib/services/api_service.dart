import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:green/models/sensor_reading.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String baseUrl = 'http://157.230.242.152:8000/api';

  Future<List<SensorReading>> getSensorReadings() async {
    final response = await http.get(Uri.parse('$baseUrl/sensor-readings'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SensorReading.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load sensor readings');
    }
  }

  Future<SensorHistory> getSensorHistory() async {
    print('Fetching data from: $baseUrl/history');
    final response = await http.get(Uri.parse('$baseUrl/history'));
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return SensorHistory.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor history');
    }
  }

  Future<DailySensorData> getTodayData() async {
    final response = await http.get(Uri.parse('$baseUrl/today'));
    return _parseResponse(response);
  }

  Future<DailySensorData> getDataByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse('$baseUrl/history/view'); // Changed endpoint
    
    print('Fetching data for date: $formattedDate');
    
    try {
      final response = await http.post( // Changed to POST
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'date': formattedDate}),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['data'] == null) {
          return DailySensorData(message: responseBody['message'] ?? 'No data', data: []);
        }
        return DailySensorData.fromJson(responseBody);
      } else {
        throw HttpException(
          'Server error: ${response.statusCode}',
          uri: url,
        );
      }
    } on SocketException {
      throw Exception('No Internet Connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  DailySensorData _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      return DailySensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  Future<List<SensorReading>> getSensorHistoryByDate(String date) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/history/view'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'date': date,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> readings = data['data'];
    return readings.map((json) => SensorReading.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load history');
  }
}
}
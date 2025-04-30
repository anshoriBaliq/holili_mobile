// sensor_models.dart
class SensorReading {
  final int id;
  final double temperature;
  final int ppm;
  final double waterLevel;
  final DateTime createdAt;

  SensorReading({
    required this.id,
    required this.temperature,
    required this.ppm,
    required this.waterLevel,
    required this.createdAt,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    try{
    return SensorReading(
      id: json['id'],
      temperature: json['temperature'].toDouble(),
      ppm: json['ppm'],
      waterLevel: json['water_level'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
    } catch (e) {
      throw FormatException('Failed to parse SensorReading: $e');
    }
  }
}

class SensorHistory {
  final String message;
  final Map<String, dynamic> date; // Perhatikan ini berbeda dari sebelumnya

  SensorHistory({
    required this.message,
    required this.date,
  });

  factory SensorHistory.fromJson(Map<String, dynamic> json) {
    return SensorHistory(
      message: json['message'],
      date: json['date'], // Sesuaikan dengan response API
    );
  }
}

class DailySensorData {
  final String message;
  final List<SensorReading> data;

  DailySensorData({
    required this.message,
    required this.data,
  });

  factory DailySensorData.fromJson(Map<String, dynamic> json) {
    return DailySensorData(
      message: json['message'] ?? 'No message',
      data: json['data'] != null 
          ? (json['data'] as List).map((e) => SensorReading.fromJson(e)).toList()
          : [],
    );
  }
}
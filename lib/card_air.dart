import 'dart:async';
import 'package:flutter/material.dart';
import 'models/sensor_reading.dart';
import 'services/api_service.dart';

class AdditionalCard extends StatefulWidget {
  const AdditionalCard({super.key});

  @override
  _AdditionalCardState createState() => _AdditionalCardState();
}

class _AdditionalCardState extends State<AdditionalCard> {
  final ApiService apiService = ApiService();
  double currentDistance = 2.5;
  final double maxDistance = 10.0;
  final double minDistance = 3.0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData(); // ambil data pertama kali
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchData(); // update tiap 5 detik
    });
  }

  void fetchData() async {
    try {
      List<SensorReading> readings = await apiService.getSensorReadings();
      if (readings.isNotEmpty) {
        setState(() {
          currentDistance = readings.last.waterLevel;
        });
      }
    } catch (e) {
      print("Error fetching water level: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // matikan timer saat widget dihapus
    super.dispose();
  }

  double getWaterLevelPercentage() {
    double level =
        (maxDistance - currentDistance) / (maxDistance - minDistance);
    return level.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    double waterLevel = getWaterLevelPercentage();

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul dengan ikon air
            Row(
              children: [
                Icon(Icons.water_drop, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  'Ketinggian Air',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Jarak: ${currentDistance.toStringAsFixed(1)} cm',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              'Level: ${(waterLevel * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 12),
            // Bar horizontal animasi
            Stack(
              children: [
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 800),
                  height: 24,
                  width: MediaQuery.of(context).size.width *
                      0.75 *
                      waterLevel,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.lightBlueAccent, Colors.blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
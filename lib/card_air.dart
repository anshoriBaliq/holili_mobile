import 'package:flutter/material.dart';
import 'models/sensor_reading.dart';
import 'services/api_service.dart';

class AdditionalCard extends StatefulWidget {
  const AdditionalCard({super.key});

  @override
  _AdditionalCardState createState() => _AdditionalCardState();
}

class _AdditionalCardState extends State<AdditionalCard> {
  late Future<List<SensorReading>> futureReadings;
  final ApiService apiService = ApiService();
  double currentDistance = 2.5; // cm, ambil dari database nanti
  final double maxDistance = 10.0; // cm (tanki kosong)
  final double minDistance = 3.0; // cm (tanki penuh)

  @override
  void initState() {
    super.initState();
    futureReadings = apiService.getSensorReadings();
  }

  double getWaterLevelPercentage() {
    double level =
        (maxDistance - currentDistance) / (maxDistance - minDistance);
    return level.clamp(0.0, 1.0);
  }

  void updateDistanceFromDatabase(double newDistance) {
    setState(() {
      currentDistance = newDistance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SensorReading>>(
      future: futureReadings,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final latestReading = snapshot.data!.last;
          currentDistance = latestReading.waterLevel;

          double waterLevel = getWaterLevelPercentage();

          return Card(
            margin: EdgeInsets.all(16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors
                .white, // Mengubah warna latar belakang kartu menjadi putih
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
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

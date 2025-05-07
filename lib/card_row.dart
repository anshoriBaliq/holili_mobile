import 'dart:async'; // Untuk Timer
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'services/api_service.dart';
import 'models/sensor_reading.dart';

class CardRow extends StatefulWidget {
  const CardRow({super.key});

  @override
  _CardRowState createState() => _CardRowState();
}

class _CardRowState extends State<CardRow> {
  List<SensorReading> _readings = [];
  final ApiService apiService = ApiService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData(); // ambil data pertama kali
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchData(); // ambil data tiap 5 detik
    });
  }

  void fetchData() async {
    try {
      List<SensorReading> newReadings = await apiService.getSensorReadings();
      setState(() {
        _readings = newReadings;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // matikan timer saat widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_readings.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final latestReading = _readings.last;

    return Row(
      children: [
        // Card Suhu
        Expanded(
          child: buildCard(
            'assets/suhu.json',
            '${latestReading.temperature}°C',
          ),
        ),

        // Card Daun
        Expanded(
          child: buildCard(
            'assets/daun.json',
            '${latestReading.ppm} PPM',
          ),
        ),
      ],
    );
  }

  Widget buildCard(String assetPath, String valueText) {
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Lottie.asset(
            assetPath,
            height: 80,
            width: 80,
          ),
          SizedBox(height: 4),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
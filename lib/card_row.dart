import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import paket Lottie
import 'services/api_service.dart';
import 'models/sensor_reading.dart';

class CardRow extends StatefulWidget {
  const CardRow({super.key});

  @override
  _CardRowState createState() => _CardRowState();
}

class _CardRowState extends State<CardRow> {
  late Future<List<SensorReading>> futureReadings;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureReadings = apiService.getSensorReadings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SensorReading>>(
        future: futureReadings,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            //ambil data terbaru(indeks pertama)
            final latestReading = snapshot.data!.last;

            return Row(
              children: [
                // Card Suhu
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // Mengubah warna latar belakang menjadi putih
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
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Menempatkan konten di tengah
                      children: [
                        SizedBox(height: 8), // Jarak antara judul dan gambar
                        Lottie.asset(
                          'assets/suhu.json', // Ganti dengan path animasi Lottie Anda
                          height: 80, // Sesuaikan tinggi animasi
                          width: 80, // Sesuaikan lebar animasi
                        ),
                        SizedBox(height: 4), // Jarak antara gambar dan nilai
                        Text(
                          '${latestReading.temperature}°C',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors
                                .black, // Mengubah warna teks menjadi hitam
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Daun
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors
                          .white, // Mengubah warna latar belakang menjadi putih
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
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Menempatkan konten di tengah
                      children: [
                        SizedBox(height: 8), // Jarak antara judul dan gambar
                        Lottie.asset(
                          'assets/daun.json', // Ganti dengan path animasi Lottie Anda
                          height: 80, // Sesuaikan tinggi animasi
                          width: 80, // Sesuaikan lebar animasi
                        ),
                        SizedBox(height: 4), // Jarak antara gambar dan nilai
                        Text(
                          '${latestReading.ppm} PPM',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors
                                .black, // Mengubah warna teks menjadi hitam
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      );
  }
}

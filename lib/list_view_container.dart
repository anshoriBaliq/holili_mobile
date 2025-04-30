import 'package:flutter/material.dart';
import 'package:green/history_screen.dart';
import 'models/sensor_reading.dart';
import 'package:green/services/api_service.dart';

class ListViewContainer extends StatefulWidget {
  const ListViewContainer({super.key});

  @override
  _ListViewContainerState createState() => _ListViewContainerState();
}

class _ListViewContainerState extends State<ListViewContainer> {
  final ApiService _apiService = ApiService();
  late Future<SensorHistory> _futureHistory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _futureHistory = _apiService.getSensorHistory();
      await _futureHistory;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              icon: Icon(Icons.calendar_today, size: 16),
              label: Text('Lihat History Lengkap'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_isLoading)
                    LinearProgressIndicator(minHeight: 2)
                  else
                    SizedBox(height: 2),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: FutureBuilder<SensorHistory>(
                        future: _futureHistory,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return _buildErrorWidget(snapshot.error.toString());
                          } else if (!snapshot.hasData || 
                                    snapshot.data!.date.isEmpty) {
                            return _buildEmptyWidget();
                          }
                          return _buildHistoryList(snapshot.data!);
                        },
                      ),
                    ),
                  ),                      
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(SensorHistory history) {
    final dates = history.date.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final dailyReadings = (history.date[date] as List)
            .map((e) => SensorReading.fromJson(e))
            .toList();
        
        // dailyReadings.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        final latestReading = dailyReadings.first;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showDailyDetails(context, date, dailyReadings),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${dailyReadings.length} data',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildReadingInfo('Suhu', '${latestReading.temperature}°C'),
                  _buildReadingInfo('PPM', '${latestReading.ppm}'),
                  _buildReadingInfo('Jarak Air', '${latestReading.waterLevel} cm'),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showDailyDetails(context, date, dailyReadings),
                      icon: Icon(Icons.list_alt, size: 16),
                      label: Text('Lihat Detail Harian'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showDailyDetails(BuildContext context, String date, List<SensorReading> readings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Text(
              'Detail Sensor - ${_formatDate(date)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Total ${readings.length} Pembacaan', style: TextStyle(color: Colors.grey)),
            Divider(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: readings.length,
                itemBuilder: (context, index) {
                  final reading = readings[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   _formatTime(reading.recordedAt),
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.blue[700],
                          //   ),
                          // ),
                          SizedBox(height: 8),
                          _buildDetailRow('Suhu', '${reading.temperature}°C'),
                          _buildDetailRow('PPM', '${reading.ppm}'),
                          _buildDetailRow('Jarak Air', '${reading.waterLevel} cm'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 16),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tidak ada data history tersedia',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _loadData,
            child: Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

}
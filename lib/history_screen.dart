import 'package:flutter/material.dart';
import 'models/sensor_reading.dart';
import 'package:green/services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<DailySensorData> _futureData;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  int _jumlahData = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _selectedDate = DateTime.now();
      _isLoading = true;
    });
    try {
      _futureData = _apiService.getTodayData();
      await _futureData;

      _futureData.then((data) {
        if (mounted) setState(() => _jumlahData = data.data.length);
      });

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDataByDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _isLoading = true;
    });
    try {
      _futureData = _apiService.getDataByDate(date);
      await _futureData;

      _futureData.then((data) {
        if (mounted) setState(() => _jumlahData = data.data.length);
      });

    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
      }
      // Re-throw the error so FutureBuilder can catch it
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      _loadDataByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Sensor'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          if (_isLoading) LinearProgressIndicator() else SizedBox(height: 2),
          Expanded(
            child: _buildDataContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTodayData,
        tooltip: 'Refresh Data Hari Ini',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Data Sensor:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '$_jumlahData',
              style: TextStyle(
                fontSize: 19,
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              DateFormat('dd MMMM yyyy').format(_selectedDate),
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent() {
    return FutureBuilder<DailySensorData>(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return _buildEmptyWidget();
        }
        return _buildDataList(snapshot.data!);
      },
    );
  }

  Widget _buildDataList(DailySensorData data) {
    return RefreshIndicator(
      onRefresh: () => _loadDataByDate(_selectedDate),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: data.data.length,
        itemBuilder: (context, index) {
          final reading = data.data[index];
          return _buildReadingCard(reading);
        },
      ),
    );
  }

  Widget _buildReadingCard(SensorReading reading) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waktu: ${_formatTime(reading.createdAt)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  'ID: ${reading.id}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildDataRow(Icons.thermostat, 'Suhu', '${reading.temperature}°C'),
            _buildDataRow(Icons.eco, 'PPM', '${reading.ppm}'),
            _buildDataRow(Icons.water_drop, 'Jarak Air', '${reading.waterLevel} cm'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          SizedBox(width: 12),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadDataByDate(_selectedDate),
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
            'Tidak ada data untuk tanggal ini',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => _loadDataByDate(_selectedDate),
            child: Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }
}
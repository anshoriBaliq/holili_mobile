import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CardWithTextFieldAndButtons extends StatefulWidget {
  const CardWithTextFieldAndButtons({super.key});

  @override
  State<CardWithTextFieldAndButtons> createState() =>
      _CardWithTextFieldAndButtonsState();
}

class _CardWithTextFieldAndButtonsState
    extends State<CardWithTextFieldAndButtons> {
  final TextEditingController _controller = TextEditingController();
  final String esp32Ip = "10.10.6.164"; // Ganti IP sesuai ESP32 kamu

  void updateTargetTDS() async {
    final target = _controller.text.trim();
    if (target.isEmpty) return;

    final url = Uri.parse("http://$esp32Ip/set-tds?target=$target");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _showSnackBar("Berhasil!", "TDS Target diperbarui ke $target", Colors.green);
      } else {
        throw Exception("Gagal update TDS: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error", "Terjadi masalah: ${e.toString()}", Colors.red);
    }
  }

  void _showSnackBar(String title, String message, Color color) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              size: 60,
              color: color,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text("Tutup", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showCustomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda yakin ingin mengirim TDS ini?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(); // tutup dialog
              },
            ),
            TextButton(
              child: const Text("Kirim"),
              onPressed: () {
                Navigator.of(context).pop(); // tutup dialog
                updateTargetTDS(); // jalankan fungsi kirim
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Masukkan Target TDS',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Target TDS (ppm)',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showCustomDialog,
              child: const Text("Kirim ke ESP32"),
            ),
          ],
        ),
      ),
    );
  }
}

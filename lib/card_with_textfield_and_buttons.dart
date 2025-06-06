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
  final String esp32Ip = "192.168.167.57"; // Ganti IP sesuai ESP32 kamu
  bool isOn = false;

  // Fungsi untuk mengirimkan perintah ke ESP32 untuk menghidupkan atau mematikan sistem
  void controlSystem(String action) async {
    final url = Uri.parse("http://$esp32Ip/$action");

    try {
      final response = await http.get(url);
      final message = response.body.trim();
      
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200){
        // Jika status sukses dan pesan dari ESP sesuai
        _showSnackBar("Berhasil!", message, Colors.green);
      } else {
        // Tetap sukses statusCode tapi respon tidak sesuai harapan
        _showSnackBar("Gagal!", "Respon tidak valid: $message", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error", "Terjadi masalah saat mengirim perintah", Colors.red);
    }
  }

  // Fungsi untuk mengirimkan data TDS ke ESP32
  void updateTargetTDS() async {
    final target = _controller.text.trim();
    if (target.isEmpty) return;

    final url = Uri.parse("http://$esp32Ip/set-tds?value=$target");

    try {
      final response = await http.get(url);
      final message = response.body.trim();
      
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200){
        // Jika status sukses dan pesan dari ESP sesuai
        _showSnackBar("Berhasil!", message, Colors.green);
      } else {
        // Tetap sukses statusCode tapi respon tidak sesuai harapan
        _showSnackBar("Gagal!", "Respon tidak valid: $message", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error", "Terjadi masalah saat mengirim TDS", Colors.red);
    }
  }

  // Fungsi untuk menampilkan snack bar
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

  // Fungsi untuk menampilkan dialog konfirmasi
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Masukkan Target TDS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
            
            // Bagian On/Off
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isOn ? 'Turn Off' : 'Turn On', // Judul berubah berdasarkan status
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isOn = !isOn; // Toggle status
                          // Mengirimkan perintah ke ESP32 untuk mengaktifkan atau menonaktifkan sistem
                          controlSystem(isOn ? 'turn-on' : 'turn-off');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOn ? Colors.green : Colors.red, // Ubah warna tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Icon(
                        isOn ? Icons.toggle_on : Icons.toggle_off, // Ikon berubah
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                // Tombol Kirim
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '', // Text untuk tombol kirim
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _showCustomDialog,
                      child: const Text(
                        "Kirim ke ESP32",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

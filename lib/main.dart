import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'card_view_above.dart';
import 'card_row.dart';
import 'card_with_textfield_and_buttons.dart';
import 'list_view_container.dart';
import 'card_air.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'history_screen.dart'; // Pastikan file history_screen.dart sudah ada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardViewAbove(),
            CardRow(),
            AdditionalCard(),
            CardWithTextFieldAndButtons(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryScreen()),
                      );
                    },
                    child: Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
            // SizedBox(
            //   height: 300,
            //   child: ListViewContainer(),
            // ),
          ],
        ),
      ),
    );
  }
}
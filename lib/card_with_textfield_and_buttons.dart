import 'package:flutter/material.dart';

class CardWithTextFieldAndButtons extends StatefulWidget {
  final TextEditingController controller;

  CardWithTextFieldAndButtons({required this.controller});

  @override
  _CardWithTextFieldAndButtonsState createState() =>
      _CardWithTextFieldAndButtonsState();
}

class _CardWithTextFieldAndButtonsState
    extends State<CardWithTextFieldAndButtons> {
  bool isOn = false; // Initial state of the toggle button

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 8, // Increased elevation for better shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // More padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target PPM',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Blue color for the header
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: 'Masukan Target PPM Baru',
                labelStyle: TextStyle(
                    color: const Color.fromARGB(
                        255, 0, 0, 0)), // Custom label color
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: 2), // Focused border style
                  borderRadius: BorderRadius.circular(
                      10), // Rounded corners for the input
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isOn
                          ? 'Turn Off'
                          : 'Turn On', // Title changes based on state
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8), // Space between title and button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isOn = !isOn; // Toggle the state between on and off
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOn
                            ? Colors.green
                            : Colors.red, // Change color based on state
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOn
                                ? Icons.toggle_on
                                : Icons.toggle_off, // Toggle icon changes
                            size: 40,
                            color: Colors.white, // Icon color
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                  children: [
                    Text(
                      'Send', // Title text
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Bold title text
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8), // Space between title and button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Send button action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Green background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Icon(
                        Icons.send, // Send icon inside the button
                        size: 30,
                        color: Colors.white, // Icon color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ), // Space between previous section and the toggle button
      ),
    );
  }
}

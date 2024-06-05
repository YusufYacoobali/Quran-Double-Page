import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'السلام عليكم ورحمة الله وبركاته',
                style: TextStyle(
                  fontSize: 29,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.bookmark, size: 30, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'To Use Bookmarks:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '1. While viewing the PDF, tap on the bookmarks icon to save the current page as a bookmark.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '2. To access your bookmarks later, tap on the bookmarks icon again and select the desired bookmark from the list.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.star, size: 30, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  'Praise Our App:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Kindly support our efforts by leaving positive reviews on the app store. Your feedback encourages charitable actions.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Additionally, feel free to share any suggestions or enhancements you would like us to consider. Your input is invaluable to us.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

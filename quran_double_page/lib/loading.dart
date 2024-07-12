import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quran_double_page/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndDownloadAssets();
  }

  Future<void> _checkAndDownloadAssets() async {
    print('err1 checking');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool assetsDownloaded = prefs.getBool('19assetsDownloaded1') ?? false;

    if (!assetsDownloaded) {
      print('err1 not downloaded');
      await _downloadAssets();
      await prefs.setBool('19assetsDownloaded1', true);
    }

    setState(() {
      _isLoading = false;
    });

    // Navigate to the main screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyPDFViewer()),
    );
  }

  Future<void> _downloadAssets() async {
    print('err1 Requesting storage permission');
    var status = await Permission.manageExternalStorage.request();
    print('err1 gotten storage permission');

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      print('err1 Permission granted, starting download');
      List<Map<String, String>> files = [
        {
          'url':
              'https://drive.google.com/uc?export=download&id=1g_i-FY-K4pIyROocf0zSLePZSGLzd5A1',
          'name': 'quran_source_double_close.pdf'
        },
        {
          'url':
              'https://drive.google.com/uc?export=download&id=1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp',
          'name': 'quran_source_v_l_s.pdf'
        },
        {
          'url':
              'https://drive.google.com/uc?export=download&id=1yA767zYgKyYV3OwxtJpGXr8UHUgoVhKN',
          'name': 'quran_source_v.pdf'
        },
      ];

      final directory = await getApplicationDocumentsDirectory();

      for (var file in files) {
        try {
          final response = await http.get(Uri.parse(file['url']!));

          if (response.statusCode == 200) {
            final filePath = '${directory.path}/${file['name']}';
            await File(filePath).writeAsBytes(response.bodyBytes);
            print('${file['name']} downloaded successfully err1');
          } else {
            print(
                'err1 Failed to download ${file['name']}: ${response.statusCode}');
          }
        } catch (e) {
          print('err1 Error downloading ${file['name']}: $e');
        }
      }
    } else {
      print('err1 Storage permission denied');
      // You might want to show a dialog to the user explaining why the permission is needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading ? CircularProgressIndicator() : Container(),
      ),
    );
  }
}

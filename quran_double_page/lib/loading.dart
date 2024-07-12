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
    bool assetsDownloaded = prefs.getBool('13assetsDownloaded1') ?? false;

    if (!assetsDownloaded) {
      print('err1 not downloaded');
      await _downloadAssets();
      await prefs.setBool('13assetsDownloaded1', true);
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

  // Future<void> _downloadAssets() async {
  //   //var status = await Permission.storage.request();
  //   print('err1 asking');
  //   var status = await Permission.manageExternalStorage.request();
  //   print('err1 receieved permission');

  //   if (status.isGranted) {
  //     print('err1 trying to downloaded');
  //     // List<String> urls = [
  //     //   'https://drive.google.com/uc?export=download&id=1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp',
  //     //   'https://drive.google.com/uc?export=download&id=1fN7ISWdsscITDAN5K1-A2lYznGrUdECh',
  //     //   'https://drive.google.com/uc?export=download&id=1yA767zYgKyYV3OwxtJpGXr8UHUgoVhKN',
  //     // ];

  //     // Directory appDocDir = await getApplicationDocumentsDirectory();
  //     // for (int i = 0; i < urls.length; i++) {
  //     //   String fileName = 'file$i.pdf'; // Assign a unique name for each file
  //     //   String filePath = '${appDocDir.path}/$fileName';

  //     //   http.Response response = await http.get(Uri.parse(urls[i]));
  //     //   File file = File(filePath);
  //     //   await file.writeAsBytes(response.bodyBytes);

  //     List<String> urls = [
  //       'https://drive.google.com/uc?export=download&id=1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp',
  //       'https://drive.google.com/uc?export=download&id=1fN7ISWdsscITDAN5K1-A2lYznGrUdECh',
  //       'https://drive.google.com/uc?export=download&id=1yA767zYgKyYV3OwxtJpGXr8UHUgoVhKN',
  //     ];

  //     final directory = await getApplicationDocumentsDirectory();

  //     for (int i = 0; i < urls.length; i++) {
  //       final url = urls[i];
  //       final response = await http.get(Uri.parse(url));

  //       if (response.statusCode == 200) {
  //         final file = File('${directory.path}/file_$i.ext');
  //         await file.writeAsBytes(response.bodyBytes);
  //         print('File $i downloaded successfully');
  //       } else {
  //         print('Failed to download file $i');
  //       }

  //       print('err1 downloaded');
  //     }
  //   } else {
  //     // The permission was denied
  //     print('err1 Storage permission denied');
  //   }

  //   // print('e1 trying to downloaded');
  //   // List<String> urls = [
  //   //   'https://drive.google.com/uc?export=download&id=1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp',
  //   //   'https://drive.google.com/uc?export=download&id=1fN7ISWdsscITDAN5K1-A2lYznGrUdECh',
  //   //   'https://drive.google.com/uc?export=download&id=1yA767zYgKyYV3OwxtJpGXr8UHUgoVhKN',
  //   // ];

  //   // Directory appDocDir = await getApplicationDocumentsDirectory();
  //   // for (int i = 0; i < urls.length; i++) {
  //   //   String fileName = 'file$i.pdf'; // Assign a unique name for each file
  //   //   String filePath = '${appDocDir.path}/$fileName';

  //   //   http.Response response = await http.get(Uri.parse(urls[i]));
  //   //   File file = File(filePath);
  //   //   await file.writeAsBytes(response.bodyBytes);
  //   //   print('e1 downloaded');
  //   // }
  // }

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
              'https://drive.google.com/uc?export=download&id=1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp',
          'name': 'quran_source_v_l_s.pdf'
        },
        {
          'url':
              'https://drive.google.com/uc?export=download&id=1fN7ISWdsscITDAN5K1-A2lYznGrUdECh',
          'name': 'quran_source_double_close.pdf'
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

  // Future<void> _downloadAssets() async {
  //   print('e1 trying to downloaded');
  //   Map<String, String> files = {
  //     '1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp': 'quran_source_v_l_s.pdf',
  //     '1fN7ISWdsscITDAN5K1-A2lYznGrUdECh': 'quran_source_double_close.pdf',
  //     '1yA767zYgKyYV3OwxtJpGXr8UHUgoVhKN': 'quran_source_v.pdf',
  //   };

  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   for (String fileId in files.keys) {
  //     String url = 'https://drive.google.com/uc?export=download&id=$fileId';
  //     String fileName = files[fileId]!;
  //     String filePath = '${appDocDir.path}/$fileName';

  //     http.Response response = await http.get(Uri.parse(url));
  //     File file = File(filePath);
  //     await file.writeAsBytes(response.bodyBytes);
  //   }
  //   print('e1 downloaded');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading ? CircularProgressIndicator() : Container(),
      ),
    );
  }
}

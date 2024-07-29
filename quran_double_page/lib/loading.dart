import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAndDownloadAssets();
  }

  Future<void> _checkAndDownloadAssets() async {
    print('err1 checking');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool assetsDownloaded = prefs.getBool('23assetsDownloaded1') ?? false;

    if (!assetsDownloaded) {
      if (!await checkExists()) {
        print('err1 not downloaded');
        await _downloadAssets();
      }
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

    do {
      print('err1 showing dialog');
      await Future.delayed(Duration(seconds: 3));
      status = await Permission.manageExternalStorage.request();
      await Future.delayed(Duration(seconds: 3));
    } while (!status.isGranted);

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
            setState(() {
              _progress += 0.33;
            });
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
    }
  }

  Future<bool> checkExists() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File portraitPDF = File('${appDocDir.path}/quran_source_v.pdf');
    final File portraitPDF2 = File('${appDocDir.path}/quran_source_v_l_s.pdf');
    final File landscapePDF =
        File('${appDocDir.path}/quran_source_double_close.pdf');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (await portraitPDF.exists() &&
        await landscapePDF.exists() &&
        await portraitPDF2.exists()) {
      await prefs.setBool('23assetsDownloaded1', true);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A6767), // Islamic-themed color
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom loading animation
                  const SpinKitCubeGrid(
                    color: Colors.white,
                    size: 80.0,
                  ),
                  const SizedBox(height: 20),
                  // Progress bar

                  // Informative message
                  const Text(
                    'Please ensure WiFi is enabled\nand storage access is granted\nAllow a moment for setup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white,
                    color: Color.fromARGB(255, 147, 150, 4),
                    minHeight: 10,
                  ),
                ],
              )
            : Container(),
      ),
    );
  }
}






// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:quran_double_page/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LoadingScreen extends StatefulWidget {
//   @override
//   _LoadingScreenState createState() => _LoadingScreenState();
// }

// class _LoadingScreenState extends State<LoadingScreen> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkAndDownloadAssets();
//   }

//   Future<void> _checkAndDownloadAssets() async {
//     print('err1 checking');
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     //bool assetsDownloaded = prefs.getBool('22assetsDownloaded1') ?? false;

//     if (!await checkExists()) {
//       print('err1 not downloaded');
//       await _downloadAssets();
//       //await prefs.setBool('22assetsDownloaded1', true);
//     }

//     setState(() {
//       _isLoading = false;
//     });

//     // Navigate to the main screen
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const MyPDFViewer()),
//     );
//   }

//   Future<void> _downloadAssets() async {
//     print('err1 Requesting storage permission');
//     var status = await Permission.manageExternalStorage.request();
//     print('err1 gotten storage permission');

//     do {
//       print('err1 showing dialog');
//       await Future.delayed(Duration(seconds: 3));
//       status = await Permission.manageExternalStorage.request();
//       await Future.delayed(Duration(seconds: 3));
//     } while (!status.isGranted);

//     if (status.isGranted) {
//       print('err1 Permission granted, starting download');
//       List<Map<String, String>> files = [
//         {
//           'url':
//               'https://drive.google.com/uc?export=download&id=1g_i-FY-K4pIyROocf0zSLePZSGLzd5A1',
//           'name': 'quran_source_double_close.pdf'
//         },
//         {
//           'url':
//               'https://drive.google.com/uc?export=download&id=1QC2JzWu_AFAjtATKgRQFSDxMFnYCzjnp',
//           'name': 'quran_source_v_l_s.pdf'
//         },
//         {
//           'url':
//               'https://drive.google.com/uc?export=download&id=1yA767zYgKyYV3OwxtJpGXr8UHUgoVhKN',
//           'name': 'quran_source_v.pdf'
//         },
//       ];

//       final directory = await getApplicationDocumentsDirectory();

//       for (var file in files) {
//         try {
//           final response = await http.get(Uri.parse(file['url']!));

//           if (response.statusCode == 200) {
//             final filePath = '${directory.path}/${file['name']}';
//             await File(filePath).writeAsBytes(response.bodyBytes);
//             print('${file['name']} downloaded successfully err1');
//           } else {
//             print(
//                 'err1 Failed to download ${file['name']}: ${response.statusCode}');
//           }
//         } catch (e) {
//           print('err1 Error downloading ${file['name']}: $e');
//         }
//       }
//     } else {
//       print('err1 Storage permission denied');
//     }
//   }

//   Future<bool> checkExists() async {
//     final Directory appDocDir = await getApplicationDocumentsDirectory();
//     final File portraitPDF = File('${appDocDir.path}/quran_source_v.pdf');
//     final File landscapePDF =
//         File('${appDocDir.path}/quran_source_double_close.pdf');
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     if (await portraitPDF.exists() && await landscapePDF.exists()) {
//       //await prefs.setBool('22assetsDownloaded1', true);
//       return true;
//     } else {
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF2A6767), // Islamic-themed color
//       body: Center(
//         child: _isLoading
//             ? const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Custom loading animation
//                   SpinKitCubeGrid(
//                     color: Colors.white,
//                     size: 80.0,
//                   ),
//                   SizedBox(height: 20),
//                   // Informative message
//                   Text(
//                     'Please ensure WiFi is enabled\nand storage access is granted\nAllow a moment for setup',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               )
//             : Container(),
//       ),
//     );
//   }
// }

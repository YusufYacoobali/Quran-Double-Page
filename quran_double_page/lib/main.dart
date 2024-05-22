import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyPDFViewer(),
    );
  }
}

class MyPDFViewer extends StatefulWidget {
  @override
  _MyPDFViewerState createState() => _MyPDFViewerState();
}

class _MyPDFViewerState extends State<MyPDFViewer> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    loadPDFFromAsset('assets/quran_source_v.pdf');
  }

  Future<void> loadPDFFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/quran_source_v.pdf');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    setState(() {
      pdfPath = tempFile.path;
      if (pdfPath != null) {
        print('PDF loaded successfully: $pdfPath');
      } else {
        print('Error loading PDF');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: pdfPath != null
          ? PDFView(
              filePath: pdfPath!,
              onError: (error) {
                print('PDF loading error: $error');
              },
              onViewCreated: (PDFViewController controller) {
                print('PDF loading successful!');
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}



// import 'dart:io'; // Import the 'dart:io' library for file operations
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Quran PDF Viewer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quran PDF App'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) =>
//                     QuranPdfViewer(pdfPath: 'assets/quran_source_v.pdf'),
//               ),
//             );
//           },
//           child: Text('Open Quran PDF'),
//         ),
//       ),
//     );
//   }
// }

// class QuranPdfViewer extends StatelessWidget {
//   final String pdfPath;

//   QuranPdfViewer({required this.pdfPath});

//   @override
//   Widget build(BuildContext context) {
//     print(
//         'Checking if PDF exists at: $pdfPath'); // Print the path to check if it's correct
//     // Check if the file exists
//     if (File(pdfPath).existsSync()) {
//       print(
//           'PDF exists at the specified path.'); // Print confirmation if file exists
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Quran PDF'),
//         ),
//         body: PDFView(
//           filePath: pdfPath,
//         ),
//       );
//     } else {
//       print(
//           'PDF does not exist at the specified path.'); // Print error message if file does not exist
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Error'),
//         ),
//         body: Center(
//           child: Text('PDF file not found.'),
//         ),
//       );
//     }
//   }
// }

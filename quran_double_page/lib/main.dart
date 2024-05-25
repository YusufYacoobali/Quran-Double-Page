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
  String? portraitPdfPath;
  String? landscapePdfPath;

  @override
  void initState() {
    super.initState();
    loadPDFFromAsset('assets/quran_source_v.pdf', isLandscape: false);
    loadPDFFromAsset('assets/quran_source_double_spaced.pdf',
        isLandscape: true);
  }

  Future<void> loadPDFFromAsset(String assetPath,
      {required bool isLandscape}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File(
        '${tempDir.path}/${isLandscape ? 'quran_source_double_spaced.pdf' : 'quran_source_v.pdf'}');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    setState(() {
      if (isLandscape) {
        landscapePdfPath = tempFile.path;
      } else {
        portraitPdfPath = tempFile.path;
      }
      print('PDF loaded successfully: ${tempFile.path}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final String? pdfPath = orientation == Orientation.portrait
              ? portraitPdfPath
              : landscapePdfPath;

          // Print statement to indicate which PDF is being displayed
          if (orientation == Orientation.portrait) {
            print('Displaying portrait PDF: $portraitPdfPath');
          } else {
            print('Displaying landscape PDF: $landscapePdfPath');
          }

          return pdfPath != null
              ? PDFView(
                  filePath: pdfPath!,
                  swipeHorizontal: true,
                  //fitPolicy: FitPolicy.BOTH,
                  onError: (error) {
                    print('PDF loading error: $error');
                  },
                  onPageError: (page, error) {
                    print('Error on page $page: $error');
                  },
                  onViewCreated: (PDFViewController controller) {
                    print('PDF loading successful!');
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PDF Viewer Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyPDFViewer(),
//     );
//   }
// }

// class MyPDFViewer extends StatefulWidget {
//   @override
//   _MyPDFViewerState createState() => _MyPDFViewerState();
// }

// class _MyPDFViewerState extends State<MyPDFViewer> {
//   String? pdfPath;

//   @override
//   void initState() {
//     super.initState();
//     loadPDFFromAsset('assets/quran_source_v.pdf');
//   }

//   Future<void> loadPDFFromAsset(String assetPath) async {
//     final ByteData data = await rootBundle.load(assetPath);
//     final Directory tempDir = await getTemporaryDirectory();
//     final File tempFile = File('${tempDir.path}/quran_source_v.pdf');
//     await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
//     setState(() {
//       pdfPath = tempFile.path;
//       if (pdfPath != null) {
//         print('PDF loaded successfully: $pdfPath');
//       } else {
//         print('Error loading PDF');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pdfPath != null
//           ? PDFView(
//               filePath: pdfPath!,
//               swipeHorizontal: true,
//               fitPolicy: FitPolicy.BOTH,
//               onError: (error) {
//                 print('PDF loading error: $error');
//               },
//               onViewCreated: (PDFViewController controller) {
//                 print('PDF loading successful!');
//               },
//             )
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }

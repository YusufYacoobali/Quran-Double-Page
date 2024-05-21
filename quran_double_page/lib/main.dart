import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PDFScreen(),
    );
  }
}

class PDFScreen extends StatefulWidget {
  const PDFScreen({super.key});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  final String assetPDFPath = 'assets/quran_source_v.pdf';
  late PDFViewController pdfViewController;
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran PDF Viewer'),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: assetPDFPath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            onRender: (_pages) {
              setState(() {
                isReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              setState(() {
                pdfViewController = vc;
              });
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
            },
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
          ),
          !isReady
              ? const Center(child: CircularProgressIndicator())
              : Container(),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final zoomLevel = await pdfViewController.getZoom();
      //     pdfViewController.setZoom(zoomLevel + 0.5);
      //   },
      //   child: const Icon(Icons.zoom_in),
      // ),
    );
  }
}

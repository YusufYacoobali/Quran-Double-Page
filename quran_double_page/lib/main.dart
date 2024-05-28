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
  late Future<Map<String, String>> pdfPathsFuture;
  PDFViewController? _pdfViewController;
  int _totalPages = 0;
  int _currentPage = 0;

  final ValueNotifier<bool> _isPortraitNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    pdfPathsFuture = loadPDFFromAssets();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<Map<String, String>> loadPDFFromAssets() async {
    final ByteData dataPortrait =
        await rootBundle.load('assets/quran_source_v.pdf');
    final ByteData dataLandscape =
        await rootBundle.load('assets/quran_source_double_close.pdf');
    final Directory tempDir = await getTemporaryDirectory();

    final File tempFilePortrait = File('${tempDir.path}/quran_source_v.pdf');
    await tempFilePortrait.writeAsBytes(dataPortrait.buffer.asUint8List(),
        flush: true);

    final File tempFileLandscape =
        File('${tempDir.path}/quran_source_double_close.pdf');
    await tempFileLandscape.writeAsBytes(dataLandscape.buffer.asUint8List(),
        flush: true);

    return {
      'portrait': tempFilePortrait.path,
      'landscape': tempFileLandscape.path,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          _isPortraitNotifier.value = orientation == Orientation.portrait;

          return FutureBuilder<Map<String, String>>(
            future: pdfPathsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading PDF: ${snapshot.error}'),
                );
              } else {
                final String pdfPath = _isPortraitNotifier.value
                    ? snapshot.data!['portrait']!
                    : snapshot.data!['landscape']!;
                print('Displaying PDF: $pdfPath');

                return Stack(
                  children: [
                    PDFView(
                      filePath: pdfPath,
                      swipeHorizontal: true,
                      fitPolicy: _isPortraitNotifier.value
                          ? FitPolicy.WIDTH
                          : FitPolicy.HEIGHT,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages!;
                        });
                      },
                      onViewCreated: (PDFViewController controller) {
                        setState(() {
                          _pdfViewController = controller;
                        });
                      },
                      onPageChanged: (page, total) {
                        setState(() {
                          _currentPage = page!;
                        });
                      },
                      onError: (error) {
                        print('PDF loading error: $error');
                      },
                      onPageError: (page, error) {
                        print('Error on page $page: $error');
                      },
                    ),
                    if (_totalPages > 0)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _currentPage.toDouble(),
                                min: 0,
                                max: (_totalPages - 1).toDouble(),
                                onChanged: (value) async {
                                  final int pageNumber = value.toInt();
                                  await _pdfViewController?.setPage(pageNumber);
                                  setState(() {
                                    _currentPage = pageNumber;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${_currentPage + 1}/$_totalPages',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}

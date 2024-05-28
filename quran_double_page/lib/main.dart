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
  bool _isPortrait = true;

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
          bool isPortrait = orientation == Orientation.portrait;
          if (_isPortrait != isPortrait) {
            _isPortrait = isPortrait;
            _pdfViewController = null; // Reset controller to force rebuild
          }

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
                final String pdfPath = isPortrait
                    ? snapshot.data!['portrait']!
                    : snapshot.data!['landscape']!;
                print('Displaying PDF: $pdfPath');

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    PDFView(
                      key: ValueKey(pdfPath), // Force reload by changing key
                      filePath: pdfPath,
                      swipeHorizontal: true,
                      fitPolicy: FitPolicy.BOTH,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages!;
                          // Restore the current page after rendering
                          _pdfViewController?.setPage(_currentPage);
                        });
                      },
                      onViewCreated: (PDFViewController controller) {
                        _pdfViewController = controller;
                        // Restore the current page when view is created
                        _pdfViewController?.setPage(_currentPage);
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
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: [
                            Text(
                              '${MediaQuery.of(context).orientation == Orientation.landscape ? ((_totalPages - _currentPage) * 2 - 1) : (_totalPages - _currentPage)}/${MediaQuery.of(context).orientation == Orientation.landscape ? (_totalPages * 2 - 1) : _totalPages}',
                              style: TextStyle(color: Colors.black),
                            ),
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

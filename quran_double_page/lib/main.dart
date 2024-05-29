import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _orientationChanging = false;
  bool _isScrollbarVisible = true; // Track if scrollbar is visible
  Timer? _scrollbarTimer; // Timer to hide scrollbar

  @override
  void initState() {
    super.initState();
    pdfPathsFuture = loadPDFFromAssets();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start the timer when the widget is initialized
    _startScrollbarTimer();
  }

  @override
  void dispose() {
    _scrollbarTimer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  // Function to start the timer to hide the scrollbar after a few seconds
  void _startScrollbarTimer() {
    setState(() {
      _isScrollbarVisible = true;
    });
    _scrollbarTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _isScrollbarVisible = false; // Hide the scrollbar
      });
    });
  }

  // Function to reset the timer
  void _resetScrollbarTimer() {
    _scrollbarTimer?.cancel(); // Cancel the current timer
    _startScrollbarTimer(); // Start a new timer
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
    return GestureDetector(
      onTap: () {
        print('TAP DETECTED');
        // Reset the scrollbar timer on tap
        //_resetScrollbarTimer();
        setState(() {
          _isScrollbarVisible = true; // Show the scrollbar
        });
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<Map<String, String>>(
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
                  final String pdfPath = _isPortrait
                      ? snapshot.data!['portrait']!
                      : snapshot.data!['landscape']!;
                  print('Displaying PDF: $pdfPath');

                  return PDFView(
                    key: ValueKey(pdfPath), // Force reload by changing key
                    filePath: pdfPath,
                    swipeHorizontal: true,
                    fitPolicy: FitPolicy.BOTH,
                    onRender: (pages) {
                      setState(() {
                        _totalPages = pages!;
                        // Restore the current page after rendering
                        if (_orientationChanging) {
                          _pdfViewController?.setPage(_isPortrait
                              ? (_currentPage * 2).toInt()
                              : (_currentPage / 2).toInt());
                        } else {
                          _pdfViewController
                              ?.setPage((_currentPage / 2).toInt());
                        }
                        _orientationChanging = false; // Reset the flag
                        _resetScrollbarTimer();
                      });
                    },
                    onViewCreated: (PDFViewController controller) {
                      _pdfViewController = controller;
                      // Restore the current page when view is created
                      _pdfViewController?.setPage(_currentPage);
                      _resetScrollbarTimer();
                    },
                    onPageChanged: (page, total) {
                      if (_orientationChanging) {
                        return; // Skip updating if orientation is changing
                      }
                      setState(() {
                        _currentPage = page!;
                        //_resetScrollbarTimer();
                      });
                    },
                    onError: (error) {
                      print('PDF loading error: $error');
                    },
                    onPageError: (page, error) {
                      print('Error on page $page: $error');
                    },
                  );
                }
              },
            ),
            if (_isScrollbarVisible &&
                (_totalPages > 0)) // Show the scrollbar if visible
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
                            _resetScrollbarTimer();
                            print(
                                'Slider onChanged: Orientation: ${_isPortrait ? 'Portrait' : 'Landscape'}, Current Page: $_currentPage');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

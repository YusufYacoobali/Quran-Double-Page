import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
  bool _isScrollbarVisible = true; // State for scrollbar visibility
  Timer? _hideScrollbarTimer; // Timer to hide the scrollbar

  @override
  void initState() {
    super.initState();
    pdfPathsFuture = loadPDFFromAssets();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideScrollbarTimer(); // Start the timer when the widget initializes
  }

  @override
  void dispose() {
    _hideScrollbarTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  void _startHideScrollbarTimer() {
    _hideScrollbarTimer?.cancel(); // Cancel any existing timer
    _hideScrollbarTimer = Timer(Duration(seconds: 4), () {
      setState(() {
        _isScrollbarVisible = false;
      });
    });
  }

  void _onScreenTap() {
    print('screen tapped');
    setState(() {
      _isScrollbarVisible = true;
    });
    _startHideScrollbarTimer(); // Restart the timer when screen is tapped
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
      behavior: HitTestBehavior.translucent, // Ensure gesture detection
      onTap: _onScreenTap,
      child: Scaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            bool isPortrait = orientation == Orientation.portrait;
            if (_isPortrait != isPortrait) {
              _isPortrait = isPortrait;
              _orientationChanging = true;
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
                            if (_orientationChanging) {
                              _pdfViewController?.setPage(_isPortrait
                                  ? (_currentPage * 2).toInt()
                                  : (_currentPage / 2).toInt());
                            } else {
                              _pdfViewController
                                  ?.setPage((_currentPage / 2).toInt());
                            }
                            _orientationChanging = false; // Reset the flag
                          });
                          print(
                              'onRender: Orientation: ${_isPortrait ? 'Portrait' : 'Landscape'}, Current Page: $_currentPage');
                        },
                        onViewCreated: (PDFViewController controller) {
                          _pdfViewController = controller;
                          // Restore the current page when view is created
                          _pdfViewController?.setPage(_currentPage);
                          print(
                              'onViewCreated: Orientation: ${_isPortrait ? 'Portrait' : 'Landscape'}, Current Page: $_currentPage');
                        },
                        onPageChanged: (page, total) {
                          if (_orientationChanging) {
                            return; // Skip updating if orientation is changing
                          }
                          setState(() {
                            print(
                                'onPageChanged: Current page changing from $_currentPage');
                            _currentPage = page!;
                            print(
                                'onPageChanged: Current page changed to $_currentPage');
                          });
                          print(
                              'onPageChanged: Orientation: ${_isPortrait ? 'Portrait' : 'Landscape'}, Current Page: $_currentPage');
                        },
                        onError: (error) {
                          print('PDF loading error: $error');
                        },
                        onPageError: (page, error) {
                          print('Error on page $page: $error');
                        },
                      ),
                      if (_totalPages > 0 && _isScrollbarVisible)
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
                                    await _pdfViewController
                                        ?.setPage(pageNumber);
                                    setState(() {
                                      _currentPage = pageNumber;
                                      print(
                                          'Slider onChanged: Orientation: ${_isPortrait ? 'Portrait' : 'Landscape'}, Current Page: $_currentPage');
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      GestureDetector(
                        behavior: HitTestBehavior
                            .translucent, //to listen for tap events on an empty container

                        onTap: _onScreenTap,

                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                      )
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

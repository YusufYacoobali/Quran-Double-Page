import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_double_page/bookmark.dart';
import 'package:quran_double_page/model/bookmark.dart';
import 'package:quran_double_page/model/storage.dart';
import 'package:quran_double_page/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyPDFViewer(),
    );
  }
}

class MyPDFViewer extends StatefulWidget {
  const MyPDFViewer({super.key});

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
  final List<Bookmark> _bookmarks = [];
  String selectedPortraitPDF = 'quran_source_v_l_s.pdf';

  void _addBookmark() {
    int pageNumber = _isPortrait
        ? (_totalPages - _currentPage)
        : (_totalPages - _currentPage) * 2 - 1;

    // Check if the page number is already bookmarked
    if (_bookmarks.any((bookmark) => bookmark.pageNumber == pageNumber)) {
      // If the page number is already bookmarked, do nothing
      return;
    }

    // If the page number is not bookmarked, add it to the list of bookmarks
    setState(() {
      _bookmarks.add(Bookmark(
        pageNumber: pageNumber,
        // surah: 'Description for page $_pagenum',
      ));
    });
    // Save the updated list of bookmarks to storage
    StorageManager.saveBookmarks(_bookmarks);
  }

  void _handleBookmarkToggled(Bookmark bookmark) {
    setState(() {
      if (_bookmarks.contains(bookmark)) {
        _bookmarks.remove(bookmark);
      }
    });
    StorageManager.saveBookmarks(_bookmarks);
  }

  void _loadCurrentPage() async {
    int savedPage = await StorageManager.getCurrentPage();
    print('loading PAGE WAS $savedPage, cur page was $_currentPage');
    // if (!_isPortrait) {
    //   savedPage = savedPage ~/ 2;
    // }
    setState(() {
      _currentPage = savedPage;
    });
    print('current page is now $_currentPage');
  }

  // Load bookmarks from SharedPreferences
  void _loadBookmarks() async {
    final List<Bookmark> bookmarks = await StorageManager.getBookmarks();
    print(' all bookmarks gotten:  $bookmarks');
    setState(() {
      _bookmarks.addAll(bookmarks);
    });
  }

  @override
  void initState() {
    super.initState();

    pdfPathsFuture = loadPDFFromAssets();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideScrollbarTimer(); // Start the timer when the widget initializes
    _loadBookmarks();
    _loadCurrentPage();
    _loadSelectedPDF();
    print('at the end $selectedPortraitPDF is pdf');
  }

  @override
  void dispose() {
    _hideScrollbarTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  void _startHideScrollbarTimer() {
    _hideScrollbarTimer?.cancel(); // Cancel any existing timer
    _hideScrollbarTimer = Timer(const Duration(seconds: 4), () {
      setState(() {
        _isScrollbarVisible = false;
      });
    });
  }

  void _onScreenTap() {
    setState(() {
      _isScrollbarVisible = true;
    });
    _startHideScrollbarTimer(); // Restart the timer when screen is tapped
  }

  Future<Map<String, String>> loadPDFFromAssets() async {
    print('loading asset $selectedPortraitPDF is pdf');
    final ByteData dataPortrait =
        await rootBundle.load('assets/$selectedPortraitPDF');
    final ByteData dataLandscape =
        await rootBundle.load('assets/quran_source_double_close.pdf');
    final Directory tempDir = await getTemporaryDirectory();

    final File tempFilePortrait = File('${tempDir.path}/$selectedPortraitPDF');
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

  Future<void> _loadSelectedPDF() async {
    bool isOptimizedPortrait = await StorageManager.getOptimizedPortrait();
    setState(() {
      selectedPortraitPDF =
          isOptimizedPortrait ? 'quran_source_v_l_s.pdf' : 'quran_source_v.pdf';
      print('load selected $selectedPortraitPDF is pdf');
      pdfPathsFuture = loadPDFFromAssets(); // Reload PDF paths
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        print('onrender current page is now $_currentPage');
                        setState(() {
                          _totalPages = pages!;
                          // Restore the current page after rendering
                          if (_orientationChanging) {
                            _pdfViewController?.setPage(_isPortrait
                                ? (_currentPage * 2).toInt()
                                : _currentPage ~/ 2);
                          } else {
                            _pdfViewController?.setPage(_currentPage);
                          }
                          _orientationChanging = false; // Reset the flag
                        });
                        print('onrender current page is now $_currentPage');
                      },
                      onViewCreated: (PDFViewController controller) {
                        print('onview current page is now $_currentPage');
                        _pdfViewController = controller;
                        // Restore the current page when view is created
                        _pdfViewController?.setPage(_currentPage);
                        print('onview current page is now $_currentPage');
                      },
                      onPageChanged: (page, total) {
                        print('onpage current page is now $_currentPage');
                        if (_orientationChanging) {
                          return; // Skip updating if orientation is changing
                        }
                        if (page != 0) {
                          setState(() {
                            _currentPage = page!;
                            if (isPortrait) {
                              StorageManager.saveCurrentPage(page);
                            } else {
                              StorageManager.saveCurrentPage(page * 2 + 1);
                            }
                          });
                        }

                        print('onpage current page is now $_currentPage');
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 2, 92, 50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${MediaQuery.of(context).orientation == Orientation.landscape ? ((_totalPages - _currentPage) * 2 - 1) : (_totalPages - _currentPage)}/${MediaQuery.of(context).orientation == Orientation.landscape ? (_totalPages * 2 - 1) : _totalPages}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Slider(
                                  activeColor: const Color(0xFF7EA16B),
                                  thumbColor:
                                      const Color.fromARGB(255, 175, 132, 4),
                                  inactiveColor:
                                      const Color.fromARGB(255, 175, 132, 4),
                                  value: _currentPage.toDouble(),
                                  min: 0,
                                  max: (_totalPages - 1).toDouble(),
                                  onChanged: (value) async {
                                    final int pageNumber = value.toInt();
                                    await _pdfViewController
                                        ?.setPage(pageNumber);

                                    setState(() {
                                      _currentPage = pageNumber;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.bookmarks_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    backgroundColor:
                                        Color.fromARGB(255, 235, 243, 236),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setModalState) {
                                          return Container(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.all(
                                                      16.0),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _addBookmark();
                                                      setModalState(
                                                          () {}); // Update modal state
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: const Color(
                                                          0xFFFBFBFB), // Background color
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Bookmark This Page',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            Color(0xFF2A6767),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount:
                                                        _bookmarks.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return BookmarkWidget(
                                                        bookmark:
                                                            _bookmarks[index],
                                                        onBookmarkToggled:
                                                            (bookmark) {
                                                          _handleBookmarkToggled(
                                                              bookmark);
                                                          setModalState(
                                                              () {}); // Update modal state
                                                        },
                                                        onPagePressed:
                                                            (bookmark) async {
                                                          int pageNumber = _isPortrait
                                                              ? (_totalPages -
                                                                  bookmark
                                                                      .pageNumber)
                                                              : (851 -
                                                                      bookmark
                                                                          .pageNumber) ~/
                                                                  2;

                                                          await _pdfViewController
                                                              ?.setPage(
                                                                  pageNumber);

                                                          setState(() {
                                                            _currentPage =
                                                                pageNumber;
                                                          });
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // Navigate to the SettingsScreen when the settings icon is pressed
                                  print('Settings tapped');
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => const Settings()),
                                  // );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Settings(
                                        onPDFSelectionChanged:
                                            (isPortraitOptimized) {
                                          // Reload the PDF viewer with the updated PDF selection
                                          _loadSelectedPDF();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35),
                      child: GestureDetector(
                        behavior: HitTestBehavior
                            .translucent, // to listen for tap events on an empty container
                        onTap: _onScreenTap,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                        ),
                      ),
                    )
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

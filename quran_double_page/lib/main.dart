import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_double_page/bookmark.dart';
import 'package:quran_double_page/model/bookmark.dart';
import 'package:quran_double_page/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final List<Bookmark> _bookmarks = [];

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
    BookmarkManager.saveBookmarks(_bookmarks);
  }

  void _handleBookmarkToggled(Bookmark bookmark) {
    setState(() {
      if (_bookmarks.contains(bookmark)) {
        _bookmarks.remove(bookmark);
      }
    });
    BookmarkManager.saveBookmarks(_bookmarks);
  }

  // Load bookmarks from SharedPreferences
  void _loadBookmarks() async {
    final List<Bookmark> bookmarks = await BookmarkManager.getBookmarks();
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
                      },
                      onViewCreated: (PDFViewController controller) {
                        _pdfViewController = controller;
                        // Restore the current page when view is created
                        _pdfViewController?.setPage(_currentPage);
                      },
                      onPageChanged: (page, total) {
                        if (_orientationChanging) {
                          return; // Skip updating if orientation is changing
                        }
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
                                  await _pdfViewController?.setPage(pageNumber);

                                  setState(() {
                                    _currentPage = pageNumber;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmarks_outlined),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setModalState) {
                                        return Container(
                                          //width: double.infinity,
                                          width: double.infinity,

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _addBookmark();
                                                    setModalState(
                                                        () {}); // Update modal state
                                                  },
                                                  child: const Text(
                                                      'Bookmark This Page'),
                                                ),
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: _bookmarks.length,
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
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () {
                                // Navigate to the SettingsScreen when the settings icon is pressed
                                print('Settings tapped');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Settings()),
                                );
                              },
                            ),
                          ],
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

class BookmarkManager {
  static const _kBookmarkKey = 'bookmarks1';

  // Save bookmarks to SharedPreferences
  static Future<void> saveBookmarks(List<Bookmark> bookmarks) async {
    print('trying to save bookmark 2');
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarkPageNumbers =
        bookmarks.map((bookmark) => bookmark.pageNumber.toString()).toList();
    print('SAVING BOOKMARKS: $bookmarkPageNumbers');
    await prefs.setStringList(_kBookmarkKey, bookmarkPageNumbers);
  }

// Retrieve bookmarks from SharedPreferences
  static Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? bookmarkPageNumbers =
        prefs.getStringList(_kBookmarkKey);
    if (bookmarkPageNumbers == null) {
      return [];
    }
    print('RETRIEVING BOOKMARKS: $bookmarkPageNumbers');
    return bookmarkPageNumbers
        .map((pageNumber) => Bookmark(pageNumber: int.parse(pageNumber)))
        .toList();
  }
}

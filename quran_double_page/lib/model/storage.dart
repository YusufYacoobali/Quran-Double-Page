import 'package:quran_double_page/model/bookmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static const _kCurrentPageKey = 'CurrentPage1';
  static const _kBookmarkKey = 'bookmarks1';
  static const _kOptimizedPortraitKey = 'optimizedPortrait';
  static const _kOptimizedLandscapeKey = 'optimizedLandscape';

  // Save current page to SharedPreferences
  static Future<void> saveCurrentPage(int page) async {
    if (page != 0 && page != 851) {
      final prefs = await SharedPreferences.getInstance();
      print('saving current page $page');
      await prefs.setInt(_kCurrentPageKey, page);
    }
  }

  // Retrieve current page from SharedPreferences
  static Future<int> getCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCurrentPageKey) ?? 0;
  }

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

  // Save optimized portrait state to SharedPreferences
  static Future<void> saveOptimizedPortrait(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOptimizedPortraitKey, value);
  }

  // Retrieve optimized portrait state from SharedPreferences
  static Future<bool> getOptimizedPortrait() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOptimizedPortraitKey) ?? false;
  }

  // Save optimized landscape state to SharedPreferences
  static Future<void> saveOptimizedLandscape(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOptimizedLandscapeKey, value);
  }

  // Retrieve optimized landscape state from SharedPreferences
  static Future<bool> getOptimizedLandscape() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOptimizedLandscapeKey) ?? false;
  }
}

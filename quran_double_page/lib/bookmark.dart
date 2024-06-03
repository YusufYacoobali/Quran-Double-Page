import 'package:flutter/material.dart';
import 'package:quran_double_page/model/bookmark.dart';

class BookmarkWidget extends StatefulWidget {
  final Bookmark bookmark;
  final Function(Bookmark)
      onBookmarkToggled; // Callback function to handle bookmark toggle

  BookmarkWidget({required this.bookmark, required this.onBookmarkToggled});

  @override
  _BookmarkWidgetState createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget> {
  bool isBookmarked = true; // Initially, the bookmark is assumed to be present

  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    widget.onBookmarkToggled(widget.bookmark);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.bookmark.surah),
      subtitle: Text('Page ${widget.bookmark.pageNumber}'),
      trailing: IconButton(
        icon: const Icon(Icons.bookmark),
        onPressed: _toggleBookmark,
      ),
    );
  }
}

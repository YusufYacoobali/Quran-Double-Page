import 'package:flutter/material.dart';
import 'package:quran_double_page/model/bookmark.dart';

class BookmarkWidget extends StatefulWidget {
  final Bookmark bookmark;
  final Function(Bookmark) onBookmarkToggled;
  final Function(Bookmark) onPagePressed; // Callback function for page press

  BookmarkWidget({
    required this.bookmark,
    required this.onBookmarkToggled,
    required this.onPagePressed,
  });

  @override
  _BookmarkWidgetState createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget> {
  bool isBookmarked = true;

  void _toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    widget.onBookmarkToggled(widget.bookmark);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget
            .onPagePressed(widget.bookmark); // Call the callback for page press
      },
      child: ListTile(
        title: Text(widget.bookmark.surah),
        subtitle: Text('Page ${widget.bookmark.pageNumber}'),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: _toggleBookmark,
        ),
      ),
    );
  }
}

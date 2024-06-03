import 'package:flutter/material.dart';
import 'package:quran_double_page/model/bookmark.dart';

class BookmarkWidget extends StatelessWidget {
  final Bookmark bookmark;

  BookmarkWidget({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(bookmark.surah),
      subtitle: Text('Page ${bookmark.pageNumber}'),
      trailing: Icon(Icons.bookmark),
    );
  }
}

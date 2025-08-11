import 'package:flutter/material.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/components/HtmlWidgtet.dart';

class PageDetailScreen extends StatefulWidget {
  final String title;
  final String description;

  PageDetailScreen({required this.title, required this.description});

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: widget.title,
      body: ListView(
        children: [
          HtmlWidget(
            postContent: widget.description,
          ),
        ],
      ),
    );
  }
}

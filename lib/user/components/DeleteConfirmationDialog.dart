import 'package:flutter/material.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Function()? onDelete;

  const DeleteConfirmationDialog({this.title, this.subtitle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
            padding: EdgeInsets.all(16),
            child: Icon(Icons.delete, color: Colors.red),
          ),
          SizedBox(height: 30),
          Text(title.validate(), style: primaryTextStyle(size: 24), textAlign: TextAlign.center),
          SizedBox(height: 16),
          Text(subtitle.validate(), style: secondaryTextStyle(), textAlign: TextAlign.center),
        ],
      ),
      actions: <Widget>[
        Row(
          children: [
            outlineButton(language.cancel, () {
              Navigator.pop(context);
            }).expand(),
            16.width,
            commonButton(language.delete, () {
              finish(context);
              onDelete?.call();
            }, color: Colors.red)
                .expand(),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../extensions/extension_util/bool_extensions.dart';
import '../../main/utils/dynamic_theme.dart';

import '../../main.dart';
import '../utils/Widgets.dart';

class CommonScaffoldComponent extends StatelessWidget {
  final String? appBarTitle;
  final Widget? body;
  final bool? showBack;
  final PreferredSizeWidget? appBar;
  final List<Widget>? action;
  final bool? extendedBody;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? bottom;

  const CommonScaffoldComponent(
      {this.appBarTitle,
      this.body,
      this.action,
      this.appBar,
      this.showBack = true,
      this.extendedBody = false,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.bottomNavigationBar,
      this.bottom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendedBody.validate(),
      backgroundColor: appStore.isDarkMode ? ColorUtils.scaffoldSecondaryDark : ColorUtils.colorPrimaryLight,
      appBar: appBar ?? commonAppBarWidget(appBarTitle ?? '', actions: action, showBack: showBack!, bottom: bottom),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

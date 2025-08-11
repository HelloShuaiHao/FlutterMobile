import 'package:flutter/material.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class ThemeSelectionDialog extends StatefulWidget {
  static String tag = '/ThemeSelectionDialog';

  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
    print(currentIndex.toString());
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    List<String?> themeModeList = [language.light, language.dark, language.systemDefault];
    return Container(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            decoration: boxDecorationWithShadow(
                backgroundColor: ColorUtils.colorPrimary,
                borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.theme, style: boldTextStyle(size: 20, color: Colors.white)).paddingLeft(12),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            children: List.generate(
              themeModeList.length,
              (index) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    listTileTheme: ListTileThemeData(
                      horizontalTitleGap: 2, //here adjust based on your need
                    ),
                  ),
                  child: RadioListTile(
                    value: index,
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    groupValue: currentIndex,
                    activeColor: ColorUtils.colorPrimary,
                    title: Text(themeModeList[index]!, style: primaryTextStyle()),
                    onChanged: (dynamic val) {
                      currentIndex = index;
                      if (index == appThemeMode.themeModeSystem) {
                        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                      } else if (index == appThemeMode.themeModeLight) {
                        appStore.setDarkMode(false);
                      } else if (index == appThemeMode.themeModeDark) {
                        appStore.setDarkMode(true);
                      }
                      setValue(THEME_MODE_INDEX, index);
                      setState(() {});
                      LiveStream().emit('UpdateTheme');
                      finish(context);
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

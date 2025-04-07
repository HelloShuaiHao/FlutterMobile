import 'package:flutter/material.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Widgets.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    print("当前进入 theme_screen.dart 页面");
    init();
  }

  void init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    List<String?> themeModeList = [language.light, language.dark, language.systemDefault];
    List<Icon> icons = [
      Icon(Icons.light_mode_outlined, color: context.iconColor),
      Icon(Icons.dark_mode_outlined, color: context.iconColor),
      Icon(Icons.light_mode_outlined, color: context.iconColor)
    ];
    return Scaffold(
      appBar: commonAppBarWidget(language.theme),
      body: ListView(
        children: List.generate(
          themeModeList.length,
          (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  icons[index],
                  16.width,
                  Text(themeModeList[index]!, style: boldTextStyle()).expand(),
                  if (index == currentIndex) Icon(Icons.check_circle, color: ColorUtils.colorPrimary),
                ],
              ),
            ).onTap(() async {
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
            });
          },
        ),
      ),
    );
  }
}

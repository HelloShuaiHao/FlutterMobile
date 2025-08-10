import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mighty_delivery/languageConfiguration/LanguageDefaultJson.dart';
import 'package:mighty_delivery/main/utils/dynamic_theme.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Common.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/animatedList/animated_scroll_view.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../languageConfiguration/LanguageDataConstant.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';

class LanguageScreen extends StatefulWidget {
  static String tag = '/LanguageScreen';

  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  final List<Map<String, String>> languages = [
    {"languageCode": "en", "languageName": "English"},
    {"languageCode": "zh", "languageName": "中文"},
  ];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    print("当前进入 language_screen.dart 页面");
    print(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode));
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: "Select Language",
      body: AnimatedScrollView(
        padding: EdgeInsets.all(8),
        children: List.generate(languages.length, (index) {
          Map<String, String> data = languages[index];
          String languageCode = data["languageCode"]!;
          String languageName = data["languageName"]!;

          return Container(
            margin: EdgeInsets.all(8),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: Colors.transparent,
              border: Border.all(
                color: getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode) == languageCode
                    ? ColorUtils.colorPrimary
                    : ColorUtils.dividerColor,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(languageName, style: primaryTextStyle()).expand(),
                getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode) == languageCode
                    ? Icon(Ionicons.radio_button_on, size: 20, color: ColorUtils.colorPrimary)
                    : Icon(Ionicons.radio_button_off_sharp, size: 20, color: ColorUtils.dividerColor),
              ],
            ),
          ).onTap(() async {
            await setValue(SELECTED_LANGUAGE_CODE, languageCode);
            selectedServerLanguageData = null; // 如果需要，可以清空其他语言数据
            appStore.setLanguage(languageCode, context: context);
            setState(() {});
            LiveStream().emit('UpdateLanguage'); // 通知其他页面更新语言
            finish(context);
          }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
        }),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
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
import '../../languageConfiguration/LanguageDefaultJson.dart';
import '../../languageConfiguration/ServerLanguageResponse.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';
import '../utils/dynamic_theme.dart';

class LanguageScreen extends StatefulWidget {
  static String tag = '/LanguageScreen';

  @override
  LanguageScreenState createState() => LanguageScreenState();
}

class LanguageScreenState extends State<LanguageScreen> {
  // int? currentIndex = 0;

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
      appBarTitle: language.language,
      body: AnimatedScrollView(
        padding: EdgeInsets.all(8),
        children: List.generate(defaultServerLanguageData!.length, (index) {
          LanguageJsonData data = defaultServerLanguageData![index];
          return Container(
            margin: EdgeInsets.all(8),
            decoration: boxDecorationWithRoundedCorners(
                backgroundColor: Colors.transparent,
                border: Border.all(
                    color: getStringAsync(SELECTED_LANGUAGE_COUNTRY_CODE, defaultValue: defaultCountryCode) ==
                            data.countryCode
                        ? ColorUtils.colorPrimary
                        : ColorUtils.dividerColor)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                commonCachedNetworkImage(data.languageImage.validate(), width: 34, height: 34)
                    .cornerRadiusWithClipRRect(4),
                //Image.asset(data.languageName.validate(), width: 34, height: 34).cornerRadiusWithClipRRect(4),
                8.width,
                Text('${data.languageName.validate()}', style: primaryTextStyle()).expand(),
                getStringAsync(SELECTED_LANGUAGE_COUNTRY_CODE, defaultValue: defaultCountryCode) == data.countryCode
                    ? Icon(Ionicons.radio_button_on, size: 20, color: ColorUtils.colorPrimary)
                    : Icon(Ionicons.radio_button_off_sharp, size: 20, color: ColorUtils.dividerColor),
              ],
            ),
          ).onTap(() async {
            await setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
            setValue(SELECTED_LANGUAGE_COUNTRY_CODE, data.countryCode);
            selectedServerLanguageData = data;
            setValue(IS_SELECTED_LANGUAGE_CHANGE, true);
            appStore.setLanguage(data.languageCode!, context: context);
            setState(() {});
            LiveStream().emit('UpdateLanguage');
            finish(context);
          }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
        }),
      ),
    );
  }
}

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Images.dart';

import '../../extensions/app_button.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import 'package:share_plus/share_plus.dart';

import '../../main/utils/dynamic_theme.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.referAndEarn,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(ic_refer_earn, width: 200),
              10.height,
              Text(
                  "${language.referDes1}\n ${appStore.currencySymbol}${appStore.maxAmountEarning} ${language.referDes2}",
                  style: boldTextStyle(),
                  textAlign: TextAlign.center),
              10.height,
              Text("${language.referShareTitle} ${appStore.currencySymbol} ${appStore.maxAmountEarning}",
                      style: secondaryTextStyle(), textAlign: TextAlign.center)
                  .center(),
              30.height,
              DottedBorder(
                  dashPattern: [6, 3, 2, 3],
                  color: ColorUtils.dividerColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appStore.referralCode.validate(), style: boldTextStyle(size: 20)).paddingAll(8),
                      Icon(Icons.copy, size: 18).paddingAll(8)
                    ],
                  )).onTap(() {
                Clipboard.setData(ClipboardData(text: appStore.referralCode)).then((_) {
                  snackBar(context, content: Text("${appStore.referralCode.validate()} ${language.copiedToClipBoard}"));
                });
              }).visible(!appStore.referralCode.isEmptyOrNull),
              30.height,
              Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),
            ],
          ).paddingAll(20),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: AppButton(
              width: context.width(),
              color: ColorUtils.colorPrimary,
              text: language.referAndEarn,
              textStyle: primaryTextStyle(color: white),
              onTap: () {
                Share.share('${language.shareDes1} ${language.appName}, ${language.shareDes2} '
                    '${appStore.referralCode} ${language.shareDes3} 🚀');
              },
            ),
          ),
        ],
      ),
    );
  }
}

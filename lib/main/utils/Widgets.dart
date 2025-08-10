import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../main/utils/dynamic_theme.dart';

import '../../extensions/app_button.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import 'Constants.dart';

Widget commonButton(String title, Function() onTap,
    {double? width, Color? color, Color? textColor, int? size}) {
  return SizedBox(
    width: width,
    child: AppButton(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius)),
      elevation: 0,
      child: Text(
        title,
        style: boldTextStyle(
            color: textColor ?? white,
            size: size ?? textBoldSizeGlobal.toInt()),
      ),
      color: color ?? ColorUtils.colorPrimary,
      onTap: onTap,
    ),
  );
}

Widget outlineButton(String title, Function() onTap,
    {double? width, Color? color}) {
  return SizedBox(
    width: width,
    child: TextButton(
      child: Text(
        title,
        style: boldTextStyle(color: color ?? textPrimaryColorGlobal),
      ),
      onPressed: onTap,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
            side: BorderSide(color: color ?? ColorUtils.borderColor)),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        backgroundColor: Colors.transparent,
      ),
    ),
  );
}

Widget scheduleOptionWidget(
    BuildContext context, bool isSelected, String imagePath, String title) {
  return Container(
    padding: EdgeInsets.all(16),
    alignment: Alignment.center,
    decoration: boxDecorationWithRoundedCorners(
        border: Border.all(
            color: isSelected
                ? ColorUtils.colorPrimary
                : appStore.isDarkMode
                    ? Colors.transparent
                    : ColorUtils.borderColor),
        backgroundColor:
            isSelected ? ColorUtils.colorPrimary : context.cardColor),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(title == language.schedule ? Feather.calendar : Feather.clock,
            size: 18, color: isSelected ? Colors.white : context.iconColor),
        // ImageIcon(AssetImage(imagePath), size: 20, color: isSelected ? colorPrimary : Colors.grey),
        8.width,
        Text(title,
            style: boldTextStyle(
                color: isSelected ? Colors.white : textPrimaryColorGlobal)),
      ],
    ),
  );
}

Widget enableBidOptionWidget(
    BuildContext context, bool isSelected, IconData icon, String title) {
  return Container(
    padding: EdgeInsets.all(16),
    alignment: Alignment.center,
    decoration: boxDecorationWithRoundedCorners(
        border: Border.all(
            color: isSelected
                ? ColorUtils.colorPrimary
                : appStore.isDarkMode
                    ? Colors.transparent
                    : ColorUtils.borderColor),
        backgroundColor:
            isSelected ? ColorUtils.colorPrimary : context.cardColor),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.white : context.iconColor,
        ),
        8.width,
        Text(title,
            style: boldTextStyle(
                color: isSelected ? Colors.white : textPrimaryColorGlobal)),
      ],
    ),
  );
}

/// Default AppBar
AppBar commonAppBarWidget(
  String title, {
  @Deprecated('Use titleWidget instead') Widget? child,
  Widget? titleWidget,
  List<Widget>? actions,
  Color? color,
  bool center = false,
  Color? textColor,
  int textSize = 18,
  double titleSpacing = 2,
  bool showBack = true,
  bool isBottom = true,
  Color? shadowColor,
  double? elevation,
  Widget? backWidget,
  @Deprecated('Use systemOverlayStyle instead') Brightness? brightness,
  SystemUiOverlayStyle? systemUiOverlayStyle,
  TextStyle? titleTextStyle,
  PreferredSizeWidget? bottom,
  Widget? flexibleSpace,
}) {
  return AppBar(
    centerTitle: center,
    title: titleWidget ??
        Text(title,
            style: titleTextStyle ??
                (boldTextStyle(
                    color: textColor ?? Colors.white, size: textSize))),
    actions: actions ?? [],
    automaticallyImplyLeading: showBack,
    backgroundColor: color ?? ColorUtils.colorPrimary,
    leading: showBack
        ? (backWidget ?? BackButton(color: textColor ?? Colors.white))
        : null,
    shadowColor: shadowColor,
    shape: isBottom
        ? RoundedRectangleBorder(
            borderRadius: radiusOnly(bottomRight: 20, bottomLeft: 20))
        : null,
    elevation: elevation ?? defaultAppBarElevation,
    systemOverlayStyle: systemUiOverlayStyle,
    bottom: bottom,
    titleSpacing: showBack ? titleSpacing : 20,
    flexibleSpace: flexibleSpace,
  );
}

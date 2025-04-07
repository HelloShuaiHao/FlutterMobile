import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main.dart';

import '../../../extensions/decorations.dart';
import '../../../extensions/text_styles.dart';
import '../../../main/models/OrderListModel.dart';
import '../../../main/utils/Constants.dart';
import '../../../main/utils/dynamic_theme.dart';

class TopBarAddressComponent extends StatelessWidget {
  final OrderData? orderData;
  final VoidCallback? onTap;
  const TopBarAddressComponent({super.key, this.orderData, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      margin: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: Colors.transparent), backgroundColor: ColorUtils.colorPrimary.withOpacity(0.1)),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.near_me_outlined, color: ColorUtils.colorPrimary).paddingAll(0),
              Text("...", style: boldTextStyle(color: Colors.grey)).paddingRight(2),
              Text(orderData!.pickupPoint?.address ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 16)).expand(),
            ],
          ).animate().fade().scale(),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("...", style: boldTextStyle(size: 16, color: Colors.grey)).paddingRight(0),
              Icon(Icons.location_on_outlined, color: ColorUtils.colorPrimary).paddingAll(0),
              Text(orderData!.deliveryPoint?.address ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 16)).expand().animate().fade().scale(),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // RichText
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: language.distance + ": ",
                      style: boldTextStyle(size: 16, color: ColorUtils.colorPrimary),
                    ),
                    TextSpan(
                      text: "${orderData!.totalDistance} km",
                      style: boldTextStyle(),
                    ),
                  ],
                ),
              ).paddingRight(8).animate().fade().scale(),
              // ElevatedButton
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtils.colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                ),
                child: Text(language.viewMore, style: boldTextStyle(size: 16, color: Colors.white)).paddingAll(0),
              ).animate().fade().scale(),
            ],
          ),
        ],
      ),
    );
  }
}

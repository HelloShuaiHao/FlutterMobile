import 'package:flutter/material.dart';
import 'package:mighty_delivery/bidding/delivery/screens/OrderDetailsWithBidScreen.dart';
import 'package:mighty_delivery/extensions/animatedList/animated_list_view.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
import 'package:mighty_delivery/main/utils/Common.dart';

import '../../../extensions/animatedList/animated_configurations.dart';
import '../../../extensions/common.dart';
import '../../../extensions/decorations.dart';
import '../../../extensions/text_styles.dart';
import '../../../main.dart';
import '../../../main/utils/Constants.dart';
import '../../../main/utils/dynamic_theme.dart';
import '../models/BidListResponseModel.dart';
import '../network/RestApis.dart';

class DeliveryBidListScreen extends StatefulWidget {
  const DeliveryBidListScreen({super.key});

  @override
  State<DeliveryBidListScreen> createState() => _DeliveryBidListScreenState();
}

class _DeliveryBidListScreenState extends State<DeliveryBidListScreen> {
  List<BidListData>? bidListData = [];

  getBidListApiCall() async {
    appStore.setLoading(true);
    try {
      final res = await getBidList();
      appStore.setLoading(false);
      List<BidListData> newBidListData = res.data ?? [];
      newBidListData.retainWhere(
          (element) => element.isBidAccept == null || element.isBidAccept == 0);
      bidListData!.addAll(newBidListData);
      setState(() {});
    } catch (e) {
      appStore.setLoading(false);
      setState(() {});
      toast(e.toString());
    }
  }

  Future<void> callBidListApi() async {
    await getBidListApiCall();
  }

  @override
  void initState() {
    super.initState();
    callBidListApi();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.deliveryBid,
      body: AnimatedListView(
        itemCount: bidListData?.length ?? 0,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        listAnimationType: ListAnimationType.Slide,
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
        flipConfiguration: FlipConfiguration(
            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
        fadeInConfiguration: FadeInConfiguration(
            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
        onNextPage: () {},
        onSwipeRefresh: () async {
          callBidListApi();
          return Future.value(true);
        },
        itemBuilder: (context, index) {
          final bid = bidListData![index];
          String statusText;
          Color statusColor;

          switch (bid.isBidAccept) {
            case 1:
              statusText = "${language.bidAccepted}";
              statusColor = Colors.green;
              break;
            case 0:
              statusText = "${language.bidPlaced}";
              statusColor = Colors.orange;
              break;
            case null:
              statusText = "${language.newOrder}";
              statusColor = Colors.purple;
              break;
            default:
              statusText = "${language.bidRejected}";
              statusColor = Colors.red;
              break;
          }

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border:
                  Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
              backgroundColor: Colors.transparent,
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${language.orderId}: ${bid.orderId}',
                        style: boldTextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.width,
                    Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: statusColor.withOpacity(0.1),
                      ),
                      child: Text(
                        statusText,
                        style: boldTextStyle(color: statusColor),
                      ),
                    ),
                  ],
                ),
                8.width,
                Row(
                  children: [
                    Text(
                      '${language.totalAmount}: ${appStore.currencySymbol} ${bid.totalAmount!}',
                      style: boldTextStyle(size: 14),
                    ).expand(),
                    8.width,
                    Text(
                      '${language.bidAmount}: ${appStore.currencySymbol} ${bid.bidAmount!}',
                      style: boldTextStyle(size: 14),
                    ),
                  ],
                )
              ],
            ),
          ).onTap(() {
            OrderDetailWithBidScreen(
              bidData: bid,
              orderId: bid.orderId!,
            ).launch(context);
          });
        },
        emptyWidget: Stack(
          children: [
            loaderWidget().visible(appStore.isLoading),
            emptyWidget().visible(!appStore.isLoading),
          ],
        ),
      ),
    );
  }
}

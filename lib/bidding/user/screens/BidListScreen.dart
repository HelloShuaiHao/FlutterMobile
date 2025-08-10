import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/extensions/common.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'package:mighty_delivery/main/utils/Common.dart';

import '../../../extensions/animatedList/animated_configurations.dart';
import '../../../extensions/animatedList/animated_list_view.dart';
import '../../../extensions/confirmation_dialog.dart';
import '../../../extensions/decorations.dart';
import '../../../extensions/text_styles.dart';
import '../../../main/utils/Constants.dart';
import '../../../main/utils/dynamic_theme.dart';
import '../../../user/screens/DashboardScreen.dart';
import '../../../user/screens/OrderDetailScreen.dart';
import '../../delivery/models/BidResponseModel.dart';
import '../../delivery/network/RestApis.dart';
import '../../main/components/DashedLineComponent.dart';
import '../../main/components/TopBarAddressComponent.dart';
import '../../utils/Constants.dart';

class Bidlistscreen extends StatefulWidget {
  final OrderData? orderData;

  const Bidlistscreen({super.key, required this.orderData});

  @override
  State<Bidlistscreen> createState() => _BidlistscreenState();
}

class _BidlistscreenState extends State<Bidlistscreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late StreamSubscription _streamSubscription;

  List<Data> OrderBidData = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    startShake();
    // getOrderBidListApiCall(widget.orderData!.id!);
    _listenToStream();
  }

  void startShake() {
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    log("DISPOSE_CALLED::::");
    _animationController.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  getOrderBidListApiCall(int orderId) async {
    appStore.setLoading(true);
    await getBiddingDetails(orderId).then((value) {
      OrderBidData = value.data ?? [];
      setState(() {});
    }).catchError((e, s) {
      appStore.setLoading(false);
      toast(language.bidFetchFailedMsg);
    }).whenComplete(() => appStore.setLoading(false));
  }

  Future<void> declineOrAcceptBid({
    required String deliveryManId,
    required bool isAccept,
  }) async {
    appStore.setLoading(true);

    Map<String, String> req = {"id": widget.orderData!.id.toString(), "delivery_man_id": deliveryManId, "is_bid_accept": isAccept ? "1" : "2"};

    try {
      final response = await acceptOrRejectBid(req);

      appStore.setLoading(false);

      toast(response.message);

      if (isAccept) {
        _streamSubscription.cancel();
        DashboardScreen().launch(context, isNewTask: true);
      } else {
        await getOrderBidListApiCall(widget.orderData!.id!.toInt());
      }
    } catch (e, s) {
      log("Error123: $e Stack123: $s");
      appStore.setLoading(false);
      toast(language.errorSomethingWentWrong);
    }
  }

  _listenToStream() {
    log("Listening to stream");
    // _streamSubscription = FirebaseFirestore.instance.collection(ORDERS_BID_COLLECTION).doc(ORDERS_BID_COLLECTION_DOC_PREFIX + widget.orderData!.id!.toString()).snapshots().listen((snapshot) {
    //   if (snapshot.exists) {
    //     getOrderBidListApiCall(widget.orderData!.id!);
    //   }
    // }, onError: (error) {
    //   return null;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.bids,
      action: [
        Text("${language.orderId}: #${widget.orderData!.id}", style: boldTextStyle(size: 16, color: Colors.white)).withWidth(120),
      ],
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // ------这里还需要修改，因为把id的int改成了string------
                // TopBarAddressComponent(
                //     orderData: widget.orderData,
                //     onTap: () {
                //       OrderDetailScreen(
                //         orderId: widget.orderData!.id!,
                //       ).launch(context);
                //     }),
                // buildContent(),
              ],
            ),
          ),
          Observer(builder: (context) {
            return appStore.isLoading ? loaderWidget() : SizedBox();
          })
        ],
      ),
    );
  }

  Widget buildContent() {
    if (appStore.isLoading) {
      return SizedBox.shrink();
    } else if (OrderBidData.isEmpty) {
      log("No bids found");
      return Center(child: Text(language.noBidsFound, style: boldTextStyle()));
    } else {
      log("Bids found");
      return buildBidListView();
    }
  }

  Widget buildBidListView() {
    return Container(
      width: context.width(),
      margin: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: Colors.transparent), backgroundColor: ColorUtils.colorPrimary.withOpacity(0.1)),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.bidRequest, style: boldTextStyle(size: 16)),
          16.height,
          SizedBox(
            width: context.width(),
            height: 1,
            child: DashedLineComponent(
              axis: Axis.horizontal,
              dashWidth: 8.0,
              dashHeight: 1.5,
              color: Colors.grey,
            ),
          ),
          16.height,
          AnimatedListView(
            itemCount: OrderBidData.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            listAnimationType: ListAnimationType.Slide,
            padding: const EdgeInsets.all(0),
            itemBuilder: (context, index) {
              var orderDetail = OrderBidData[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(4),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    commonCachedNetworkImage(
                      orderDetail.deliveryManImage,
                      height: 50,
                      width: 50,
                    )
                  ],
                ),
                title: Text(
                  "${printAmount(orderDetail.bidAmount!)}",
                  style: boldTextStyle(size: 24),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderDetail.deliveryManName!.validate().capitalizeFirstLetter(),
                      style: boldTextStyle(size: 14, color: Colors.grey),
                    ),
                    Text(
                      orderDetail.notes ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: secondaryTextStyle(size: 14),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await showConfirmDialogCustom(
                          context,
                          primaryColor: ColorUtils.colorPrimary,
                          title: "${language.acceptBidConfirm}?",
                          positiveText: language.yes,
                          negativeText: language.no,
                          onAccept: (c) {
                            declineOrAcceptBid(deliveryManId: orderDetail.deliveryManId.toString(), isAccept: true);
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    8.width,
                    GestureDetector(
                      onTap: () async {
                        await showConfirmDialogCustom(
                          context,
                          primaryColor: ColorUtils.colorPrimary,
                          title: "${language.declineBidConfirm}?",
                          positiveText: language.yes,
                          negativeText: language.no,
                          onAccept: (c) {
                            declineOrAcceptBid(deliveryManId: orderDetail.deliveryManId.toString(), isAccept: false);
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if (orderDetail.notes != null || orderDetail.notes == "") showMoreInfoDialog(context: context, imageUrl: orderDetail.deliveryManImage.validate(), notes: orderDetail.notes!, name: orderDetail.deliveryManName!);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void showMoreInfoDialog({
    required BuildContext context,
    required String name,
    required String notes,
    required String imageUrl,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              commonCachedNetworkImage(imageUrl, radius: 80, width: 80, height: 80),
              16.height,
              Text(
                name.capitalizeFirstLetter(),
                style: boldTextStyle(),
                textAlign: TextAlign.center,
              ),
              8.height,
              Text(
                notes,
                style: secondaryTextStyle(),
                textAlign: TextAlign.left,
              ).paddingSymmetric(horizontal: 8.0),
              16.height,
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(language.close),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ).paddingAll(16.0),
        );
      },
    );
  }
}

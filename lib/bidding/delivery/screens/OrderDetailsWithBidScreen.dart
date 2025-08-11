import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';

import '../../../delivery/fragment/DHomeFragment.dart';
import '../../../extensions/animatedList/animated_scroll_view.dart';
import '../../../extensions/app_button.dart';
import '../../../extensions/app_text_field.dart';
import '../../../extensions/colors.dart';
import '../../../extensions/common.dart';
import '../../../extensions/confirmation_dialog.dart';
import '../../../extensions/decorations.dart';
import '../../../extensions/shared_pref.dart';
import '../../../extensions/text_styles.dart';
import '../../../main.dart';
import '../../../main/components/CommonScaffoldComponent.dart';
import '../../../main/components/OrderSummeryWidget.dart';
import '../../../main/models/CountryListModel.dart';
import '../../../main/models/ExtraChargeRequestModel.dart';
import '../../../main/models/LoginResponse.dart';
import '../../../main/models/OrderDetailModel.dart';
import '../../../main/models/OrderListModel.dart';
import '../../../main/network/RestApis.dart';
import '../../../main/utils/Common.dart';
import '../../../main/utils/Constants.dart';
import '../../../main/utils/DataProviders.dart';
import '../../../main/utils/Images.dart';
import '../../../main/utils/dynamic_theme.dart';
import '../../../user/screens/packaging_symbols_info.dart';
import '../../../extensions/extension_util/num_extensions.dart';
import '../../utils/Constants.dart';
import '../models/BidListResponseModel.dart';
import '../models/BidOrderModel.dart';
import '../network/RestApis.dart';

class OrderDetailWithBidScreen extends StatefulWidget {
  final int orderId;
  final BidListData? bidData;

  OrderDetailWithBidScreen({required this.orderId, this.bidData});

  @override
  OrderDetailWithBidScreenState createState() =>
      OrderDetailWithBidScreenState();
}

class OrderDetailWithBidScreenState extends State<OrderDetailWithBidScreen> {
  UserData? userData;

  OrderData? orderData;
  List<OrderHistory>? orderHistory;
  CourierCompanyDetail? courierDetails;
  Payment? payment;
  List<ExtraChargeRequestModel> list = [];
  double? totalDistance;
  String? distance, duration;
  // num productAmount = 0;
  String? reason;
  String? otherReason;
  bool canCancel = false;
  List<String> reasonsList = getDeliveryBoyBeforePickupCancelReasonList();
  List<Map<String, String>> packagingSymbols = [];
  TextEditingController reasonController = TextEditingController();
  bool isOtherOptionSelected = false;
  int differenceInMinutes = 0;
  Duration remainingTime = Duration(); // Remaining time
  Timer? timer;
  List<PlatformFile>? selectedFiles;
  TextEditingController proofTitleTextEditingController =
      TextEditingController();
  TextEditingController proofDetailsTextEditingController =
      TextEditingController();
  GlobalKey<FormState> claimFormKey = GlobalKey<FormState>();
  bool isUserEligibleForClaim = true;
  String vehicleDataitle = "";

  late double biddedAmount;

  late StreamSubscription _getOrdersWithBidsStreamToCancelBid;
  BidOrderModel? latestOrderToCancelBid;
  bool isBidAvailable = false;

  @override
  void initState() {
    super.initState();
    listenToOrderWithBidsStreamToCancelBid();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    orderDetailApiCall();
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await getOrderDetails(widget.orderId).then((value) {
      orderData = value.data!;
      if (orderData!.vehicleData != null) {
        vehicleDataitle =
            "${language.name} : ${orderData!.vehicleData!.title}, ${language.price} : ${appStore.currencySymbol}${orderData!.vehicleData!.price.validate()}, "
            "${language.capacity} : ${orderData!.vehicleData!.capacity.validate()},${language.perKmCharge} : "
            "${appStore.currencySymbol}${orderData!.vehicleData!.perKmCharge.validate()}";
      }
      orderHistory = value.orderHistory!;
      if (value.courierCompanyDetail != null) {
        courierDetails = value.courierCompanyDetail!;
      }
      payment = value.payment ?? Payment();
      list.clear();
      if (orderData!.extraCharges.runtimeType == List<dynamic>) {
        (orderData!.extraCharges as List<dynamic>).forEach((element) {
          list.add(ExtraChargeRequestModel.fromJson(element));
        });
      }
      if (orderData!.fixedCharges.validate() != 0) {
        list.add(ExtraChargeRequestModel(
            key: FIXED_CHARGES, value: orderData!.fixedCharges!));
      }
      if (value.data!.cityDetails != null) {
        list.add(ExtraChargeRequestModel(
            key: MIN_DISTANCE, value: value.data!.cityDetails!.minDistance));
        list.add(ExtraChargeRequestModel(
            key: MIN_WEIGHT, value: value.data!.cityDetails!.minWeight));
        list.add(ExtraChargeRequestModel(
            key: PER_DISTANCE_CHARGE,
            value: value.data!.cityDetails!.perDistanceCharges));
        list.add(ExtraChargeRequestModel(
            key: PER_WEIGHT_CHARGE,
            value: value.data!.cityDetails!.perWeightCharges));
      }
      print("list added");
      if (getStringAsync(USER_TYPE) == CLIENT) {
        userData = value.deliveryManDetail != null
            ? value.deliveryManDetail
            : UserData();
      } else {
        userData = value.clientDetail;
      }
      getDistanceApiCall();
      if (orderData!.status == ORDER_TRANSFER ||
          orderData!.status == ORDER_ASSIGNED ||
          orderData!.status == ORDER_ACCEPTED) {
        reasonsList = getDeliveryBoyBeforePickupCancelReasonList();
      } else if (orderData!.status == ORDER_PICKED_UP ||
          orderData!.status == ORDER_DEPARTED ||
          orderData!.status == ORDER_ARRIVED) {
        reasonsList = getDeliveryBoyAfterPickupCancelReasonList();
      }
      if (orderData!.packagingSymbols != null) {
        getPackagingSymbols().forEach((element1) {
          orderData!.packagingSymbols!.forEach((element2) {
            if (element1['key'] == element2.key) {
              packagingSymbols.add(element1);
            }
          });
        });
      }
    }).catchError((error) {
      print("------------${error.toString()}");
      toast(error.toString());
    }).whenComplete(() => appStore.setLoading(false));
  }

  getDistanceApiCall() async {
    String? originLat = orderData!.pickupPoint!.latitude.validate();
    String? originLong = orderData!.pickupPoint!.longitude.validate();
    String? destinationLat = orderData!.deliveryPoint!.latitude.validate();
    String? destinationLong = orderData!.deliveryPoint!.longitude.validate();
    String origins = "${originLat},${originLong}";
    String destinations = "${destinationLat},${destinationLong}";
    await getDistanceBetweenLatLng(origins, destinations).then((value) {
      duration = value.rows[0].elements[0].duration.text;
      double distanceInKms = value.rows[0].elements[0].distance.text
          .toString()
          .split(' ')[0]
          .toDouble();
      if (appStore.distanceUnit == DISTANCE_UNIT_MILE) {
        totalDistance = (MILES_PER_KM * distanceInKms);
        distance = totalDistance!.toStringAsFixed(2) + DISTANCE_UNIT_MILE;
      } else {
        totalDistance = distanceInKms;
        distance = totalDistance.toString() + DISTANCE_UNIT_KM;
      }
      setState(() {});
    });
  }

  createApplyForBidApiCall() async {
    log('createApplyForBidApiCall called');
    appStore.setLoading(true);

    Map req = {
      "id": widget.bidData!.id,
      "order_id": orderData!.id,
      "bid_amount": biddedAmount.toDouble(),
      "notes": reasonController.text.trim(),
    };

    try {
      await createBid(req).then((value) {
        appStore.setLoading(false);
        toast(value.message);
        DHomeFragment().launch(context, isNewTask: true);
      }).whenComplete(
        () {
          appStore.setLoading(false);
        },
      );
    } catch (error) {
      appStore.setLoading(false);
      log('Error during apply bid API call: $error');
      toast(language.errorSomethingWentWrong);
    }
  }

  void _showBidBottomSheet(BuildContext context) {
    biddedAmount = orderData!.totalAmount.toDouble();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appStore.isDarkMode
                    ? ColorUtils.scaffoldSecondaryDark
                    : ColorUtils.scaffoldColorLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.placeYourBid,
                              style: boldTextStyle(size: 20)),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: ColorUtils.colorPrimary, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      24.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              border: Border.all(color: Colors.red),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.remove,
                                  color: Colors.red, size: 30),
                              onPressed: () {
                                setModalState(() {
                                  if (biddedAmount > 0) {
                                    biddedAmount -=
                                        (biddedAmount >= 10) ? 10 : 1;
                                    if (biddedAmount < 0) {
                                      biddedAmount = 0;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          24.width,
                          Text('${appStore.currencyCode}',
                              style: boldTextStyle(size: 24)),
                          SizedBox(width: 4),
                          Text(biddedAmount.toStringAsFixed(2),
                              style: boldTextStyle(size: 40)),
                          24.width,
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              border: Border.all(color: Colors.green),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add,
                                  color: Colors.green, size: 30),
                              onPressed: () {
                                setModalState(() {
                                  biddedAmount += 10;
                                });
                              },
                            ),
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 12),
                      16.height,
                      Text(language.saySomething,
                          style: boldTextStyle(size: 16)),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: ColorUtils.colorPrimary.withOpacity(0.3),
                        ),
                        child: AppTextField(
                          controller: reasonController,
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            hintText: language.writeAMessage,
                            hintStyle: secondaryTextStyle(
                                size: 16, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      20.height,
                      ElevatedButton(
                        onPressed: () async {
                          hideKeyboard(context);
                          context.pop();
                          await showConfirmDialogCustom(
                            context,
                            primaryColor: ColorUtils.colorPrimary,
                            title: "${language.confirmBid}?",
                            positiveText: language.yes,
                            negativeText: language.no,
                            onAccept: (c) async {
                              createApplyForBidApiCall();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtils.colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(language.confirm,
                            style:
                                boldTextStyle(size: 20, color: Colors.white)),
                      ).withSize(width: context.width(), height: 60),
                      8.height,
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  listenToOrderWithBidsStreamToCancelBid() {
    _getOrdersWithBidsStreamToCancelBid = FirebaseFirestore.instance
        .collection(ORDERS_BID_COLLECTION)
        .where(ACCEPTED_DELIVERY_MAN_IDS, arrayContains: getIntAsync(USER_ID))
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        try {
          List<BidOrderModel> data = snapshot.docs
              .map((e) => BidOrderModel.fromJson(e.data()))
              .toList();

          if (data.isNotEmpty) {
            latestOrderToCancelBid = data[0];
            if (latestOrderToCancelBid?.status == ORDER_CREATED) {
              isBidAvailable = true;
              setState(() {});
            }
          }
        } catch (e) {
          log("ERROR::: $e");
        }
      } else {
        latestOrderToCancelBid = null;
        setState(() {});
      }
    });
  }

  declineOrCancelBid({required bool isDecline}) async {
    appStore.setLoading(true);
    Map req = {
      "id": orderData!.id,
      "delivery_man_id": getIntAsync(USER_ID).toString(),
      "is_bid_accept": isDecline ? "2" : "3"
    };

    try {
      await acceptOrRejectBid(req).then(
        (value) {
          appStore.setLoading(false);
          toast(value.message);
          DHomeFragment().launch(context, isNewTask: true);
        },
      ).whenComplete(
        () {
          appStore.setLoading(false);
        },
      );
    } catch (e) {
      appStore.setLoading(false);
      toast(language.errorSomethingWentWrong);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    reasonController.dispose();
    _getOrdersWithBidsStreamToCancelBid.cancel();
    afterBuildCreated(() {
      appStore.setLoading(false);
    });
  }

  showMoreInformation(
      {String name = "", String information = "", String instruction = ""}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.details, style: boldTextStyle()),
                      Icon(Icons.close, size: 20).onTap(() {
                        pop();
                      })
                    ]),
                10.height,
                Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.5))
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${language.contactPersonName} :",
                      style: secondaryTextStyle(),
                    ).expand(),
                    Text(
                      name,
                      style: boldTextStyle(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ).expand(),
                  ],
                ),
                4.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${language.instruction} :",
                            style: secondaryTextStyle())
                        .expand(),
                    Text(
                      instruction,
                      style: boldTextStyle(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ).expand(),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: commonAppBarWidget(
        '',
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${orderData?.clientName ?? ''}'.capitalizeFirstLetter(),
                    style: secondaryTextStyle(size: 16, color: whiteColor)),
                4.height,
                Text('# ${widget.orderId.validate()}',
                    style: secondaryTextStyle(size: 14, color: Colors.white60)),
              ],
            ).expand(),
          ],
        ),
      ),
      body: Stack(
        children: [
          orderData != null
              ? Stack(
                  children: [
                    AnimatedScrollView(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, top: 16, bottom: 100),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  border: Border.all(
                                      color: ColorUtils.colorPrimary
                                          .withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      orderData!.date != null
                                          ? Text(
                                                  '${DateFormat('dd MMM yyyy').format(DateTime.parse("${orderData!.date!}").toLocal())} ' +
                                                      ' ${language.at.toLowerCase()} ' +
                                                      ' ${DateFormat('hh:mm a').format(DateTime.parse("${orderData!.date!}").toLocal())}',
                                                  style: primaryTextStyle(
                                                      size: 14))
                                              .expand()
                                          : SizedBox(),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: statusColor(orderData!
                                                        .status
                                                        .validate())
                                                    .withOpacity(0.08))),
                                        //  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                        child: Icon(Icons.navigation_outlined,
                                                color: ColorUtils.colorPrimary)
                                            .center(),
                                      ).onTap(() {
                                        openMap(
                                            double.parse(orderData!
                                                .pickupPoint!.latitude
                                                .validate()),
                                            double.parse(orderData!
                                                .pickupPoint!.longitude
                                                .validate()),
                                            double.parse(orderData!
                                                .deliveryPoint!.latitude
                                                .validate()),
                                            double.parse(orderData!
                                                .deliveryPoint!.longitude
                                                .validate()));
                                      }).visible(
                                          orderData!.status != ORDER_DELIVERED),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(orderData!.parcelType.validate(),
                                              style: boldTextStyle(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          4.height,
                                          Row(
                                            children: [
                                              Text('# ${orderData!.id}',
                                                      style: boldTextStyle(
                                                          size: 14))
                                                  .expand(),
                                              if (orderData!.status !=
                                                  ORDER_CANCELLED)
                                                Text(
                                                    printAmount(orderData!
                                                            .totalAmount ??
                                                        0),
                                                    style: boldTextStyle()),
                                            ],
                                          ),
                                          4.height,
                                          Text('${orderData!.orderTrackingId}',
                                              style: boldTextStyle(
                                                  size: 12,
                                                  color:
                                                      ColorUtils.colorPrimary)),
                                          4.height,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(language.distance,
                                                      style: secondaryTextStyle(
                                                          size: 14),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                  4.width,
                                                  Text(distance ?? "0",
                                                      style: boldTextStyle(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(language.duration,
                                                      style: secondaryTextStyle(
                                                          size: 14),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                  4.width,
                                                  Text(duration ?? "0",
                                                      style: boldTextStyle(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                ],
                                              ),
                                            ],
                                          ).visible(orderData!.pickupPoint !=
                                                  null &&
                                              orderData!.deliveryPoint != null),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  8.height,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (orderData!.pickupDatetime !=
                                                  null)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(language.picked,
                                                        style:
                                                            secondaryTextStyle(
                                                                size: 12)),
                                                    4.height,
                                                    Text(
                                                        '${language.at} ${printDateWithoutAt("${orderData!.pickupDatetime!}Z")}',
                                                        style:
                                                            secondaryTextStyle(
                                                                size: 12)),
                                                  ],
                                                ),
                                              4.height,
                                              GestureDetector(
                                                onTap: () {
                                                  // openMap(double.parse(orderData!.pickupPoint!.latitude.validate()),
                                                  //     double.parse(orderData!.pickupPoint!.longitude.validate()));
                                                },
                                                child: Row(
                                                  children: [
                                                    ImageIcon(
                                                        AssetImage(ic_from),
                                                        size: 24,
                                                        color: ColorUtils
                                                            .colorPrimary),
                                                    12.width,
                                                    Text('${orderData!.pickupPoint!.address}',
                                                            style:
                                                                secondaryTextStyle())
                                                        .expand(),
                                                  ],
                                                ),
                                              ),
                                              if (orderData!.pickupDatetime ==
                                                      null &&
                                                  orderData!.pickupPoint!
                                                          .endTime !=
                                                      null &&
                                                  orderData!.pickupPoint!
                                                          .startTime !=
                                                      null)
                                                Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.endTime!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle(
                                                                size: 12,
                                                                color:
                                                                    Colors.red))
                                                    .paddingOnly(top: 4),
                                            ],
                                          ).expand(),
                                          12.width,
                                          if (orderData!
                                                  .pickupPoint!.contactNumber !=
                                              null)
                                            Icon(Ionicons.ios_call_outline,
                                                    size: 20,
                                                    color:
                                                        ColorUtils.colorPrimary)
                                                .onTap(() {
                                              commonLaunchUrl(
                                                  'tel:${orderData!.pickupPoint!.contactNumber}');
                                            }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  16.height,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (orderData!
                                                          .deliveryDatetime !=
                                                      null)
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(language.delivered,
                                                            style:
                                                                secondaryTextStyle(
                                                                    size: 12)),
                                                        4.height,
                                                        Text(
                                                            '${language.at} ${printDateWithoutAt("${orderData!.deliveryDatetime!}Z")}',
                                                            style:
                                                                secondaryTextStyle(
                                                                    size: 12)),
                                                      ],
                                                    ),
                                                  4.height,
                                                  InkWell(
                                                    onTap: () {
                                                      // openMap(
                                                      //     double.parse(orderData!.deliveryPoint!.latitude.validate()),
                                                      //     double.parse(orderData!.deliveryPoint!.longitude.validate()));
                                                    },
                                                    child: Row(
                                                      children: [
                                                        ImageIcon(
                                                            AssetImage(ic_to),
                                                            size: 24,
                                                            color: ColorUtils
                                                                .colorPrimary),
                                                        12.width,
                                                        Text('${orderData!.deliveryPoint!.address}',
                                                                style:
                                                                    secondaryTextStyle(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start)
                                                            .expand(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (orderData!
                                                          .deliveryDatetime ==
                                                      null &&
                                                  orderData!.deliveryPoint!
                                                          .endTime !=
                                                      null &&
                                                  orderData!.deliveryPoint!
                                                          .startTime !=
                                                      null)
                                                Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.endTime!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle(
                                                                color:
                                                                    Colors.red,
                                                                size: 12))
                                                    .paddingOnly(top: 4)
                                            ],
                                          ).expand(),
                                          12.width,
                                          if (orderData!.deliveryPoint!
                                                  .contactNumber !=
                                              null)
                                            Icon(Ionicons.ios_call_outline,
                                                    size: 20,
                                                    color:
                                                        ColorUtils.colorPrimary)
                                                .onTap(() {
                                              commonLaunchUrl(
                                                  'tel:${orderData!.deliveryPoint!.contactNumber}');
                                            }),
                                        ],
                                      ),
                                      if (orderData!.reScheduleDateTime != null)
                                        Text('${language.note} ${language.rescheduleMsg} ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(orderData!.reScheduleDateTime!))} ',
                                                style: secondaryTextStyle(
                                                    color: Colors.red,
                                                    size: 12))
                                            .paddingOnly(top: 4)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            16.height,
                            Text(language.parcelDetails,
                                style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  border: Border.all(
                                      color: ColorUtils.colorPrimary
                                          .withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration:
                                            boxDecorationWithRoundedCorners(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border:
                                                    Border
                                                        .all(
                                                            color:
                                                                ColorUtils
                                                                    .borderColor,
                                                            width: appStore
                                                                    .isDarkMode
                                                                ? 0.2
                                                                : 1),
                                                backgroundColor:
                                                    Colors.transparent),
                                        padding: EdgeInsets.all(8),
                                        child: Image.asset(
                                            parcelTypeIcon(orderData!.parcelType
                                                .validate()),
                                            height: 24,
                                            width: 24,
                                            color: Colors.grey),
                                      ),
                                      8.width,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(orderData!.parcelType.validate(),
                                              style: boldTextStyle()),
                                          4.height,
                                          Text(
                                              '${orderData!.totalWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}',
                                              style: secondaryTextStyle()),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.numberOfParcels,
                                          style: secondaryTextStyle()),
                                      Text('${orderData!.totalParcel ?? 1}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ).visible(orderData!.totalParcel != null),
                                  8.height,
                                ],
                              ),
                            ),
                            16.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.labels,
                                        style: boldTextStyle(size: 16))
                                    .visible(packagingSymbols.isNotEmpty),
                                Icon(Icons.info,
                                        color: appStore.isDarkMode
                                            ? Colors.white.withOpacity(0.7)
                                            : ColorUtils.colorPrimary)
                                    .onTap(() {
                                  PackagingSymbolsInfo().launch(context);
                                })
                              ],
                            ).visible(packagingSymbols.isNotEmpty),
                            12.height.visible(packagingSymbols.isNotEmpty),
                            Container(
                              width: context.width(),
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  border: Border.all(
                                      color: ColorUtils.colorPrimary
                                          .withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: packagingSymbols.map((item) {
                                      return Container(
                                        width: 50,
                                        decoration:
                                            boxDecorationWithRoundedCorners(
                                                backgroundColor:
                                                    Colors.transparent,
                                                border: Border.all(
                                                  color: ColorUtils.colorPrimary
                                                      .withOpacity(0.4),
                                                )),
                                        child: Stack(
                                          children: [
                                            Image.asset(
                                              item['image'].toString(),
                                              width: 24,
                                              height: 24,
                                              color: appStore.isDarkMode
                                                  ? Colors.white
                                                      .withOpacity(0.7)
                                                  : ColorUtils.colorPrimary,
                                            ).center().paddingAll(10),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ).visible(packagingSymbols.isNotEmpty),
                            16.height.visible(packagingSymbols.isNotEmpty),
                            Text(language.shippedVia,
                                    style: boldTextStyle(size: 16))
                                .visible(courierDetails != null &&
                                    (orderData!.status != ORDER_CREATED &&
                                        orderData!.status != ORDER_DELIVERED)),
                            12.height.visible(courierDetails != null &&
                                orderData!.status != ORDER_CREATED &&
                                (orderData!.status != ORDER_DELIVERED)),
                            if (courierDetails != null &&
                                orderData!.status != ORDER_DELIVERED &&
                                orderData!.status != ORDER_CREATED)
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    border: Border.all(
                                        color: ColorUtils.colorPrimary
                                            .withOpacity(0.3)),
                                    backgroundColor: Colors.transparent),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(ic_no_data,
                                                height: 30,
                                                width: 30,
                                                fit: BoxFit.cover,
                                                alignment: Alignment.center)
                                            .center(),
                                        8.width,
                                        Text(courierDetails!.name.toString(),
                                                style: boldTextStyle())
                                            .expand(),
                                        if (!courierDetails!.link.isEmptyOrNull)
                                          AppButton(
                                            elevation: 0,
                                            height: 20,
                                            color: Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4),
                                            shapeBorder: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      defaultRadius),
                                              side: BorderSide(
                                                  color:
                                                      ColorUtils.colorPrimary),
                                            ),
                                            child: Text(language.track,
                                                style: primaryTextStyle(
                                                    color: ColorUtils
                                                        .colorPrimary)),
                                            onTap: () {
                                              commonLaunchUrl(courierDetails!
                                                  .link
                                                  .toString());
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            16.height.visible(courierDetails != null &&
                                orderData!.status != ORDER_DELIVERED),
                            Text(language.paymentDetails,
                                style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  border: Border.all(
                                      color: ColorUtils.colorPrimary
                                          .withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.paymentType,
                                          style: secondaryTextStyle()),
                                      Text(
                                          '${paymentType(orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH))}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.paymentStatus,
                                          style: secondaryTextStyle()),
                                      Text(
                                          '${paymentStatus(orderData!.paymentStatus.validate(value: PAYMENT_PENDING))}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.paymentCollectFrom,
                                          style: secondaryTextStyle()),
                                      Text(
                                          '${paymentCollectForm(orderData!.paymentCollectFrom!)}',
                                          style: boldTextStyle(size: 14)),
                                    ],
                                  ).visible(orderData!.paymentType
                                          .validate(value: PAYMENT_TYPE_CASH) ==
                                      PAYMENT_TYPE_CASH),
                                ],
                              ),
                            ),
                            if (!orderData!
                                .pickupPoint!.description.isEmptyOrNull)
                              16.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.pickupInformation,
                                        style: boldTextStyle(size: 16))
                                    .visible(!orderData!.pickupPoint!
                                        .description.isEmptyOrNull),
                                Text(language.viewMore,
                                        style: secondaryTextStyle(size: 12))
                                    .onTap(() {
                                  showMoreInformation(
                                      name: orderData!.pickupPoint!.name
                                          .validate(),
                                      instruction: orderData!
                                          .pickupPoint!.instruction
                                          .validate());
                                }),
                              ],
                            ).visible(!orderData!
                                .pickupPoint!.description.isEmptyOrNull),
                            12.height,
                            Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                        borderRadius: BorderRadius.circular(
                                            defaultRadius),
                                        border: Border.all(
                                            color: ColorUtils.colorPrimary
                                                .withOpacity(0.3)),
                                        backgroundColor: Colors.transparent),
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                                orderData!
                                                    .pickupPoint!.description
                                                    .toString(),
                                                style: boldTextStyle(size: 14),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis)
                                            .expand(),
                                      ],
                                    ))
                                .visible(!orderData!
                                    .pickupPoint!.description.isEmptyOrNull),
                            if (!orderData!
                                .deliveryPoint!.description.isEmptyOrNull)
                              16.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.deliveryInformation,
                                        style: boldTextStyle(size: 16))
                                    .visible(!orderData!.deliveryPoint!
                                        .description.isEmptyOrNull),
                                Text(language.viewMore,
                                        style: secondaryTextStyle(size: 12))
                                    .onTap(() {
                                  showMoreInformation(
                                      name: orderData!.deliveryPoint!.name
                                          .validate(),
                                      instruction: orderData!
                                          .deliveryPoint!.instruction
                                          .validate());
                                }),
                              ],
                            ).visible(!orderData!
                                .deliveryPoint!.description.isEmptyOrNull),
                            12.height,
                            Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                        borderRadius: BorderRadius.circular(
                                            defaultRadius),
                                        border: Border.all(
                                            color: ColorUtils.colorPrimary
                                                .withOpacity(0.3)),
                                        backgroundColor: Colors.transparent),
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                                orderData!
                                                    .deliveryPoint!.description
                                                    .toString(),
                                                style: boldTextStyle(size: 14),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis)
                                            .expand(),
                                      ],
                                    ))
                                .visible(!orderData!
                                    .deliveryPoint!.description.isEmptyOrNull),
                            if (orderData!.vehicleData != null) 16.height,
                            if (orderData!.vehicleData != null)
                              Text(language.vehicle, style: boldTextStyle()),
                            if (orderData!.vehicleData != null) 12.height,
                            if (orderData!.vehicleData != null)
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    border: Border.all(
                                        color: ColorUtils.colorPrimary
                                            .withOpacity(0.3)),
                                    backgroundColor: Colors.transparent),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    commonCachedNetworkImage(
                                        orderData!.vehicleData!.vehicleImage
                                            .validate(),
                                        height: 40,
                                        width: 40),
                                    SizedBox(width: 16),
                                    Expanded(
                                      // Wrapping the Column with Expanded to prevent overflow
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Align to start
                                        children: [
                                          if (vehicleDataitle != "")
                                            Container(
                                              width: context.width() * 0.6,
                                              child: Text(
                                                vehicleDataitle,
                                                style: primaryTextStyle(),
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ],
                                ).paddingAll(10),
                              ),
                            if (userData != null &&
                                (orderData!.status != ORDER_CREATED &&
                                    orderData!.status != ORDER_DRAFT))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  Text(
                                      '${getStringAsync(USER_TYPE) == CLIENT ? language.aboutDeliveryMan : language.aboutUser}',
                                      style: boldTextStyle(size: 16)),
                                  12.height,
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                        borderRadius: BorderRadius.circular(
                                            defaultRadius),
                                        border: Border.all(
                                            color: ColorUtils.colorPrimary
                                                .withOpacity(0.3)),
                                        backgroundColor: Colors.transparent),
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.network(
                                                    userData!.profileImage
                                                        .validate(),
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.center)
                                                .cornerRadiusWithClipRRect(60)
                                                .visible(!userData!.profileImage
                                                    .isEmptyOrNull),
                                            commonCachedNetworkImage(ic_profile,
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.center)
                                                .cornerRadiusWithClipRRect(60)
                                                .visible(userData!.profileImage
                                                    .isEmptyOrNull),
                                            8.width,
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            '${userData!.name.validate()}',
                                                            style:
                                                                boldTextStyle()),
                                                        4.width,
                                                        if (getStringAsync(
                                                                    USER_TYPE) ==
                                                                CLIENT &&
                                                            !userData!
                                                                .documentVerifiedAt
                                                                .isEmptyOrNull)
                                                          Icon(
                                                              Octicons.verified,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                4.height,
                                                userData!.contactNumber != null
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text('${userData!.contactNumber}',
                                                                  style:
                                                                      secondaryTextStyle())
                                                              .paddingOnly(
                                                                  top: 4)
                                                              .onTap(() {
                                                            commonLaunchUrl(
                                                                'tel:${userData!.contactNumber}');
                                                          }),
                                                          InkWell(
                                                              onTap: () {
                                                                commonLaunchUrl(
                                                                    'tel:${userData!.contactNumber}');
                                                                //   ChatScreen(userData: userData).launch(context);
                                                              },
                                                              child: Icon(
                                                                  Ionicons
                                                                      .call_outline,
                                                                  size: 22,
                                                                  color: ColorUtils
                                                                      .colorPrimary))
                                                        ],
                                                      )
                                                    : SizedBox()
                                              ],
                                            ).expand(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (orderData!.reason.validate().isNotEmpty &&
                                orderData!.status != ORDER_CANCELLED)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  24.height,
                                  Text(language.returnReason,
                                      style: boldTextStyle()),
                                  12.height,
                                  Container(
                                    width: context.width(),
                                    decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                        '${orderData!.reason.validate(value: "-")}',
                                        style: primaryTextStyle(
                                            color: Colors.red)),
                                  ),
                                ],
                              ),
                            if (orderData!.status == ORDER_CANCELLED)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  24.height,
                                  Text(language.cancelledReason,
                                      style: boldTextStyle()),
                                  12.height,
                                  Container(
                                    width: context.width(),
                                    decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                        '${orderData!.reason.validate(value: "-")}',
                                        style: primaryTextStyle(
                                            color: Colors.red)),
                                  ),
                                ],
                              ),
                            16.height,
                            (orderData!.extraCharges.runtimeType ==
                                    List<dynamic>)
                                ? OrderSummeryWidget(
                                    vehiclePrice:
                                        orderData!.vehicleCharge.validate(),
                                    extraChargesList: list,
                                    totalDistance:
                                        orderData!.totalDistance != null
                                            ? orderData!.totalDistance
                                            : 0,
                                    totalWeight:
                                        orderData!.totalWeight.validate(),
                                    distanceCharge:
                                        orderData!.distanceCharge.validate(),
                                    weightCharge:
                                        orderData!.weightCharge.validate(),
                                    totalAmount: orderData!.totalAmount,
                                    payment: payment,
                                    status: orderData!.status,
                                    isDetail: true,
                                    isInsuranceChargeDisplay:
                                        orderData!.insuranceCharge != 0
                                            ? true
                                            : false,
                                    insuranceCharge: orderData!.insuranceCharge,
                                    baseTotal: orderData!.baseTotal)
                                : Container(
                                    width: context.width(),
                                    padding: EdgeInsets.all(16),
                                    decoration: boxDecorationWithRoundedCorners(
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius),
                                      border: Border.all(
                                          color: ColorUtils.colorPrimary
                                              .withOpacity(0.2)),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderData!.vehicleData != null)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "${language.vehicle} ${language.price.toLowerCase()}",
                                                  style: primaryTextStyle()),
                                              16.width,
                                              Text(
                                                  '${printAmount(orderData!.vehicleData!.price)}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language.deliveryCharge,
                                                style: primaryTextStyle()),
                                            16.width,
                                            Text(
                                                '${printAmount(orderData!.fixedCharges.validate())}',
                                                style: primaryTextStyle()),
                                          ],
                                        ),
                                        if (orderData!.insuranceCharge != 0)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.insuranceCharge,
                                                  style: primaryTextStyle()),
                                              16.width,
                                              Text(
                                                  '${orderData!.insuranceCharge.validate()}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        if (orderData!.distanceCharge
                                                .validate() !=
                                            0)
                                          Column(
                                            children: [
                                              8.height,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(language.distanceCharge,
                                                      style:
                                                          primaryTextStyle()),
                                                  16.width,
                                                  Text(
                                                      '${printAmount(orderData!.distanceCharge.validate())}',
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              )
                                            ],
                                          ),
                                        if (orderData!.weightCharge
                                                .validate() !=
                                            0)
                                          Column(
                                            children: [
                                              8.height,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(language.weightCharge,
                                                      style:
                                                          primaryTextStyle()),
                                                  16.width,
                                                  Text(
                                                      '${printAmount(orderData!.weightCharge.validate())}',
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              ),
                                            ],
                                          ),
                                        if (orderData!.extraCharges != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              16.height,
                                              Text(language.extraCharges,
                                                  style: boldTextStyle()),
                                              8.height,
                                              Column(
                                                  children: List.generate(
                                                      orderData!
                                                          .extraCharges!
                                                          .keys
                                                          .length, (index) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          orderData!
                                                              .extraCharges.keys
                                                              .elementAt(index)
                                                              .replaceAll(
                                                                  "_", " "),
                                                          style:
                                                              primaryTextStyle()),
                                                      16.width,
                                                      Text(
                                                          '${printAmount(orderData!.extraCharges.values.elementAt(index))}',
                                                          style:
                                                              primaryTextStyle()),
                                                    ],
                                                  ),
                                                );
                                              }).toList()),
                                            ],
                                          ).visible(orderData!
                                                  .extraCharges.keys.length !=
                                              0),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ],
                )
              : SizedBox(),
          Observer(
              builder: (context) =>
                  loaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 4,
        child: Container(
          height: 80,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.bidData!.bidAmount! > 0) ...[
                      Text(
                        '${language.youPlaced}:',
                        style: boldTextStyle(),
                      ),
                      Text(
                        '${appStore.currencySymbol} ${widget.bidData!.bidAmount!}',
                        style: boldTextStyle(size: 20),
                      ),
                    ] else ...[
                      Text(
                        '${language.totalAmount}:',
                        style: boldTextStyle(),
                      ),
                      Text(
                        '${appStore.currencySymbol} ${orderData?.totalAmount ?? 0}',
                        style: boldTextStyle(size: 20),
                      ),
                    ]
                  ],
                ),
              ),
              SizedBox(width: 16),
              if (widget.bidData!.isBidAccept == 0 && isBidAvailable)
                AppButton(
                  text: language.cancelBid,
                  color: Colors.red,
                  onTap: () async {
                    await showConfirmDialogCustom(
                      context,
                      primaryColor: ColorUtils.colorPrimary,
                      title: "${language.declineBidConfirm}?",
                      positiveText: language.yes,
                      negativeText: language.no,
                      onAccept: (c) async {
                        declineOrCancelBid(isDecline: false);
                      },
                    );
                  },
                ).expand()
              else if (widget.bidData!.isBidAccept == null)
                AppButton(
                  text: "${language.placeBid}",
                  color: ColorUtils.colorPrimary,
                  onTap: () {
                    _showBidBottomSheet(context);
                  },
                ).expand()
              else if (widget.bidData!.isBidAccept == 1)
                Center(
                  child: Text(
                    "${language.bidAccepted}",
                    style: boldTextStyle(color: ColorUtils.colorPrimary),
                  ),
                )
              else
                Center(
                  child: Text(
                    "${language.bidRejected}",
                    style: boldTextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/models/GroupedOrderData.dart';

import 'package:mighty_delivery/main/services/RoutePlanService.dart';
import 'package:mighty_delivery/main/utils/storage.dart';

import '../../delivery/screens/OrdersMapScreen.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/widgets.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

import '../../delivery/fragment/DProfileFragment.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/animatedList/animated_configurations.dart';
import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/app_button.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/horizontal_list.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/screens/UserCitySelectScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../user/screens/OrderDetailScreen.dart';
import 'ReceivedScreenOrderScreen.dart';

// background geolocation
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class DeliveryDashBoard extends StatefulWidget {
  final int selectedIndex;

  DeliveryDashBoard({this.selectedIndex = 0});

  @override
  @override
  DeliveryDashBoardState createState() => DeliveryDashBoardState();
}

class DeliveryDashBoardState extends State<DeliveryDashBoard>
    with WidgetsBindingObserver {
  List<String> statusList = [
    ORDER_ASSIGNED,
    ORDER_PICKED_UP,
    ORDER_DELIVERED,
    ORDER_CANCELLED,
  ];
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();
  PageController pageController = PageController();
  int currentPage = 1;
  int totalPage = 1;
  int selectedStatusIndex = 0;
  List<OrderData> orderData = [];
  List<GroupedOrderData> groupedOrderDataList = []; // 分组数据

  // List<NewOrderData> orderData = []; // change type to var
  GlobalKey<FormState> rescheduleFormKey = GlobalKey<FormState>();
  TextEditingController reasonTitleTextEditingController =
      TextEditingController();
  TextEditingController dateTextEditingController = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  DateTime? pickDate;

  @override
  void initState() {
    super.initState();
    print("当前进入 DeliveryDashBoard页面");
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  void init() async {
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
    selectedStatusIndex = widget.selectedIndex;
    // await getAppSetting().then((value) {
    //   print(
    //       "-------------------------------${value.otpVerifyOnPickupDelivery}");
    //   appStore
    //       .setOtpVerifyOnPickupDelivery(value.otpVerifyOnPickupDelivery == 1);
    //   appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
    //   appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
    //   appStore.setCurrencyPosition(
    //       value.currencyPosition ?? CURRENCY_POSITION_LEFT);
    //   appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
    //   appStore.setSiteEmail(value.siteEmail ?? "");
    //   appStore.setCopyRight(value.siteCopyright ?? "");
    //   //   appStore.setOrderTrackingIdPrefix(value.orderTrackingIdPrefix ?? "");
    //   appStore.setIsInsuranceAllowed(value.isInsuranceAllowed ?? "0");
    //   appStore.setInsurancePercentage(value.insurancePercentage ?? "0");
    //   appStore.setInsuranceDescription(value.insuranceDescription ?? "");
    //   appStore.setMaxAmountPerMonth(value.maxEarningsPerMonth ?? '');
    //   appStore.setClaimDuration(value.claimDuration ?? "");
    //   // setValue(IS_VERIFIED_DELIVERY_MAN, (value.isVerifiedDeliveryMan.validate() == 1));
    // }).catchError((error) {
    //   log(error.toString());
    // });
    if (await checkPermission()) {
      await checkLocationPermission(context);
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});
          getOrderListApiCall();
        }
      }
    });
    if (selectedStatusIndex == 5) {
      scrollController1.animateTo(4 * 100,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    await getOrderListApiCall();
    afterBuildCreated(() => appStore.setLoading(true));
  }

  Future<void> checkLocationPermission(BuildContext context) async {
    initLocationStream();
  }

  void initLocationStream() async {
    positionStream?.cancel();

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position event) async {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        event.latitude,
        event.longitude,
      );
      try {
        if (placeMarks.isNotEmpty) {
          // 停止调用 updateUserStatus
          log("位置更新：纬度 ${event.latitude}, 经度 ${event.longitude}");
        }
      } catch (e) {}
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      default:
    }
  }

  void onResumed() async {
    await checkLocationPermission(context);
    setState(() {});
  }

  // getOrderListApiCall() async {
  //   appStore.setLoading(true);
  //   await getDeliveryBoyOrderList(
  //           page: currentPage,
  //           deliveryBoyID: getIntAsync(USER_ID),
  //           cityId: getIntAsync(CITY_ID),
  //           countryId: getIntAsync(COUNTRY_ID),
  //           orderStatus: statusList[selectedStatusIndex])
  //       .then((value) {
  //     appStore.setLoading(false);
  //     appStore.setAllUnreadCount(value.allUnreadCount.validate());
  //     currentPage = value.pagination!.currentPage!;
  //     totalPage = value.pagination!.totalPages!;
  //     if (currentPage == 1) {
  //       orderData.clear();
  //     }
  //     orderData.addAll(value.data!);
  //     // default
  //     setState(() {});
  //     appStore.setLoading(false);
  //   }).catchError((error) {
  //     log(error);
  //   }).whenComplete(() {
  //     appStore.setLoading(false);
  //   });
  // }

  // 测试：直接使用模拟数据，而不调用真实 API
  // getOrderListApiCall() async {
  //   print("getOrderListApiCall invoked");
  //   // 测试：直接使用模拟数据，而不调用真实 API
  //   final Map<String, dynamic> sampleData = {
  //     "pagination": {
  //       "total_items": 1,
  //       "per_page": 10,
  //       "currentPage": 1,
  //       "totalPages": 1,
  //     },
  //     "data": [
  //       {
  //         "id": 101,
  //         "order_tracking_id": "ORD-20250310001",
  //         "client_id": 1,
  //         "client_name": "John Doe",
  //         "date": "2025-03-20",
  //         "pickup_point": {
  //           "name": "Pickup Point",
  //           "address": "123 Pickup St",
  //           "latitude": "37.785834",
  //           "longitude": "-122.406417",
  //           "description": "Pickup description",
  //           "contact_number": "1234567890",
  //           "start_time": "2025-03-20T09:00:00",
  //           "end_time": "2025-03-20T10:00:00",
  //           "instruction": "Be on time"
  //         },
  //         "delivery_point": {
  //           "name": "Delivery Point",
  //           "address": "456 Delivery Ave",
  //           "latitude": "37.781234",
  //           "longitude": "-122.407654",
  //           "description": "Delivery description",
  //           "contact_number": "0987654321",
  //           "start_time": "2025-03-20T11:00:00",
  //           "end_time": "2025-03-20T12:00:00",
  //           "instruction": "Ring the bell"
  //         },
  //         "country_id": 1,
  //         "country_name": "USA",
  //         "city_id": 1,
  //         "city_name": "San Francisco",
  //         "parcel_type": "Small",
  //         "total_weight": 1.5,
  //         "total_distance": 5.0,
  //         "pickup_datetime": "2025-03-20T09:30:00",
  //         "delivery_datetime": "2025-03-20T11:30:00",
  //         "parent_order_id": null,
  //         "status": "ORDER_ASSIGNED",
  //         "payment_id": 1001,
  //         "payment_type": "Cash",
  //         "payment_status": "Pending",
  //         "payment_collect_from": "Delivery",
  //         "delivery_man_id": 2739,
  //         "delivery_man_name": "Delivery Man",
  //         "bid_type": 0,
  //         "fixed_charges": 5.0,
  //         "vehicle_charge": 2.0,
  //         "extra_charges": 1.0,
  //         "total_amount": 8.0,
  //         "reason": "",
  //         "pickup_confirm_by_client": 1,
  //         "pickup_confirm_by_delivery_man": 1,
  //         "pickup_time_signature": null,
  //         "delivery_time_signature": null,
  //         "deleted_at": null,
  //         "return_order_id": false,
  //         "weight_charge": 0.5,
  //         "distance_charge": 0.8,
  //         "total_parcel": 1,
  //         "auto_assign": 1,
  //         "cancelled_delivery_man_ids": [],
  //         "vehicle_id": 15,
  //         "vehicle_data": {
  //           "id": 15,
  //           "vehicleTypeName": "SmallCar",
  //           "vehicleTypeId": "3a18c3a7-9f83-aa47-f9e0-99fe604bc5e2",
  //           "driverName": "Driver 1",
  //           "vehicle_register_no": "ABC123"
  //         },
  //         "vehicle_image": "https://example.com/vehicle.png",
  //         "invoice": "https://example.com/invoice.pdf",
  //         "insurance_charge": 0.5,
  //         "base_total": 7.5,
  //         "isClaimed": 0,
  //         "extra_charge_list": [],
  //         "city_details_list": {},
  //         "rescheduledatetime": null,
  //         "is_reschedule": 0,
  //         "packaging_symbols": []
  //       }
  //     ],
  //     "all_unread_count": 0,
  //     "wallet_data": null
  //   };
  //   try {
  //     appStore.setLoading(true);
  //     // 使用 OrderListModel.fromJson() 进行解析
  //     var orderListModel = OrderListModel.fromJson(toStringKeyMap(sampleData));
  //     // 更新分页信息
  //     currentPage = orderListModel.pagination?.currentPage ?? 1;
  //     totalPage = orderListModel.pagination?.totalPages ?? 1;
  //     // 清空以前的数据并添加新的数据
  //     orderData.clear();
  //     orderData.addAll(orderListModel.data ?? []);
  //   } catch (e) {
  //     log("Error in getOrderListApiCall: $e");
  //   } finally {
  //     appStore.setLoading(false);
  //   }
  //   setState(() {});
  //   // appStore.setLoading(false);
  // }

  getOrderListApiCall() async {
    print("getOrderListApiCall invoked");

    try {
      appStore.setLoading(true);

      // 获取当前选中的状态
      String selectedStatus = statusList[selectedStatusIndex];
      String enumStatus = convertStatusToEnum(selectedStatus); // 转换为枚举字符串
      int statusCode = convertStatusToInt(enumStatus); // 将枚举字符串转换为整数

      // 调用 RoutePlanService 获取数据
      final routePlanService = RoutePlanService();
      final response =
          await routePlanService.getRoutePlansByVehicleIdAndStatusCode(
        vehicleId: SpUtil.getJSON("vehicleId"),
        statusCode: statusCode, // 使用转换后的整数状态码
      );

      // 转换新格式为现有格式
      final transformedResponse =
          routePlanService.transformNewResponseToExistingFormat({
        "totalCount": response.length,
        "items": response,
      });

      // 使用 OrderListModel.fromJson() 解析数据
      var orderListModel =
          OrderListModel.fromJson(toStringKeyMap(transformedResponse));

      // 更新分页信息
      currentPage = orderListModel.pagination?.currentPage ?? 1;
      totalPage = orderListModel.pagination?.totalPages ?? 1;

      // 清空以前的数据并添加新的数据
      orderData.clear();
      orderData.addAll(orderListModel.data ?? []);

      groupOrderData(); // 分组数据
    } catch (e) {
      log("Error in getOrderListApiCall: $e");
    } finally {
      appStore.setLoading(false);
    }

    setState(() {});
  }

  String convertStatusToEnum(String status) {
    switch (status) {
      case ORDER_ASSIGNED:
        return "Assigned";
      case ORDER_PICKED_UP:
        return "PickedUp";
      case ORDER_DELIVERED:
        return "Delivered";
      case ORDER_CANCELLED:
        return "Cancelled";
      default:
        throw Exception("Unknown status: $status");
    }
  }

  int convertStatusToInt(String status) {
    switch (status) {
      case 'Draft':
        return 0;
      case 'Assigned':
        return 1;
      case 'Accepted':
        return 2;
      case 'PickedUp':
        return 3;
      case 'Departed':
        return 4;
      case 'Delivered':
        return 5;
      case 'Cancelled':
        return 6;
      case 'Shipped':
        return 7;
      case 'SelfDefined':
        return 8;
      default:
        throw Exception('Unknown status: $status');
    }
  }

  groupOrderData() async {
    // 创建一个 Map，用于存储分类后的数据
    Map<String, List<OrderData>> groupedOrders = {};
    // 遍历 orderData 列表
    for (var order in orderData) {
      // 获取 businessEntityId
      String? businessEntityId = order.pickupPoint?.businessEntityId;

      // 如果 businessEntityId 为空，跳过该订单
      if (businessEntityId == null) continue;

      // 如果 Map 中不存在该 businessEntityId，则初始化一个空列表
      if (!groupedOrders.containsKey(businessEntityId)) {
        groupedOrders[businessEntityId] = [];
      }

      // 将订单添加到对应的 businessEntityId 的列表中
      groupedOrders[businessEntityId]!.add(order);
    }

    // 将 Map 转换为 List<GroupedOrderData>
    groupedOrderDataList = groupedOrders.entries.map((entry) {
      return GroupedOrderData(
        deliveryOrderId: entry.key, // 使用 businessEntityId 作为分组 ID
        orders: entry.value, // 对应的订单列表
      );
    }).toList();

    // 打印分类后的数据（可选）
    print("Grouped Order Data: $groupedOrderDataList");

    // this.groupedOrderDataList = groupedOrderDataList;
  }

  Map<String, dynamic> toStringKeyMap(Map<dynamic, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        result[key.toString()] = toStringKeyMap(value);
      } else if (value is List) {
        result[key.toString()] = value.map((e) {
          if (e is Map<dynamic, dynamic>) return toStringKeyMap(e);
          return e;
        }).toList();
      } else {
        result[key.toString()] = value;
      }
    });
    return result;
  }

  Future<void> cancelOrder(OrderData order) async {
    appStore.setLoading(true);
    List<dynamic> cancelledDeliverManIds = order.cancelledDeliverManIds ?? [];
    cancelledDeliverManIds.add(getIntAsync(USER_ID));
    Map req = {
      "id": order.id,
      "cancelled_delivery_man_ids": cancelledDeliverManIds,
    };
    await cancelAutoAssignOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      getOrderListApiCall();
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    super.dispose();
  }

  void handleOrderAction(OrderData orderData, String orderStatus) async {
    if (orderStatus == ORDER_ASSIGNED) {
      print("Handling ORDER_ASSIGNED for order: ${orderData.id}");
      await onTapData(orderStatus: ORDER_ACCEPTED, orderData: orderData);
    } else if (orderStatus == ORDER_PICKED_UP) {
      print("Handling ORDER_PICKED_UP for order: ${orderData.id}");
      await onTapData(orderStatus: ORDER_DEPARTED, orderData: orderData);
    } else if (orderStatus == ORDER_DEPARTED) {
      print("Handling ORDER_DEPARTED for order: ${orderData.id}");
      await onTapData(orderStatus: ORDER_DELIVERED, orderData: orderData);
    } else {
      print("Unhandled order status: $orderStatus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: PreferredSize(
        preferredSize: Size(context.width(), 110),
        child: commonAppBarWidget(
          '${language.hey} ${getStringAsync(NAME)} 👋',
          showBack: true, // Enable the back button
          center: true, // Center the title
          actions: [
            // Container(
            //   margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   decoration: boxDecorationWithRoundedCorners(
            //       borderRadius: radius(defaultRadius),
            //       backgroundColor: Colors.white24),
            //   child: Row(children: [
            //     Icon(Ionicons.ios_location_outline,
            //         color: Colors.white, size: 18),
            //     8.width,
            //     Text(
            //         CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate(),
            //         style: primaryTextStyle(color: white)),
            //   ]).onTap(() {
            //     UserCitySelectScreen(
            //       isBack: true,
            //       onUpdate: () {
            //         currentPage = 1;
            //         getOrderListApiCall();
            //         setState(() {});
            //       },
            //     ).launch(context);
            //   },
            //       highlightColor: Colors.transparent,
            //       hoverColor: Colors.transparent,
            //       splashColor: Colors.transparent),
            // ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Align(
                    alignment: AlignmentDirectional.center,
                    child: Icon(Ionicons.md_notifications_outline,
                        color: Colors.white)),
                Observer(builder: (context) {
                  return Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange, shape: BoxShape.circle),
                        child: Text(
                            '${appStore.allUnreadCount < 99 ? appStore.allUnreadCount : '99+'}',
                            style: primaryTextStyle(
                                size: appStore.allUnreadCount < 99 ? 12 : 8,
                                color: Colors.white))),
                  ).visible(appStore.allUnreadCount != 0);
                }),
              ],
            ).withWidth(30).onTap(() {
              NotificationScreen().launch(context);
            }),
            IconButton(
              padding: EdgeInsets.only(right: 8),
              onPressed: () async {
                DProfileFragment().launch(context,
                    pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
              },
              icon: Icon(Ionicons.settings_outline, color: Colors.white),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size(context.width(), 100),
            child: HorizontalList(
              controller: scrollController1,
              itemCount: statusList.length,
              itemBuilder: (ctx, index) {
                return Theme(
                  data: ThemeData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent),
                  child: Text(orderStatus(statusList[index]),
                          style: statusList[selectedStatusIndex] ==
                                  statusList[index]
                              ? boldTextStyle(color: Colors.white)
                              : secondaryTextStyle(color: Colors.white70))
                      .paddingAll(8)
                      .onTap(() {
                    currentPage = 1;
                    selectedStatusIndex = statusList
                        .indexWhere((item) => item == statusList[index]);
                    pageController.jumpToPage(selectedStatusIndex);
                    getOrderListApiCall();
                    setState(() {});
                  }),
                );
              },
            ).paddingOnly(left: 6, right: 6),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification &&
              notification.depth == 0) {
            if (notification.dragDetails != null &&
                notification.dragDetails?.delta != null) {
              double? delta = notification.dragDetails?.delta.dx;
              double newPosition = scrollController1.position.pixels - delta!;
              scrollController1.jumpTo(newPosition.clamp(
                  0.0, scrollController1.position.maxScrollExtent));
            }
          }
          return false;
        },
        child: Stack(
          children: [
            PageView(
              controller: pageController,
              onPageChanged: (value) {
                selectedStatusIndex =
                    statusList.indexWhere((item) => item == statusList[value]);

                orderData.clear();

                getOrderListApiCall();

                setState(() {});
              },
              children: statusList.map((e) {
                return Stack(
                  children: [
                    groupedOrderDataList.isEmpty
                        ? Center(
                            child:
                                CircularProgressIndicator(), // 如果没有数据，显示加载指示器
                          )
                        : SingleChildScrollView(
                            child: ExpansionPanelList(
                              expansionCallback: (int index, bool isExpanded) {
                                isExpanded =
                                    groupedOrderDataList[index].isExpanded;
                                try {
                                  print(
                                      "Clicked group index: $index, isExpanded: $isExpanded"); // 打印当前分组索引和展开状态
                                  setState(() {
                                    // 切换分组的展开状态
                                    groupedOrderDataList[index].isExpanded =
                                        !isExpanded;
                                    print(
                                        "New isExpanded state: ${groupedOrderDataList[index].isExpanded}"); // 打印切换后的状态
                                  });
                                } catch (e, stackTrace) {
                                  // 捕获并打印错误信息
                                  print("Error in expansionCallback: $e");
                                  print("StackTrace: $stackTrace");
                                }
                              },
                              children: groupedOrderDataList.map((group) {
                                return ExpansionPanel(
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return ListTile(
                                      title: Text(
                                        "Group: ${group.deliveryOrderId ?? 'Unknown'}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.green), // 绿色勾号按钮
                                            onPressed: () {
                                              switch (statusList[
                                                  selectedStatusIndex]) {
                                                case ORDER_ASSIGNED:
                                                  print(
                                                      "Handling ORDER_ASSIGNED");
                                                  showConfirmDialogCustom(
                                                    context,
                                                    primaryColor:
                                                        ColorUtils.colorPrimary,
                                                    dialogType:
                                                        DialogType.CONFIRMATION,
                                                    title: orderTitle(statusList[
                                                        selectedStatusIndex]),
                                                    positiveText: language.yes,
                                                    negativeText: language.no,
                                                    onAccept: (c) async {
                                                      appStore.setLoading(true);
                                                      appStore
                                                          .setLoading(false);
                                                    },
                                                  );
                                                  break;

                                                case ORDER_PICKED_UP:
                                                  print(
                                                      "Handling ORDER_PICKED_UP");

                                                  int val = 0;
                                                  showInDialog(
                                                    barrierDismissible: true,
                                                    context,
                                                    builder: (p0) {
                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            selectedImagesUpdate) {
                                                          return Form(
                                                            key:
                                                                rescheduleFormKey,
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Container(
                                                                child: !appStore
                                                                        .isLoading
                                                                    ? Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              // Reschedule button
                                                                              commonButton(language.reschedule, size: 12, () {
                                                                                selectedImagesUpdate(() {
                                                                                  val = 1;
                                                                                  print("$val"); // Make the reschedule form visible
                                                                                });
                                                                              }).expand(),

                                                                              2.width,

                                                                              // Confirm Delivery button
                                                                              commonButton(language.confirmDelivery, size: 12, () async {
                                                                                if (context.mounted) {
                                                                                  Navigator.pop(context);
                                                                                }
                                                                                // onTapData(
                                                                                //   orderData: data,
                                                                                //   orderStatus: statusList[selectedStatusIndex],
                                                                                // );
                                                                              }).expand(),
                                                                            ],
                                                                          ).visible(val ==
                                                                              0),

                                                                          // Reschedule form
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(language.rescheduleTitle, style: boldTextStyle(), textAlign: TextAlign.start),
                                                                              10.height,
                                                                              Divider(color: dividerColor, height: 1),
                                                                              8.height,

                                                                              // Reason text field
                                                                              Text(language.reason, style: boldTextStyle()),
                                                                              12.height,
                                                                              AppTextField(
                                                                                isValidationRequired: true,
                                                                                controller: reasonTitleTextEditingController,
                                                                                textFieldType: TextFieldType.NAME,
                                                                                errorThisFieldRequired: language.fieldRequiredMsg,
                                                                                decoration: commonInputDecoration(hintText: language.reason),
                                                                              ),
                                                                              8.height,

                                                                              // Date picker
                                                                              Text(language.date, style: boldTextStyle()),
                                                                              12.height,
                                                                              DateTimePicker(
                                                                                controller: pickDateController,
                                                                                type: DateTimePickerType.date,
                                                                                initialDate: DateTime.now(),
                                                                                firstDate: DateTime.now(),
                                                                                lastDate: DateTime.now().add(Duration(days: 30)),
                                                                                onChanged: (value) {
                                                                                  pickDate = DateTime.parse(value);
                                                                                },
                                                                                validator: (value) {
                                                                                  if (value!.isEmpty) return language.fieldRequiredMsg;
                                                                                  return null;
                                                                                },
                                                                                decoration: commonInputDecoration(suffixIcon: Icons.calendar_today, hintText: language.date),
                                                                              ),

                                                                              16.height,

                                                                              // Buttons inside the reschedule form
                                                                              Row(
                                                                                children: [
                                                                                  commonButton(language.cancel, size: 14, () {
                                                                                    finish(context, 0); // Close the dialog
                                                                                  }).expand(),

                                                                                  6.width,

                                                                                  // Reschedule button inside the form
                                                                                  commonButton(language.reschedule, size: 14, () async {
                                                                                    if (rescheduleFormKey.currentState!.validate()) {
                                                                                      // Trigger the reschedule API call
                                                                                      // Map request = {
                                                                                      //   "order_id": data.id,
                                                                                      //   "reason": reasonTitleTextEditingController.text.toString(),
                                                                                      //   "date": DateFormat('yyyy-MM-dd').format(pickDate!),
                                                                                      // };
                                                                                      Map request = {};
                                                                                      appStore.setLoading(true);
                                                                                      await rescheduleOrder(request).then((value) {
                                                                                        toast(value.message);
                                                                                        appStore.setLoading(false);
                                                                                        finish(context);
                                                                                      });
                                                                                    }
                                                                                  }).expand(),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ).visible(val ==
                                                                              1),
                                                                        ],
                                                                      )
                                                                    : Observer(
                                                                        builder:
                                                                            (context) =>
                                                                                loaderWidget().visible(appStore.isLoading),
                                                                      ).center(),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                  break;

                                                case ORDER_DELIVERED:
                                                  print(
                                                      "Handling ORDER_DELIVERED");
                                                  break;

                                                case ORDER_CANCELLED:
                                                  print(
                                                      "Handling ORDER_CANCELLED");
                                                  break;

                                                default:
                                                  print(
                                                      "Unhandled status: ${statusList[selectedStatusIndex]}");
                                                  break;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  body: Column(
                                    children: group.orders!.map((order) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16), // 增加左右两边的 margin
                                        child: orderCard(order), // 渲染每个订单
                                      );
                                    }).toList(),
                                  ),
                                  isExpanded:
                                      group.isExpanded, // 绑定 isExpanded 状态
                                );
                              }).toList(),
                            ),
                          ),
                    // loaderWidget().visible(appStore.isLoading), // 显示加载状态
                    emptyWidget().visible(groupedOrderDataList.isEmpty &&
                        !appStore.isLoading), // 显示空状态
                  ],
                );
                // return Stack(
                //   children: [
                //     AnimatedListView(
                //       itemCount: orderData.length,
                //       shrinkWrap: true,
                //       physics: BouncingScrollPhysics(),
                //       listAnimationType: ListAnimationType.Slide,
                //       padding: EdgeInsets.only(
                //           left: 16, right: 16, top: 16, bottom: 60),
                //       flipConfiguration: FlipConfiguration(
                //           duration: Duration(seconds: 1),
                //           curve: Curves.fastOutSlowIn),
                //       fadeInConfiguration: FadeInConfiguration(
                //           duration: Duration(seconds: 1),
                //           curve: Curves.fastOutSlowIn),
                //       onNextPage: () {
                //         if (currentPage < totalPage) {
                //           currentPage++;
                //           setState(() {});
                //           getOrderListApiCall();
                //         }
                //       },
                //       onSwipeRefresh: () async {
                //         currentPage = 1;
                //         await getAppSetting().then((value) {
                //           appStore.setOtpVerifyOnPickupDelivery(
                //               value.otpVerifyOnPickupDelivery == 1);
                //           appStore.setCurrencyCode(
                //               value.currencyCode ?? CURRENCY_CODE);
                //           appStore.setCurrencySymbol(
                //               value.currency ?? CURRENCY_SYMBOL);
                //           appStore.setCurrencyPosition(
                //               value.currencyPosition ?? CURRENCY_POSITION_LEFT);
                //           appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
                //           appStore.setSiteEmail(value.siteEmail ?? "");
                //           appStore.setCopyRight(value.siteCopyright ?? "");
                //           appStore.setIsInsuranceAllowed(
                //               value.isInsuranceAllowed ?? "0");
                //           appStore.setInsurancePercentage(
                //               value.insurancePercentage ?? "0");
                //           //   appStore.setOrderTrackingIdPrefix(value.orderTrackingIdPrefix ?? "");
                //           appStore.setInsuranceDescription(
                //               value.insuranceDescription ?? "");
                //           appStore.setMaxAmountPerMonth(
                //               value.maxEarningsPerMonth ?? '');
                //           appStore.setClaimDuration(value.claimDuration ?? '');
                //         }).catchError((error) {
                //           log(error.toString());
                //         });
                //         getOrderListApiCall();
                //         return Future.value(true);
                //       },
                //       itemBuilder: (context, i) {
                //         OrderData item = orderData[i];
                //         return item.status != ORDER_DRAFT
                //             ? orderCard(item)
                //             : SizedBox();
                //       },
                //     ).visible(orderData.length > 0),
                //     loaderWidget().visible(appStore.isLoading),
                //     emptyWidget()
                //         .visible(orderData.length <= 0 && !appStore.isLoading),
                //   ],
                // );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: radius(40)),
        backgroundColor: appStore.availableBal >= 0
            ? ColorUtils.colorPrimary
            : textSecondaryColorGlobal,
        child: Icon(Icons.pin_drop_outlined, color: Colors.white),
        onPressed: () {
          // Get current location.
          // 使用 flutter_background_geolocation 获取当前位置信息
          OrdersMapScreen().launch(context);
        },
      ).paddingAll(10),
    );
  }

  Widget orderCard(OrderData data) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: ColorUtils.colorPrimary),
            backgroundColor: Colors.transparent),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // order-id
                Container(
                  height: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${language.order} - ${data.id}',
                              style: boldTextStyle(size: 9))
                          .expand(),
                      Text('${data.orderTrackingId}',
                              style: boldTextStyle(
                                  size: 12, color: ColorUtils.colorPrimary))
                          .expand(),
                    ],
                  ),
                ).expand(),
                // 导航按钮
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: appStore.isDarkMode
                          ? ColorUtils.scaffoldSecondaryDark
                          : ColorUtils.colorPrimaryLight,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(
                          color: ColorUtils.colorPrimary.withOpacity(0.5))),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Icon(
                    Icons.navigation_outlined,
                    color: ColorUtils.colorPrimary,
                    size: 28,
                  ),
                )
                    .onTap(() {
                      openMap(
                          double.parse(data.pickupPoint!.latitude.validate()),
                          double.parse(data.pickupPoint!.longitude.validate()),
                          double.parse(data.deliveryPoint!.latitude.validate()),
                          double.parse(
                              data.deliveryPoint!.longitude.validate()));
                    })
                    .paddingSymmetric(horizontal: 5)
                    .visible(data.status != ORDER_DELIVERED &&
                        data.status != ORDER_CANCELLED &&
                        data.status != ORDER_SHIPPED),
                // 每种card需要进入下一步的按钮
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(color: Colors.red),
                      backgroundColor: Colors.red.withOpacity(0.2)),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 28,
                  ),
                ).onTap(() {
                  showConfirmDialogCustom(
                    context,
                    primaryColor: Colors.red,
                    dialogType: DialogType.CONFIRMATION,
                    title: language.orderCancelConfirmation,
                    positiveText: language.yes,
                    negativeText: language.no,
                    onAccept: (c) async {
                      await cancelOrder(data);
                    },
                  ); // 每种卡片具体的控制逻辑
                }).visible(data.status == ORDER_ASSIGNED),
                (statusList[selectedStatusIndex] == ORDER_ASSIGNED)
                    ? AppButton(
                        elevation: 0,
                        text: buttonText(statusList[
                            selectedStatusIndex]), // 使用 buttonText 方法
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        textStyle: boldTextStyle(color: Colors.white, size: 14),
                        color: ColorUtils.colorPrimary,
                        onTap: () {
                          showConfirmDialogCustom(
                            context,
                            primaryColor: ColorUtils.colorPrimary,
                            dialogType: DialogType.CONFIRMATION,
                            title: orderTitle(statusList[selectedStatusIndex]),
                            positiveText: language.yes,
                            negativeText: language.no,
                            onAccept: (c) async {
                              appStore.setLoading(true);
                              await onTapData(
                                orderData: data,
                                orderStatus: statusList[selectedStatusIndex],
                              );
                              appStore.setLoading(false);
                            },
                          );
                        },
                      ).paddingSymmetric(horizontal: 5)
                    : SizedBox(), // 使用 SizedBox() 代替空的 Container
                (statusList[selectedStatusIndex] != ORDER_CANCELLED &&
                        statusList[selectedStatusIndex] != ORDER_ASSIGNED)
                    ? AppButton(
                        elevation: 0,
                        text: buttonText(statusList[selectedStatusIndex]),
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        textStyle: boldTextStyle(color: Colors.white, size: 14),
                        color: ColorUtils.colorPrimary,
                        onTap: () {
                          if (statusList[selectedStatusIndex] ==
                              ORDER_ACCEPTED) {
                            onTapData(
                                orderData: data,
                                orderStatus: statusList[selectedStatusIndex]);
                          } else if (statusList[selectedStatusIndex] ==
                              ORDER_ARRIVED) {
                            onTapData(
                                orderData: data,
                                orderStatus: statusList[selectedStatusIndex]);
                          } else if (statusList[selectedStatusIndex] ==
                                  ORDER_DEPARTED ||
                              statusList[selectedStatusIndex] ==
                                  ORDER_PICKED_UP) {
                            int val = 0;
                            return showInDialog(
                              barrierDismissible: true,
                              getContext,
                              builder: (p0) {
                                return StatefulBuilder(
                                    builder: (context, selectedImagesUpdate) {
                                  // This is used to toggle the visibility of the reschedule form

                                  return Form(
                                    key: rescheduleFormKey,
                                    child: SingleChildScrollView(
                                      child: Container(
                                        child: !appStore.isLoading
                                            ? Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // Reschedule button - shows the reschedule form
                                                      commonButton(
                                                          language.reschedule,
                                                          size: 12, () {
                                                        selectedImagesUpdate(
                                                            () {
                                                          val = 1;
                                                          print(
                                                              "$val"); // This will make the reschedule form visible
                                                        });
                                                      }).expand(),

                                                      2.width,

                                                      // Departed button - triggers the API call and hides the form
                                                      commonButton(
                                                        language
                                                            .confirmDelivery,
                                                        size: 12,
                                                        () async {
                                                          if (context.mounted) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                          onTapData(
                                                              orderData: data,
                                                              orderStatus:
                                                                  statusList[
                                                                      selectedStatusIndex]);
                                                        },
                                                      ).expand(),
                                                    ],
                                                  ).visible(val == 0),

                                                  // Reschedule form (only visible when val == 1)
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          language
                                                              .rescheduleTitle,
                                                          style:
                                                              boldTextStyle(),
                                                          textAlign:
                                                              TextAlign.start),
                                                      10.height,
                                                      Divider(
                                                          color: dividerColor,
                                                          height: 1),
                                                      8.height,

                                                      // Reason text field
                                                      Text(language.reason,
                                                          style:
                                                              boldTextStyle()),
                                                      12.height,
                                                      AppTextField(
                                                        isValidationRequired:
                                                            true,
                                                        controller:
                                                            reasonTitleTextEditingController,
                                                        textFieldType:
                                                            TextFieldType.NAME,
                                                        errorThisFieldRequired:
                                                            language
                                                                .fieldRequiredMsg,
                                                        decoration:
                                                            commonInputDecoration(
                                                                hintText:
                                                                    language
                                                                        .reason),
                                                      ),
                                                      8.height,

                                                      // Date picker
                                                      Text(language.date,
                                                          style:
                                                              boldTextStyle()),
                                                      12.height,
                                                      DateTimePicker(
                                                        controller:
                                                            pickDateController,
                                                        type: DateTimePickerType
                                                            .date,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime.now(),
                                                        lastDate: DateTime.now()
                                                            .add(Duration(
                                                                days: 30)),
                                                        onChanged: (value) {
                                                          pickDate =
                                                              DateTime.parse(
                                                                  value);
                                                        },
                                                        validator: (value) {
                                                          if (value!.isEmpty)
                                                            return language
                                                                .fieldRequiredMsg;
                                                          return null;
                                                        },
                                                        decoration:
                                                            commonInputDecoration(
                                                                suffixIcon: Icons
                                                                    .calendar_today,
                                                                hintText:
                                                                    language
                                                                        .date),
                                                      ),

                                                      16.height,

                                                      // Buttons inside the reschedule form
                                                      Row(
                                                        children: [
                                                          commonButton(
                                                              language.cancel,
                                                              size: 14, () {
                                                            finish(getContext,
                                                                0); // Close the dialog
                                                          }).expand(),

                                                          6.width,

                                                          // Reschedule button inside the form
                                                          commonButton(
                                                              language
                                                                  .reschedule,
                                                              size: 14,
                                                              () async {
                                                            if (rescheduleFormKey
                                                                .currentState!
                                                                .validate()) {
                                                              // Trigger the reschedule API call
                                                              // Example API call
                                                              Map request = {
                                                                "order_id":
                                                                    data.id,
                                                                "reason":
                                                                    reasonTitleTextEditingController
                                                                        .text
                                                                        .toString(),
                                                                "date": DateFormat(
                                                                        'yyyy-MM-dd')
                                                                    .format(
                                                                        pickDate!),
                                                              };
                                                              appStore
                                                                  .setLoading(
                                                                      true);
                                                              await rescheduleOrder(
                                                                      request)
                                                                  .then(
                                                                      (value) {
                                                                toast(value
                                                                    .message);
                                                                appStore
                                                                    .setLoading(
                                                                        false);
                                                                finish(context);
                                                              });
                                                            }
                                                          }).expand(),
                                                        ],
                                                      ),
                                                    ],
                                                  ).visible(val == 1),
                                                  // This makes the form visible based on the value of "val"
                                                ],
                                              )
                                            : Observer(
                                                    builder: (context) =>
                                                        loaderWidget().visible(
                                                            appStore.isLoading))
                                                .center(),
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                            //    onTapData(orderData: data, orderStatus: statusList[selectedStatusIndex]);
                          } else {
                            showConfirmDialogCustom(
                              context,
                              primaryColor: ColorUtils.colorPrimary,
                              dialogType: DialogType.CONFIRMATION,
                              title:
                                  orderTitle(statusList[selectedStatusIndex]),
                              positiveText: language.yes,
                              negativeText: language.no,
                              onAccept: (c) async {
                                appStore.setLoading(true);
                                await onTapData(
                                    orderData: data,
                                    orderStatus:
                                        statusList[selectedStatusIndex]);
                                appStore.setLoading(false);
                                // finish(context);
                              },
                            );
                          }
                        },
                      )
                        .visible(statusList[selectedStatusIndex] !=
                                ORDER_DELIVERED &&
                            statusList[selectedStatusIndex] != ORDER_SHIPPED)
                        .paddingOnly(
                            right: appStore.selectedLanguage == "ar" ? 10 : 0)
                    : SizedBox()
              ],
            ),
            8.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.pickupDatetime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.picked,
                          style: secondaryTextStyle(size: 12)),
                      4.height,
                      Text(
                          '${language.at} ${printDateWithoutAt("${data.pickupDatetime!}Z")}',
                          style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                4.height,
                Row(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // -----这里还需要修改，因为把id的int改成了string
                            // OrderDetailScreen(orderId: data.id!).launch(context,
                            //     pageRouteAnimation:
                            //         PageRouteAnimation.SlideBottomTop,
                            //     duration: 400.milliseconds);
                          },
                          child: Row(
                            children: [
                              ImageIcon(AssetImage(ic_from),
                                  size: 24, color: ColorUtils.colorPrimary),
                              12.width,
                              Text('${data.pickupPoint!.address}',
                                      style: primaryTextStyle(size: 14))
                                  .expand(),
                            ],
                          ),
                        ),
                      ],
                    ).expand(),
                    12.width,
                    if (data.pickupPoint!.contactNumber != null)
                      Icon(Ionicons.ios_call_outline,
                              size: 20, color: ColorUtils.colorPrimary)
                          .onTap(() {
                        commonLaunchUrl(
                            'tel:${data.pickupPoint!.contactNumber}');
                      }),
                  ],
                ),
                if (data.pickupDatetime == null &&
                    data.pickupPoint!.endTime != null &&
                    data.pickupPoint!.startTime != null)
                  Row(
                    children: [
                      Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(data.pickupPoint!.endTime!).toLocal())}',
                              style: secondaryTextStyle(
                                  size: 12, color: Colors.red),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)
                          .expand(),
                    ],
                  ),
              ],
            ),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.deliveryDatetime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.delivered,
                          style: secondaryTextStyle(size: 12)),
                      4.height,
                      Text(
                          '${language.at} ${printDateWithoutAt("${data.deliveryDatetime!}Z")}',
                          style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                4.height,
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // -----这里还需要修改，因为把id的int改成了string
                        // OrderDetailScreen(orderId: data.id!).launch(context,
                        //     pageRouteAnimation:
                        //         PageRouteAnimation.SlideBottomTop,
                        //     duration: 400.milliseconds);
                      },
                      child: Row(
                        children: [
                          ImageIcon(AssetImage(ic_to),
                              size: 24, color: ColorUtils.colorPrimary),
                          12.width,
                          Text('${data.deliveryPoint!.address}',
                                  style: primaryTextStyle(size: 14),
                                  textAlign: TextAlign.start)
                              .expand(),
                        ],
                      ),
                    ).expand(),
                    12.width,
                    if (data.deliveryPoint!.contactNumber != null)
                      Icon(Ionicons.ios_call_outline,
                              size: 20, color: ColorUtils.colorPrimary)
                          .onTap(() {
                        commonLaunchUrl(
                            'tel:${data.deliveryPoint!.contactNumber}');
                      }),
                  ],
                ),
                if (data.deliveryDatetime == null &&
                    data.deliveryPoint!.endTime != null &&
                    data.deliveryPoint!.startTime != null)
                  Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(data.deliveryPoint!.endTime!).toLocal())}',
                          style:
                              secondaryTextStyle(color: Colors.red, size: 12))
                      .paddingOnly(top: 4),
                if (data.reScheduleDateTime != null)
                  Text('${language.note} ${language.rescheduleMsg} ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(data.reScheduleDateTime!))} ',
                          style:
                              secondaryTextStyle(color: Colors.red, size: 12))
                      .paddingOnly(top: 4)
              ],
            ),
            Divider(height: 30, thickness: 1, color: context.dividerColor),
            Row(
              children: [
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: ColorUtils.borderColor,
                          width: appStore.isDarkMode ? 0.2 : 1),
                      backgroundColor: context.cardColor),
                  padding: EdgeInsets.all(8),
                  child: Image.asset(parcelTypeIcon(data.parcelType.validate()),
                      height: 24, width: 24, color: Colors.grey),
                ),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(data.parcelType.validate(), style: boldTextStyle()),
                    4.height,
                    Row(
                      children: [
                        data.date != null
                            ? Text(printDate("${data.date}"),
                                    style: secondaryTextStyle())
                                .expand()
                            : SizedBox(),
                        // Text('${printAmount(data.totalAmount ?? 0)}',
                        //     style: boldTextStyle()),
                      ],
                    ),
                  ],
                ).expand(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AppButton(
                    elevation: 0,
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        side: BorderSide(color: ColorUtils.colorPrimary)),
                    child: Text(language.notifyUser,
                        style:
                            primaryTextStyle(color: ColorUtils.colorPrimary)),
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        primaryColor: ColorUtils.colorPrimary,
                        dialogType: DialogType.CONFIRMATION,
                        title: language.areYouSureWantToArrive,
                        positiveText: language.yes,
                        negativeText: language.cancel,
                        onAccept: (c) async {
                          appStore.setLoading(true);
                          // -----这里还需要修改，因为把id的int改成了string
                          // await updateOrder(
                          //         orderStatus: ORDER_ARRIVED, orderId: data.id)
                          //     .then((value) {
                          //   toast(language.orderArrived);
                          // });
                          appStore.setLoading(false);
                          // finish(context);
                          int i = statusList
                              .indexWhere((item) => item == ORDER_ARRIVED);
                          pageController.jumpToPage(i);
                          getOrderListApiCall();
                        },
                      );
                    },
                  ),
                ).paddingOnly(top: 10).visible(data.status == ORDER_ACCEPTED),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        // ------这里还需要，因为把id的int改成了string
        // OrderDetailScreen(orderId: data.id!).launch(context,
        //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
        //     duration: 400.milliseconds);
      },
    );
  }

  Future<void> onTapData(
      {required String orderStatus, required OrderData orderData}) async {
    final routePlanService = RoutePlanService();
    // var enumStatusCode = convertStatusToEnum(orderStatus);
    if (orderStatus == ORDER_ASSIGNED) {
      FlutterRingtonePlayer().stop();
      await routePlanService.addTaskStatus(
        taskId: orderData.id!, // 任务 ID
        statusCode: "PickedUp", // 状态代码
        name: "PickedUp",
        senderMessage: "Your order has been assigned",
        receiverMessage: "The order is now assigned to a delivery person",
        colorHex: "#00FF00",
      );

      // 不进行跳转
      // int i = statusList.indexWhere((item) => item == ORDER_ASSIGNED);
      // pageController.jumpToPage(i + 1);

      getOrderListApiCall();
    } else if (orderStatus == ORDER_ACCEPTED) {
      DateTime startTime = DateTime.parse(orderData.pickupPoint!.startTime!);
      DateTime endTime = DateTime.parse(orderData.pickupPoint!.endTime!);
      DateTime now = DateTime.now();
      // Check if the current time is between start and end times
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        // Allow the api call
        await ReceivedScreenOrderScreen(
                orderData: orderData,
                isShowPayment: orderData.paymentId == null &&
                    orderData.paymentCollectFrom == PAYMENT_ON_PICKUP)
            .launch(context,
                pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
        int i = statusList.indexWhere((item) => item == ORDER_PICKED_UP);
        pageController.jumpToPage(i);
        getOrderListApiCall();
      } else {
        toast(language.earlyPickupMsg);
      }
      // int i = statusList.indexWhere((item) => item == ORDER_PICKED_UP);
      // pageController.jumpToPage(i);
      getOrderListApiCall();
    } else if (orderStatus == ORDER_ARRIVED) {
      bool isCheck = await ReceivedScreenOrderScreen(
              orderData: orderData,
              isShowPayment: orderData.paymentId == null &&
                  orderData.paymentCollectFrom == PAYMENT_ON_PICKUP)
          .launch(context,
              pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

      if (isCheck) {
        getOrderListApiCall();
      }
      int i = statusList.indexWhere((item) => item == ORDER_ARRIVED);
      pageController.jumpToPage(i + 1);
    } else if (orderStatus == ORDER_PICKED_UP) {
      // 不进行跳转
      // int i = statusList.indexWhere((item) => item == ORDER_PICKED_UP);
      // pageController.jumpToPage(i + 1);
      await routePlanService.addTaskStatus(
        taskId: orderData.id!, // 任务 ID
        statusCode: "Delivered", // 状态代码
        name: "Delivered",
        senderMessage: "Your order has been delivered",
        receiverMessage: "The order is now completed",
        colorHex: "#00FF00",
      );

      getOrderListApiCall();
    } else if (orderStatus == ORDER_DEPARTED) {
      DateTime startTime = DateTime.parse(orderData.pickupDatetime!);
      DateTime now = DateTime.now();
      // Check if the current time is between start and end times
      if (now.isAfter(startTime)) {
        await ReceivedScreenOrderScreen(
                orderData: orderData,
                isShowPayment: orderData.paymentId == null &&
                    orderData.paymentCollectFrom == PAYMENT_ON_DELIVERY)
            .launch(context,
                pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
        int i = statusList.indexWhere((item) => item == ORDER_DEPARTED);
        pageController.jumpToPage(i + 1);
        getOrderListApiCall();
      } else {
        //todo add keys
        toast(language.earlyDeliveryMsg);
      }
    }
  }

  buttonText(String orderStatus) {
    if (orderStatus == ORDER_ASSIGNED) {
      return language.pickUp;
    } else if (orderStatus == ORDER_ACCEPTED) {
      return language.pickUp;
    } else if (orderStatus == ORDER_ARRIVED) {
      return language.pickUp;
    } else if (orderStatus == ORDER_PICKED_UP) {
      return language.confirmDelivery;
    } else if (orderStatus == ORDER_DEPARTED) {
      return language.confirmDelivery;
    }
    return '';
  }
}

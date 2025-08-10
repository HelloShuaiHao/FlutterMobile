import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/list_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/animatedList/animated_configurations.dart';
import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../main.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/models.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../components/OrderCardComponent.dart';

class OrderFragment extends StatefulWidget {
  static String tag = '/OrderFragment';

  @override
  OrderFragmentState createState() => OrderFragmentState();
}

class OrderFragmentState extends State<OrderFragment> {
  List<OrderData> orderList = [];
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;
  List storeList = [];

  @override
  void initState() {
    super.initState();
    init();
    LiveStream().on('UpdateOrderData', (p0) {
      page = 1;
      getOrderListApiCall();
      setState(() {});
    });
  }

  Future<void> getOrderData() async {
    await getOrderListApiCall();
  }

  Future<void> init() async {
    getOrderData();

    await getAppSetting().then((value) {
      appStore.setOtpVerifyOnPickupDelivery(value.otpVerifyOnPickupDelivery == 1);
      appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.setSiteEmail(value.siteEmail ?? "");
      appStore.setCopyRight(value.siteCopyright ?? "");
      appStore.isVehicleOrder = value.isVehicleInOrder ?? 0;
      appStore.setDistanceUnit(value.distanceUnit ?? DISTANCE_UNIT_KM);
      appStore.setCopyRight(value.siteCopyright ?? "");
      // appStore.setOrderTrackingIdPrefix(value.orderTrackingIdPrefix ?? "");
      appStore.setIsInsuranceAllowed(value.isInsuranceAllowed ?? "0");
      appStore.setInsurancePercentage(value.insurancePercentage ?? "0");
      appStore.setInsuranceDescription(value.insuranceDescription ?? "");
      appStore.setMaxAmountPerMonth(value.maxEarningsPerMonth ?? '');
      appStore.setClaimDuration(value.claimDuration ?? '');
      if (value.storeType!.validate().isNotEmpty) {
        storeList = value.storeType.validate();
        setState(() {});
        // storeList.add(value.storeManage.validate());
      }
    }).catchError((error) {
      log(error.toString());
    });
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);

    FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));

    await getOrderList(
            page: page,
            orderStatus: filterData.orderStatus,
            fromDate: filterData.fromDate,
            toDate: filterData.toDate,
            excludeStatus: ORDER_DRAFT)
        .then((value) {
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);

      if (value.walletData != null) {
        appStore.availableBal = value.walletData!.totalAmount;
      }

      isLastPage = false;
      if (page == 1) orderList.clear();
      orderList.addAll(value.data!);

      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      toast(e.toString(), print: true);
      print("------------${e.toString()}");
    }).whenComplete(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedListView(
      itemCount: orderList.length,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      listAnimationType: ListAnimationType.Slide,
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
      flipConfiguration: FlipConfiguration(duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
      fadeInConfiguration: FadeInConfiguration(duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn),
      onNextPage: () {
        if (page < totalPage) {
          page++;
          setState(() {});
          getOrderData();
        }
      },
      emptyWidget: Stack(
        children: [
          loaderWidget().visible(appStore.isLoading),
          emptyWidget().visible(!appStore.isLoading),
        ],
      ),
      onSwipeRefresh: () async {
        page = 1;
        getOrderData();
        return Future.value(true);
      },
      itemBuilder: (context, i) {
        OrderData item = orderList[i];
        return item.status != ORDER_DRAFT ? OrderCardComponent(item: item) : SizedBox();
      },
      /*   ),
      ],*/
    );
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/bidding/extensions/extension_util/animation_extensions.dart';
import 'package:mighty_delivery/delivery/screens/TaskListScreen.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/main/network/test_signalR.dart';
import 'package:mighty_delivery/main/screens/LanguageScreen.dart';
import 'package:mighty_delivery/main/services/RoutePlanService.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import '../../bidding/delivery/models/BidOrderModel.dart';
import '../../bidding/delivery/screens/DeliveryBidListScreen.dart';
import '../../bidding/utils/Constants.dart';
import '../../delivery/screens/EarningHistoryScreen.dart';
import '../../delivery/screens/FilterCountScreen.dart';
import '../../delivery/screens/PreDeliveryScanScreen.dart';

import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/num_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/DashboardCountModel.dart';
import '../../user/screens/WalletScreen.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/BankDetailScreen.dart';
import '../../main/screens/UserCitySelectScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../delivery/fragment/DProfileFragment.dart';
import '../../extensions/common.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/utils/dynamic_theme.dart';
import '../screens/DeliveryDashBoard.dart';
import '../screens/WithDrawScreen.dart';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

// 日期格式化工具
final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

// 示例任务数据
final List<TaskItem> exampleTasks = const [
  TaskItem(
    id: '74649349',
    address:
        'CHANGI HYPER BUSINESS PK #2-11 8 8 Changi Business Park Ave 1\nSingapore 486018',
    timeWindow: '8:00 AM — 10:00 AM',
    contactName: 'LinksPoints Test DC Customer',
    modules: [
      Module(name: 'ZBK-B', code: '74649349,ZBK-B-01'),
      Module(name: 'ZGN-A', code: '74649349,ZGN-A-01'),
      Module(name: 'ZGN-W', code: '74649349,ZGN-W-01'),
    ],
  ),
  TaskItem(
    id: '74649427',
    address:
        'CHANGI HYPER BUSINESS PK #8-158 8, 8 Changi Bus\nSingapore 486018',
    timeWindow: '8:00 AM — 10:00 AM',
    contactName: 'LinksPoints Test DC Customer',
    modules: [
      Module(name: 'ZBK-B', code: '74649427,ZBK-B-01'),
      Module(name: 'ZGN-A', code: '74649427,ZGN-A-01'),
    ],
  ),
];

class DHomeFragment extends StatefulWidget {
  @override
  State<DHomeFragment> createState() => _DHomeFragmentState();
}

class _DHomeFragmentState extends State<DHomeFragment>
    with TickerProviderStateMixin {
  int currentPage = 1;
  DashboardCount? countData;

  late AnimationController _animationController;

  late double biddedAmount;
  TextEditingController reasonController = TextEditingController();
  late StreamSubscription _getOrdersWithBidsStream;
  late StreamSubscription _getOrdersWithBidsStreamToCancelBid;

  BidOrderModel? latestOrder;
  BidOrderModel? latestOrderToCancelBid;

  ScrollController scrollController = ScrollController();
  UserBankAccount? userBankAccount;

  List items = [
    TODAY_ORDER,
    REMAINING_ORDER,
    PICKED_UP_ORDER, // 新增 PickedUp tab
    COMPLETED_ORDER,
    INPROGRESS_ORDER,
    // TOTAL_EARNING,
    // WALLET_BALANCE,
    // PENDING_WITHDRAW_REQUEST,
    // COMPLETED_WITHDRAW_REQUEST,
  ];

  List<Color> colorList = [
    Color(0xFFF6D7D3),
    Color(0xFFE5D7D7),
    Color(0xFFE5D1EA),
    Color(0xFFD0E5F6),
    Color(0xFFD9F6D0),
    Color(0xFFF6D3E8),
    Color(0xFFFFDFDA),
    Color(0xFFD9D9F6),
    Color(0xFFE4D2E9),
  ];

  Map<String, int> statusCountMap = {};

  Future<void> fetchTaskCountByStatusName() async {
    final routePlanService = RoutePlanService();
    String vehicleId = SpUtil.getJSON("vehicleId");

    // 从 SharedPreferences 获取保存的日期
    String? savedDateStr = SpUtil.getJSON('selected_date');
    String taskDate =
        savedDateStr ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      appStore.setLoading(true); // 显示加载状态
      statusCountMap = await routePlanService.getTaskCountByStatusName(
        vehicleId: vehicleId,
        taskDate: taskDate, // 传递 TaskDate 参数
      );
      log("Fetched statusCountMap: $statusCountMap"); // 打印数据
      setState(() {});
    } catch (e) {
      print("Error fetching status count: $e");
    } finally {
      appStore.setLoading(false); // 隐藏加载状态
    }
  }

  String getCount(int index) {
    switch (index) {
      case 0:
        // 总和：包括 Assigned、Delivered、Picked Up 等状态
        int total = (statusCountMap['Assigned'] ?? 0) +
            (statusCountMap['Delivered'] ?? 0) +
            (statusCountMap['Picked Up'] ?? 0); // 确保包含 Picked Up
        return total.toString();
      case 1:
        return (statusCountMap['Assigned'] ?? 0).toString();
      case 2:
        return (statusCountMap['Delivered'] ?? 0).toString();
      case 3:
        return (statusCountMap['Picked Up'] ?? 0).toString(); // Picked Up 状态
      case 4:
        return (statusCountMap['Cancelled'] ?? 0).toString();
      default:
        return "0";
    }
  }

  void startShake() {
    _animationController.repeat(reverse: true);
  }

  Future<void> goToCountScreen(int index) async {
    // 根据索引跳转到不同的界面
    switch (index) {
      case 0: // Today Order
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => DeliveryDashBoard(selectedIndex: 0),
          ),
        )
            .then((value) {
          fetchTaskCountByStatusName(); // 刷新任务状态数据
          getDashboardCountDataApi(); // 刷新仪表盘统计数据
          setState(() {}); // 更新界面
        });
        break;

      case 1: // Remaining Order
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => DeliveryDashBoard(selectedIndex: 0),
          ),
        )
            .then((value) {
          fetchTaskCountByStatusName();
          getDashboardCountDataApi();
          setState(() {});
        });
        break;

      case 2: // Picked Up Order
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => DeliveryDashBoard(selectedIndex: 1),
          ),
        )
            .then((value) {
          fetchTaskCountByStatusName();
          getDashboardCountDataApi();
          setState(() {});
        });
        break;

      case 3: // Completed Order
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => DeliveryDashBoard(selectedIndex: 2),
          ),
        )
            .then((value) {
          fetchTaskCountByStatusName();
          getDashboardCountDataApi();
          setState(() {});
        });
        break;

      case 4: // Cancelled Order
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => DeliveryDashBoard(selectedIndex: 3),
          ),
        )
            .then((value) {
          fetchTaskCountByStatusName();
          getDashboardCountDataApi();
          setState(() {});
        });
        break;

      default:
        log("Invalid index: $index");
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTaskCountByStatusName(); // 初始化时获取 count

    print("当前进入 的页面是：${DHomeFragment()}");

    // Listen for language updates: When a LiveStream message for 'UpdateLanguage' is received,
    // the UI is rebuilt.
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });

    // Listen for theme updates: When a LiveStream message for 'UpdateTheme' is received,
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });

    // Create an animation controller for shake animation with a 1-second duration.
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Start the repeated shake animation.
    startShake();

    // Initialize application settings (such as currency settings) by calling init().
    init();

    // Fetch dashboard count data (loads statistics for dashboard widgets) by calling getDashboardCountDataApi().
    getDashboardCountDataApi();

    // Set up Firestore stream listeners to monitor bid-related order changes.
    listenToOrderWithBidsStream();
    listenToOrderWithBidsStreamToCancelBid();

    // 在这里调用 testSignalR() 进行 SignalR 连接测试
    testSignalR();

    // 获取不同状态的task的数量
    fetchTaskCountByStatusName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTaskCountByStatusName(); // 每次依赖发生变化时刷新 count
  }

  Future<void> init() async {
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(value.currency ?? CURRENCY_SYMBOL);
      appStore.setCopyRight(value.siteCopyright ?? "");
      appStore.setSiteEmail(value.siteEmail ?? "");
      appStore.setDistanceUnit(value.distanceUnit ?? DISTANCE_UNIT_KM);
      appStore.setIsInsuranceAllowed(value.isInsuranceAllowed ?? "0");
      appStore.setInsurancePercentage(value.insurancePercentage ?? "0");
      appStore.setCurrencyPosition(
          value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.setInsuranceDescription(value.insuranceDescription ?? '');
      appStore.setMaxAmountPerMonth(value.maxEarningsPerMonth ?? '');
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> getDashboardCountDataApi(
      {String? startDate, String? endDate}) async {
    appStore.setLoading(true);
    await getDashboardCount(startDate: startDate, endDate: endDate)
        .then((value) {
      appStore.setLoading(false);
      countData = value;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  getBankDetail() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      appStore.setLoading(false);
      userBankAccount = value.userBankAccount;
    }).then((value) {
      log(value.toString());
    });
  }

  @override
  void dispose() {
    _getOrdersWithBidsStream.cancel();
    _getOrdersWithBidsStreamToCancelBid.cancel();
    reasonController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget bidAcceptView({required BidOrderModel? order}) {
    if (order == null) return SizedBox();
    return InkWell(
      onTap: () {
        DeliveryBidListScreen().launch(context);
      },
      child: Container(
        width: context.width(),
        decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            backgroundColor: darkRed),
        child: Text("${language.orderAvailableForBidding}".capitalizedByWord(),
                style: boldTextStyle(size: 16, color: Colors.white))
            .paddingAll(16),
      )
          .visible(latestOrder != null || latestOrderToCancelBid != null)
          .withShakeAnimation(_animationController),
    );
  }

  Widget bidCancelView({required BidOrderModel? order}) {
    if (order == null) return SizedBox();
    return InkWell(
        onTap: () {
          DeliveryBidListScreen().launch(context);
        },
        child: Container(
          width: context.width(),
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              backgroundColor: darkRed),
          child: Text("${language.bidAvailableForCancel}".capitalizedByWord(),
                  style: boldTextStyle(size: 16, color: Colors.white))
              .paddingAll(16),
        )
            .visible(latestOrder != null || latestOrderToCancelBid != null)
            .withShakeAnimation(_animationController));
  }

  listenToOrderWithBidsStream() {
    _getOrdersWithBidsStream = FirebaseFirestore.instance
        .collection(ORDERS_BID_COLLECTION)
        .where(ALL_DELIVERY_MAN_IDS, arrayContains: getIntAsync(USER_ID))
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          latestOrder = null;
          setState(() {});
        } else {
          try {
            List<BidOrderModel> data = snapshot.docs
                .map((e) => BidOrderModel.fromJson(e.data()))
                .toList();

            if (data.isNotEmpty) {
              latestOrder = data[0];
            }
          } catch (e) {
            log("ERROR::: $e");
          }
        }
      },
      onError: (error) {
        log("ERROR::: $error");
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

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: commonAppBarWidget(
        '${language.hey} ${getStringAsync(NAME)} 👋',
        showBack: false,
        actions: [
          // 城市选择按钮
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(defaultRadius),
                backgroundColor: Colors.white24),
            child: Row(children: [
              // 'assets/icon/ic_languages.png'
              Image.asset(
                'assets/icon/ic_languages.png',
                height: 18,
                width: 18,
                color: Colors.white, // 如果需要颜色覆盖
              ),
            ]).onTap(() {
              LanguageScreen().launch(context,
                  pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
            },
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent),
          ),

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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getDashboardCountDataApi();
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: [
                  9.height,
                  // 添加扫描 area
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: const Color.fromARGB(255, 203, 248, 248),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Scanning Area",
                          style: boldTextStyle(size: 16, color: Colors.black),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // 扫描逻辑
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PreDeliveryScanScreen(
                                  tasks: exampleTasks,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtils.colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Scan",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  1.height,
                  latestOrderToCancelBid != null
                      ? bidCancelView(order: latestOrderToCancelBid ?? null)
                      : bidAcceptView(order: latestOrder ?? null),
                  16.height,
                  Row(
                    // 过滤日期按钮
                    children: [
                      Text(
                        language.filterBelowCount,
                        style: boldTextStyle(
                            size: 16, color: ColorUtils.colorPrimary),
                      ),
                      Spacer(),
                      Icon(
                        Icons.filter_list,
                        color: ColorUtils.colorPrimary,
                      ).onTap(() {
                        String? savedDateStr = SpUtil.getJSON('selected_date');
                        DateTime initialDate;
                        if (savedDateStr != null && savedDateStr.isNotEmpty) {
                          initialDate = dateFormat.parse(savedDateStr);
                        } else {
                          initialDate = DateTime.now();
                        }

                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime(2020, 1, 1),
                          maxTime: DateTime(2100, 12, 31),
                          currentTime: initialDate,
                          locale: LocaleType.en,
                          onConfirm: (picked) {
                            String formatted = dateFormat.format(picked);
                            SpUtil.setJSON('selected_date', formatted);

                            // 显示加载状态并刷新数据
                            fetchTaskCountByStatusName();

                            setState(() {});
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Date Selected'),
                                content: Text(
                                  formatted,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ).paddingSymmetric(horizontal: 10),
                  8.height,
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.45,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    cacheExtent: 2.0,
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(7, 5, 7, 5),
                    itemBuilder: (context, index) {
                      // log("GETCOUNT::: ${getCount(index)}");
                      return countWidget(
                              text: items[index],
                              value: getCount(index),
                              color: colorList[index])
                          .onTap(() {
                        goToCountScreen(index);
                      });
                    },
                    itemCount: items.length,
                  ),
                ],
              ),
            ),
            Observer(
              builder: (context) => Positioned.fill(
                child: loaderWidget().visible(appStore.isLoading),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: boxDecorationWithRoundedCorners(
              backgroundColor: ColorUtils.colorPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(language.viewAllOrders,
                  style: boldTextStyle(color: Colors.white)),
            ],
          ).onTap(() {
            DeliveryDashBoard().launch(context).then((value) {
              setState(() {});
              getDashboardCountDataApi();
            });

            // 修改跳转逻辑为 TaskListScreen
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => PreDeliveryScanScreen(tasks: exampleTasks),
            //   ),
            // );
          }),
        ),
      ),
    );
  }

  Widget countWidget({
    required String text,
    required String value,
    required Color color,
  }) {
    // Color color =
    return Container(
      decoration: appStore.isDarkMode
          ? boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              backgroundColor: color)
          : boxDecorationRoundedWithShadow(defaultRadius.toInt(),
              backgroundColor: color),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: boldTextStyle(size: 27, color: textPrimaryColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          4.height,
          Text(
            countName(text),
            style: primaryTextStyle(size: 13, color: textPrimaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

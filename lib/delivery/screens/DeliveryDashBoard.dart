import 'package:gallery_saver/gallery_saver.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/delivery/screens/EPODScreen.dart';

import 'package:mighty_delivery/main/models/GroupedOrderData.dart';
import 'package:mighty_delivery/main/services/LocationTrackingService.dart';

import 'package:mighty_delivery/main/services/RoutePlanService.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../delivery/screens/OrdersMapScreen.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

import '../../delivery/fragment/DProfileFragment.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/app_button.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/horizontal_list.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/network/http_utils.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import 'ReceivedScreenOrderScreen.dart';

// background geolocation

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
    ORDER_CANCELLED
  ];
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();
  PageController pageController = PageController();
  int currentPage = 1;
  int totalPage = 1;
  int selectedStatusIndex = 0;
  List<OrderData> orderData = [];
  List<Map<String, dynamic>> rawOrderItems = [];
  List<GroupedOrderData> groupedOrderDataList = []; // 分组数据

  // ===== Cancellation reason support =====
  // Stores per-item cancellation reasons when user unchecks an item
  final Map<String, String> _itemCancelReasons = {};
  // Dropdown preset options
  final List<String> _cancelReasonOptions = const [
    'Customer cancelled',
    'Damaged item',
    'Out of stock',
    'Wrong item prepared',
    'Address issue',
    'Other',
  ];

  // Build item remarks list (only unchecked items with a reason)
  List<Map<String, dynamic>> _buildItemRemarks(OrderData order) {
    final remarks = <Map<String, dynamic>>[];
    final items = order.taskItems ?? [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final itemId = item['id']?.toString();
      if (itemId == null || itemId.isEmpty) continue;
      final isSelected = (i < order.itemSelected.length)
          ? order.itemSelected[i]
          : true; // default selected
      if (!isSelected) {
        final reason = _itemCancelReasons[itemId];
        if (reason != null && reason.trim().isNotEmpty) {
          remarks.add({'itemId': itemId, 'remark': reason.trim()});
        }
      }
    }
    return remarks;
  }

  Future<String?> _promptCancelReason(String itemName) async {
    String current = _cancelReasonOptions.first;
    final TextEditingController customCtl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: const Text('Cancellation Reason'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Item: $itemName',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: current,
                    decoration:
                        const InputDecoration(labelText: 'Select reason'),
                    items: _cancelReasonOptions
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setLocal(() => current = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customCtl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Custom reason *',
                      hintText: 'Please provide detailed reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* Required field',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final customReason = customCtl.text.trim();

                    // 检查自定义原因是否为空
                    if (customReason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a detailed reason'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // 组合最终原因
                    String finalReason;
                    if (current == 'Other') {
                      finalReason = customReason;
                    } else {
                      finalReason = '$current - $customReason';
                    }

                    Navigator.pop(ctx, finalReason);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // List<NewOrderData> orderData = []; // change type to var
  GlobalKey<FormState> rescheduleFormKey = GlobalKey<FormState>();
  TextEditingController reasonTitleTextEditingController =
      TextEditingController();
  TextEditingController dateTextEditingController = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  DateTime? pickDate;

  Color getTaskItemStatusColor(String? status) {
    final code = status?.toLowerCase() ?? '';
    if (code == 'inprogress') {
      return Colors.lightBlueAccent;
    } else if (code == 'unpicked' || code == 'unpickedup') {
      return Colors.red;
    } else if (code == 'completed') {
      return Colors.green;
    }
    return ColorUtils.colorPrimary;
  }

  // 合并相同的物品并计数
  List<Map<String, dynamic>> _mergeAndCountItems(List<dynamic>? taskItems) {
    if (taskItems == null || taskItems.isEmpty) return [];

    final Map<String, Map<String, dynamic>> itemMap = {};

    for (var item in taskItems) {
      final itemName = item['name']?.toString() ?? 'Unknown Item';
      final itemId = item['id']?.toString() ?? '';

      if (itemMap.containsKey(itemName)) {
        // 相同名称的物品，增加数量
        itemMap[itemName]!['count'] = (itemMap[itemName]!['count'] as int) + 1;
        // 保存所有相同物品的ID和索引
        (itemMap[itemName]!['indices'] as List<int>)
            .add(taskItems.indexOf(item));
        (itemMap[itemName]!['ids'] as List<String>).add(itemId);
      } else {
        // 新物品
        itemMap[itemName] = {
          'name': itemName,
          'count': 1,
          'item': item, // 保存第一个物品的完整信息
          'indices': [taskItems.indexOf(item)], // 保存所有索引
          'ids': [itemId], // 保存所有ID
        };
      }
    }

    return itemMap.values.toList();
  }

  // 检查合并后的物品是否全部选中
  bool _isGroupSelected(OrderData data, List<int> indices) {
    return indices.every((index) =>
        index < data.itemSelected.length && data.itemSelected[index]);
  }

  // 检查合并后的物品是否部分选中
  bool _isGroupPartiallySelected(OrderData data, List<int> indices) {
    final selectedCount = indices
        .where((index) =>
            index < data.itemSelected.length && data.itemSelected[index])
        .length;
    return selectedCount > 0 && selectedCount < indices.length;
  }

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
    // afterBuildCreated(() => appStore.setLoading(true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // onResumed();
        break;
      default:
    }
  }

  getOrderListApiCall() async {
    print("getOrderListApiCall invoked");
    print("vehicleId: ${SpUtil.getJSON("vehicleId")}");

    try {
      appStore.setLoading(true);

      // 获取当前选中的状态
      String selectedStatus = statusList[selectedStatusIndex];
      String enumStatus = convertStatusToEnum(selectedStatus); // 转换为枚举字符串
      int statusCode = convertStatusToInt(enumStatus); // 将枚举字符串转换为整数

      // 读取本地选中的日期（没有则用今天）
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dynamic saved = SpUtil.getJSON('selected_date');
      final String taskDate = (saved != null && saved.toString().isNotEmpty)
          ? saved.toString()
          : today;

      // 调用 RoutePlanService 获取数据（带 TaskDate）
      final routePlanService = RoutePlanService();
      final response =
          await routePlanService.getRoutePlansByVehicleIdAndStatusCode(
        vehicleId: SpUtil.getJSON("vehicleId"),
        statusCode: statusCode,
        taskDate: taskDate, // 新增
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

      final items = transformedResponse['items'];
      if (items != null && items is List) {
        rawOrderItems = items.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        rawOrderItems = [];
      }

      // 更新分页、排序、分组
      currentPage = orderListModel.pagination?.currentPage ?? 1;
      totalPage = orderListModel.pagination?.totalPages ?? 1;

      orderData
        ..clear()
        ..addAll(orderListModel.data ?? []);

      // 初始化 itemSelected
      for (var order in orderData) {
        order.itemSelected = List.generate(
          order.taskItems?.length ?? 0,
          (index) {
            final item = order.taskItems![index];
            final statusCode = item['itemStatusCode']?.toString();
            print("Task Item Status Code: $statusCode"); // 调试输出
            return statusCode == 'InProgress'; // 默认选中 InProgress 状态
          },
        );
      }

      if (statusCode == 1) {
        orderData.sort((a, b) => (a.pickupPoint?.taskSequence ?? 0)
            .compareTo(b.pickupPoint?.taskSequence ?? 0));
      } else if (statusCode == 3) {
        orderData.sort((a, b) => (a.deliveryPoint?.taskSequence ?? 0)
            .compareTo(b.deliveryPoint?.taskSequence ?? 0));
      }

      groupOrderData();
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
      case TEST_A:
        return "Test A"; // TEST_A 映射到 SelfDefined
      case TEST_B:
        return "Test B"; // TEST_A 映射到 SelfDefined
      default:
        throw Exception("Unknown status: $status");
    }
  }

  int convertStatusToInt(String status) {
    switch (status) {
      case 'Draft':
        return 0;
      case 'Assigned' || 'Test A':
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

  void groupOrderData() async {
    // 只在 Assigned 状态下分组
    if (statusList[selectedStatusIndex] == ORDER_ASSIGNED) {
      Map<String, List<OrderData>> groupedOrders = {};
      for (var order in orderData) {
        String? address = order.pickupPoint?.address;
        if (address == null) continue;
        if (!groupedOrders.containsKey(address)) {
          groupedOrders[address] = [];
        }
        groupedOrders[address]!.add(order);
      }
      groupedOrderDataList = groupedOrders.entries.map((entry) {
        return GroupedOrderData(
          deliveryOrderId: entry.key, // 这里就是 address
          orders: entry.value,
        );
      }).toList();
    } else {
      // 其它状态不分组
      groupedOrderDataList = [
        GroupedOrderData(
          deliveryOrderId: null,
          orders: orderData,
        )
      ];
    }
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
                      .onTap(() async {
                    currentPage = 1;
                    selectedStatusIndex = statusList
                        .indexWhere((item) => item == statusList[index]);

                    pageController.jumpToPage(selectedStatusIndex);
                    appStore.setLoading(true); // 显示加载
                    await getOrderListApiCall();
                    appStore.setLoading(false);

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
                    if (appStore.isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (statusList[selectedStatusIndex] == ORDER_ASSIGNED)
                      // Assigned：有数据展示分组；没数据展示空态
                      (groupedOrderDataList.isEmpty
                          ? Center(child: Text('No tasks for this date'))
                          : SingleChildScrollView(
                              child: ExpansionPanelList(
                                expansionCallback:
                                    (int index, bool isExpanded) {
                                  setState(() {
                                    groupedOrderDataList[index].isExpanded =
                                        !groupedOrderDataList[index].isExpanded;
                                  });
                                },
                                children: groupedOrderDataList.map((group) {
                                  return ExpansionPanel(
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
                                      return GestureDetector(
                                        onLongPress: () {
                                          // 长按事件：弹出对话框显示物品聚合（合并同名）
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // 获取当前地点下所有订单的物品
                                              final allTaskItems = group.orders!
                                                  .expand(
                                                      (o) => o.taskItems ?? [])
                                                  .toList();

                                              // 按名称分组统计数量
                                              final Map<String, int>
                                                  nameCountMap = {};
                                              for (var taskItem
                                                  in allTaskItems) {
                                                final itemName =
                                                    taskItem['name']
                                                            ?.toString() ??
                                                        'Unknown Item';
                                                nameCountMap[itemName] =
                                                    (nameCountMap[itemName] ??
                                                            0) +
                                                        1;
                                              }

                                              // 排序
                                              final sortedEntries =
                                                  nameCountMap.entries.toList()
                                                    ..sort((a, b) =>
                                                        a.key.compareTo(b.key));

                                              return AlertDialog(
                                                title: Text(
                                                  "Item List",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                content: Container(
                                                  width: double.maxFinite,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: sortedEntries
                                                          .map((entry) {
                                                        final itemName =
                                                            entry.key;
                                                        final count =
                                                            entry.value;
                                                        return Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 6),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade100,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 1,
                                                                blurRadius: 3,
                                                                offset: Offset(
                                                                    0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .inventory_2_outlined,
                                                                color:
                                                                    Colors.blue,
                                                                size: 24,
                                                              ),
                                                              SizedBox(
                                                                  width: 12),
                                                              Expanded(
                                                                child: Text(
                                                                  itemName,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                              // 数量列
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            6),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: count >
                                                                          1
                                                                      ? ColorUtils
                                                                          .colorPrimary
                                                                          .withOpacity(
                                                                              0.15)
                                                                      : Colors
                                                                          .grey
                                                                          .shade200,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  border: count >
                                                                          1
                                                                      ? Border.all(
                                                                          color: ColorUtils.colorPrimary.withOpacity(
                                                                              0.5),
                                                                          width:
                                                                              1.5)
                                                                      : null,
                                                                ),
                                                                child: Text(
                                                                  '$count',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight: count >
                                                                            1
                                                                        ? FontWeight
                                                                            .bold
                                                                        : FontWeight
                                                                            .normal,
                                                                    color: count >
                                                                            1
                                                                        ? ColorUtils
                                                                            .colorPrimary
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: Text(
                                                      "Close",
                                                      style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "🏚️: ${group.deliveryOrderId ?? 'Unknown Address'}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              // Pickup All 按钮
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  showConfirmDialogCustom(
                                                    context,
                                                    primaryColor:
                                                        ColorUtils.colorPrimary,
                                                    dialogType:
                                                        DialogType.CONFIRMATION,
                                                    title:
                                                        'Pickup All Orders at This Address?',
                                                    subTitle:
                                                        'This will pickup all ${group.orders!.length} orders at ${group.deliveryOrderId ?? 'this address'}.',
                                                    positiveText: language.yes,
                                                    negativeText: language.no,
                                                    onAccept: (c) async {
                                                      await _pickupGroupOrders(
                                                          group);
                                                    },
                                                  );
                                                },
                                                icon: Icon(Icons.done_all,
                                                    size: 18,
                                                    color: Colors.white),
                                                label: Text('Pickup All',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      ColorUtils.colorPrimary,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  minimumSize: Size(0, 0),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    body: Column(
                                      children: group.orders!.map((order) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: orderCard(order),
                                        );
                                      }).toList(),
                                    ),
                                    isExpanded: group.isExpanded,
                                  );
                                }).toList(),
                              ),
                            ))
                    else
                      // 其他 tab：空列表也给空态
                      (orderData.isEmpty
                          ? Center(child: Text('No tasks'))
                          : SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: Column(
                                  children: orderData
                                      .map((order) => Container(
                                            margin: EdgeInsets.only(bottom: 16),
                                            child: orderCard(order),
                                          ))
                                      .toList(),
                                ),
                              ),
                            )),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
      // 用 Stack 包裹 floatingActionButton
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(borderRadius: radius(40)),
              backgroundColor: appStore.availableBal >= 0
                  ? ColorUtils.colorPrimary
                  : textSecondaryColorGlobal,
              child: Icon(Icons.pin_drop_outlined, color: Colors.white),
              onPressed: () {
                OrdersMapScreen().launch(context);
              },
            ).paddingAll(18),
          ),
        ],
      ),
    );
  }

  Widget orderCard(OrderData data) {
    if (data.itemSelected.length != (data.taskItems?.length ?? 0)) {
      data.itemSelected = List.generate(
        data.taskItems?.length ?? 0,
        (index) {
          final item = data.taskItems![index];
          final statusCode = item['itemStatusCode']?.toString();
          print("Item Status Code: $statusCode"); // 调试输出
          return statusCode == 'InProgress'; // 确保匹配字符串
        },
      );
      print("Item Selected After: ${data.itemSelected}"); // 调试输出
    }
    bool allSelected =
        data.itemSelected.isNotEmpty && data.itemSelected.every((e) => e);
    bool partiallySelected = data.itemSelected.any((e) => e) && !allSelected;

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
              crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
              children: [
                // order-id
                Text(
                  '${data.orderTrackingId}',
                  style:
                      boldTextStyle(size: 20, color: ColorUtils.colorPrimary),
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
                    .onTap(() async {
                      // 使用当前真实位置作为起点
                      await _launchNavigation(data: data);
                    })
                    .paddingSymmetric(horizontal: 5)
                    .visible(data.status != ORDER_DELIVERED &&
                        data.status != ORDER_CANCELLED &&
                        data.status != ORDER_SHIPPED)
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
                        onTap: () async {
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
                            appStore.setLoading(true); // 显示 loading
                            final epodResult = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EPODScreen(),
                              ),
                            );
                            appStore.setLoading(false); // 隐藏 loading

                            if (epodResult != null) {
                              print('拍照路径: ${epodResult['photoPath']}');
                              print('签名数据: ${epodResult['signature']}');

                              // 保存到相册
                              await GallerySaver.saveImage(
                                  epodResult['photoPath']);

                              // 上传到服务器
                              appStore.setLoading(true);
                              final uploadSuccess = await _uploadProofOfDelivery(
                                taskHeaderId: data.id ?? '',
                                photoPath: epodResult['photoPath'],
                                signatureBytes: epodResult['signature'],
                                notes: '测试上传',
                              );

                              if (uploadSuccess) {
                                // 上传成功后更新订单状态
                                await onTapData(
                                  orderData: data,
                                  orderStatus: statusList[selectedStatusIndex],
                                );
                                appStore.setLoading(false);
                                toast('配送确认成功');
                              } else {
                                appStore.setLoading(false);
                                toast('上传失败，请重试');
                              }
                            } else {
                              toast('需要完成拍照和签名才能确认配送');
                            }
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
                // 只在 Assigned 状态显示 pickup address
                if (data.status == ORDER_ASSIGNED)
                  Row(
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
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

                // 只在 Picked up 状态显示 delivery address
                if (data.status == ORDER_PICKED_UP)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
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
                      onTap: () {},
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
            Divider(height: 5, thickness: 1, color: context.dividerColor),
            if ((data.taskItems?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4), // 减小上下间距
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 全选行
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Expanded(child: SizedBox()),
                        Checkbox(
                          visualDensity: VisualDensity.compact, // 紧凑
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: allSelected,
                          tristate: true,
                          onChanged: (val) {
                            setState(() {
                              bool selectAll =
                                  !(allSelected || partiallySelected);
                              for (int i = 0;
                                  i < data.itemSelected.length;
                                  i++) {
                                data.itemSelected[i] = selectAll;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    // item行 - 合并相同物品并显示数量
                    ...(() {
                      final mergedItems = _mergeAndCountItems(data.taskItems);
                      return mergedItems.map((mergedItem) {
                        final itemName = mergedItem['name'] as String;
                        final itemCount = mergedItem['count'] as int;
                        final item = mergedItem['item'] as Map<String, dynamic>;
                        final indices = mergedItem['indices'] as List<int>;
                        final ids = mergedItem['ids'] as List<String>;

                        final isGroupSelected = _isGroupSelected(data, indices);
                        final isGroupPartial =
                            _isGroupPartiallySelected(data, indices);

                        // 检查是否有取消原因
                        final cancelReasons = ids
                            .where((id) => _itemCancelReasons.containsKey(id))
                            .map((id) => _itemCancelReasons[id])
                            .toSet()
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 图标
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: ColorUtils.borderColor,
                                        width: appStore.isDarkMode ? 0.2 : 1),
                                    backgroundColor: context.cardColor),
                                padding: EdgeInsets.all(4),
                                child: Image.asset(
                                  parcelTypeIcon(data.parcelType.validate()),
                                  height: 24,
                                  width: 24,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 8),
                              // 物品名称（左侧，可扩展）
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    if (item['itemStatusCode'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: getTaskItemStatusColor(
                                                    item['itemStatusCode']
                                                        ?.toString())),
                                            color: getTaskItemStatusColor(
                                                    item['itemStatusCode']
                                                        ?.toString())
                                                .withOpacity(0.1),
                                          ),
                                          child: Text(
                                            '${item['itemStatusCode']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: getTaskItemStatusColor(
                                                  item['itemStatusCode']
                                                      ?.toString()),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (cancelReasons.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: cancelReasons.map((reason) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.info_outline,
                                                      size: 14,
                                                      color: Colors.orange),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      reason ?? 'Cancelled',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.orange),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              // 数量（右侧，固定宽度，与checkbox对齐）
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  'x$itemCount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorUtils.colorPrimary,
                                  ),
                                ),
                              ),
                              // Checkbox（右侧）
                              Checkbox(
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: isGroupSelected,
                                tristate: isGroupPartial,
                                onChanged: (val) async {
                                  if (val == null) return;

                                  if (val == false) {
                                    // 取消选中整组
                                    final reason =
                                        await _promptCancelReason(itemName);
                                    if (reason == null) {
                                      setState(() {});
                                      return;
                                    }
                                    setState(() {
                                      for (int i = 0; i < indices.length; i++) {
                                        final index = indices[i];
                                        data.itemSelected[index] = false;
                                        if (ids[i].isNotEmpty) {
                                          _itemCancelReasons[ids[i]] = reason;
                                        }
                                      }
                                    });
                                  } else {
                                    // 选中整组
                                    setState(() {
                                      for (int i = 0; i < indices.length; i++) {
                                        final index = indices[i];
                                        data.itemSelected[index] = true;
                                        if (ids[i].isNotEmpty) {
                                          _itemCancelReasons.remove(ids[i]);
                                        }
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    })(),
                  ],
                ),
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

  // Pickup all orders in a specific address group
  Future<void> _pickupGroupOrders(GroupedOrderData group) async {
    try {
      appStore.setLoading(true);

      int successCount = 0;
      int failCount = 0;

      for (var order in group.orders ?? []) {
        try {
          // 获取选中的 itemIds（所有 InProgress 状态的）
          final selectedIds = [
            for (int i = 0; i < order.itemSelected.length; i++)
              if (order.itemSelected[i])
                order.taskItems?[i]['id']?.toString() ?? ''
          ]..removeWhere((id) => id.isEmpty);

          final itemRemarks = _buildItemRemarks(order);

          final routePlanService = RoutePlanService();
          await routePlanService.addTaskStatus(
            taskId: order.id!,
            statusCode: "PickedUp",
            name: "PickedUp",
            senderMessage: "Your order has been assigned",
            receiverMessage: "The order is now assigned to a delivery person",
            colorHex: "#00FF00",
            itemIds: selectedIds,
            itemRemarks: itemRemarks,
          );

          successCount++;
        } catch (e) {
          print('Failed to pickup order ${order.id}: $e');
          failCount++;
        }
      }

      appStore.setLoading(false);

      if (successCount > 0) {
        toast(
            'Successfully picked up $successCount order${successCount > 1 ? 's' : ''} at ${group.deliveryOrderId ?? 'this address'}${failCount > 0 ? ', $failCount failed' : ''}');
        await getOrderListApiCall();
      } else {
        toast('Failed to pickup orders');
      }
    } catch (e) {
      appStore.setLoading(false);
      toast('Error: ${e.toString()}');
    }
  }

  Future<void> onTapData(
      {required String orderStatus, required OrderData orderData}) async {
    final routePlanService = RoutePlanService();
    // var enumStatusCode = convertStatusToEnum(orderStatus);
    if (orderStatus == ORDER_ASSIGNED) {
      FlutterRingtonePlayer().stop();
      final selectedIds = [
        for (int i = 0; i < orderData.itemSelected.length; i++)
          if (orderData.itemSelected[i])
            orderData.taskItems?[i]['id']?.toString() ?? ''
      ]..removeWhere((id) => id.isEmpty);

      final itemRemarks = _buildItemRemarks(orderData);

      await routePlanService.addTaskStatus(
        taskId: orderData.id!,
        statusCode: "PickedUp",
        name: "PickedUp",
        senderMessage: "Your order has been assigned",
        receiverMessage: "The order is now assigned to a delivery person",
        colorHex: "#00FF00",
        itemIds: selectedIds,
        itemRemarks: itemRemarks,
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
      // 获取选中的 itemIds
      final selectedItemIds = [
        for (int i = 0; i < orderData.itemSelected.length; i++)
          if (orderData.itemSelected[i])
            orderData.taskItems?[i]['id']?.toString() ?? ''
      ]..removeWhere((id) => id.isEmpty);
      final itemRemarks = _buildItemRemarks(orderData);

      await routePlanService.addTaskStatus(
        taskId: orderData.id!,
        statusCode: "Delivered",
        name: "Delivered",
        senderMessage: "Your order has been delivered",
        receiverMessage: "The order is now completed",
        colorHex: "#00FF00",
        itemIds: selectedItemIds,
        itemRemarks: itemRemarks,
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

  Future<bool> _uploadProofOfDelivery({
    required String taskHeaderId,
    required String photoPath,
    required Uint8List signatureBytes,
    String notes = '',
    String photoType = '1',
    String photoDescription = '现场照片',
  }) async {
    try {
      // 1. 将签名保存为临时文件
      final tempDir = await getTemporaryDirectory();
      final signatureFile = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await signatureFile.writeAsBytes(signatureBytes);

      // 2. 创建 FormData
      FormData formData = FormData.fromMap({
        'TaskHeaderId': taskHeaderId,
        'SignatureFile': await MultipartFile.fromFile(
          signatureFile.path,
          filename: 'signature.png',
        ),
        'Notes': notes,
        'Photos[0].PhotoFile': await MultipartFile.fromFile(
          photoPath,
          filename: 'photo.jpg',
        ),
        'Photos[0].PhotoType': photoType,
        'Photos[0].Description': photoDescription,
      });

      // 3. 调用上传 API
      final response = await HttpUtils.uploadMultipart(
        '/api/delivery/proof-of-delivery/upload',
        formData: formData,
        loadingDialog: false,
        showErrorTip: true,
      );

      // 4. 清理临时签名文件
      try {
        await signatureFile.delete();
      } catch (_) {}

      if (response.code == 0) {
        print('Proof of delivery uploaded successfully');
        return true;
      } else {
        print('Upload failed: ${response.msg}');
        return false;
      }
    } catch (e) {
      print('Error uploading proof of delivery: $e');
      return false;
    }
  }

  Future<({double lat, double lng})?> _getCurrentLatLng() async {
    // 优先后台定位服务
    final last = LocationTrackingService.instance.lastLocation;
    if (last != null) {
      return (lat: last.coords.latitude, lng: last.coords.longitude);
    }
    try {
      // 兜底直接用 Geolocator (已 import geolocator.dart)
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      print('Current location fetch error: $e');
      return null;
    }
  }

  String _buildNavigationUrl({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return 'https://www.google.com/maps/dir/?api=1'
        '&origin=$originLat,$originLng'
        '&destination=$destLat,$destLng'
        '&travelmode=driving';
  }

  Future<void> _launchNavigation({
    required OrderData data,
  }) async {
    final current = await _getCurrentLatLng();
    if (current == null) {
      toast('当前位置不可用，请稍后再试');
      return;
    }

    // 判定目标点
    double destLat;
    double destLng;

    if (data.status == ORDER_ASSIGNED) {
      destLat = double.parse(data.pickupPoint!.latitude.validate());
      destLng = double.parse(data.pickupPoint!.longitude.validate());
    } else {
      // PickedUp / Departed 等去送货地址
      destLat = double.parse(data.deliveryPoint!.latitude.validate());
      destLng = double.parse(data.deliveryPoint!.longitude.validate());
    }

    final url = _buildNavigationUrl(
      originLat: current.lat,
      originLng: current.lng,
      destLat: destLat,
      destLng: destLng,
    );

    print('NAV URL: $url');
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toast('无法打开导航应用');
    }
  }
}

// 现象描述：可以发现，我在LoginScreen第137行 LocationTrackingService.instance.startTracking(); 调用了这个单例服务的startTracking方法，
// 也就意味着 每次登录成功都会启动定位服务，
// 但是通过测试发现，每次swipe掉app再重新打开后，定位服务就停止了，无法自动恢复。
// 另外 最好就算swipe掉app后 还能继续定位上传，毕竟后台定位服务的意义就在于此。

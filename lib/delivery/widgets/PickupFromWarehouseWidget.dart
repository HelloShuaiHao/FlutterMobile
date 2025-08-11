import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/models/OrderListModel.dart';
import 'WarehouseOrderGroupWidget.dart';

// 数据结构
class WarehouseOrderGroup {
  final String code;
  final String customer;
  final List<OrderModel> orders;
  WarehouseOrderGroup({
    required this.code,
    required this.customer,
    required this.orders,
  });
}

class OrderModel {
  final String orderNo;
  final List<ItemModel> items;
  bool selected;
  OrderModel({
    required this.orderNo,
    required this.items,
    this.selected = false,
  });
}

class ItemModel {
  final String name;
  final String size;
  final String weight;
  bool selected;
  ItemModel({
    required this.name,
    required this.size,
    required this.weight,
    this.selected = false,
  });
}

class PickupFromWarehouseWidget extends StatefulWidget {
  final List<OrderData> data; // 改为接收 OrderData

  const PickupFromWarehouseWidget({Key? key, required this.data})
      : super(key: key);

  @override
  State<PickupFromWarehouseWidget> createState() =>
      _PickupFromWarehouseWidgetState();
}

class _PickupFromWarehouseWidgetState extends State<PickupFromWarehouseWidget> {
  late List<WarehouseOrderGroup> groups;

  List<WarehouseOrderGroup> groupOrdersBySenderReceiver(List<OrderData> items) {
    final Map<String, WarehouseOrderGroup> groupMap = {};

    for (var order in items) {
      final sender = order.pickupPoint?.name ?? '';
      final receiver = order.deliveryPoint?.name ?? '';
      final code = '$sender → $receiver';
      final customer = code;
      final orderNo = order.orderTrackingId ?? '';
      // 如果有 taskItems 字段就用，否则传空
      final taskItems = order.taskItems ?? [];

      print('orderNo: $orderNo, taskItems: $taskItems'); // 打印每个订单的 taskItems

      final orderModel = OrderModel(
        orderNo: orderNo,
        items: taskItems
            .map<ItemModel>((item) => ItemModel(
                  name: item['name'] ?? '',
                  size: item['length']?.toString() ?? '',
                  weight: item['weight']?.toString() ?? '',
                ))
            .toList(),
      );

      if (!groupMap.containsKey(code)) {
        groupMap[code] = WarehouseOrderGroup(
          code: code,
          customer: customer,
          orders: [],
        );
      }
      groupMap[code]!.orders.add(orderModel);
    }
    return groupMap.values.toList();
  }

  @override
  void initState() {
    super.initState();
    // 初始化数据
    groups = groupOrdersBySenderReceiver(widget.data); // 必须初始化
    print('widget.data: ${widget.data}');
    print('分组后数据: ${groups.length}'); // 打印分组数量

    // groups = [
    //   WarehouseOrderGroup(
    //     code: 'WBG',
    //     customer: 'Customer Name and Location',
    //     orders: [
    //       OrderModel(
    //         orderNo: "SO12345",
    //         items: [
    //           ItemModel(name: "Item A", size: "L", weight: "2kg"),
    //           ItemModel(name: "Item B", size: "M", weight: "1kg"),
    //         ],
    //       ),
    //       OrderModel(
    //         orderNo: "SO23456",
    //         items: [
    //           ItemModel(name: "Item A", size: "S", weight: "0.5kg"),
    //         ],
    //       ),
    //     ],
    //   ),
    //   WarehouseOrderGroup(
    //     code: 'PP2',
    //     customer: 'Customer Name and Location',
    //     orders: [
    //       OrderModel(
    //         orderNo: "SO34567",
    //         items: [
    //           ItemModel(name: "Item A", size: "L", weight: "2kg"),
    //         ],
    //       ),
    //       OrderModel(
    //         orderNo: "SO45678",
    //         items: [
    //           ItemModel(name: "Item A", size: "M", weight: "1kg"),
    //         ],
    //       ),
    //     ],
    //   ),
    // ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false, // 不自动显示返回按钮
      //   title: const Text('Pickup From Warehouse'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            // 分组列表
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groups
                      .map((group) => WarehouseOrderGroupWidget(group: group))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: Icon(Icons.check, size: 32, color: Colors.white), // 图标变大
          label: Text('', style: TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // 留空，后续补充点击逻辑
          },
        ),
      ),
    );
  }
}

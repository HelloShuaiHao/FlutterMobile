import 'package:flutter/material.dart';

class DeliveryWidget extends StatefulWidget {
  const DeliveryWidget({Key? key}) : super(key: key);

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> {
  late List<GroupedOrder> groupedOrders;

  @override
  void initState() {
    super.initState();
    // 初始化数据
    groupedOrders = [
      GroupedOrder(
        groupName: 'Xxx (Code)',
        groupDescription: 'Customer Name and Location',
        orders: [
          OrderModel(
            orderNo: "SO12345",
            items: [
              ItemModel(name: "Item A", size: "Size", weight: "Weight, xx"),
              ItemModel(name: "Item B", size: "Size", weight: "Weight, xx"),
            ],
          ),
          OrderModel(
            orderNo: "SO23456",
            items: [
              ItemModel(name: "Item A", size: "Size", weight: "Weight, xx"),
            ],
          ),
        ],
      ),
      GroupedOrder(
        groupName: 'xx (Code)',
        groupDescription: 'Customer Name and Location',
        orders: [
          OrderModel(
            orderNo: "SO34567",
            items: [
              ItemModel(name: "Item A", size: "Size", weight: "Weight, xx"),
            ],
          ),
          OrderModel(
            orderNo: "SO45678",
            items: [
              ItemModel(name: "Item A", size: "Size", weight: "Weight, xx"),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 将所有 group 下的 orders 合并为一个列表
    final allOrders = groupedOrders.expand((group) => group.orders).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 搜索框
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            // 订单列表
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: allOrders
                      .map((order) => _buildOrderWidget(order))
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

  Widget _buildGroupWidget(GroupedOrder group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          group.groupName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          group.groupDescription,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text('Select All', style: TextStyle(fontSize: 16)),
            Checkbox(
              value: group.orders.every((order) => order.selected),
              onChanged: (val) {
                setState(() {
                  for (var order in group.orders) {
                    order.selected = val ?? false;
                    for (var item in order.items) {
                      item.selected = val ?? false;
                    }
                  }
                });
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        ...group.orders.map((order) => _buildOrderWidget(order)).toList(),
      ],
    );
  }

  Widget _buildOrderWidget(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'OrderNo. (${order.orderNo})',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // ePOD 按钮点击事件
                },
                child: Text('ePOD'),
              ),
              Checkbox(
                value: order.selected,
                onChanged: (val) {
                  setState(() {
                    order.selected = val ?? false;
                    for (var item in order.items) {
                      item.selected = order.selected;
                    }
                  });
                },
              ),
            ],
          ),
          ...order.items.map((item) => _buildItemWidget(item, order)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemWidget(ItemModel item, OrderModel order) {
    return Row(
      children: [
        SizedBox(width: 16),
        Expanded(
          child: Text(
            '${item.name}, ${item.size}, ${item.weight}',
            style: TextStyle(fontSize: 15),
          ),
        ),
        Checkbox(
          value: item.selected,
          onChanged: (val) {
            setState(() {
              item.selected = val ?? false;
              order.selected = order.items.every((i) => i.selected);
            });
          },
        ),
      ],
    );
  }
}

// 数据结构
class GroupedOrder {
  final String groupName;
  final String groupDescription;
  final List<OrderModel> orders;

  GroupedOrder({
    required this.groupName,
    required this.groupDescription,
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

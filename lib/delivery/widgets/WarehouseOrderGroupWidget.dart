import 'package:flutter/material.dart';
import 'PickupFromWarehouseWidget.dart'; // 用于访问数据结构

class WarehouseOrderGroupWidget extends StatefulWidget {
  final WarehouseOrderGroup group;
  const WarehouseOrderGroupWidget({required this.group, Key? key})
      : super(key: key);

  @override
  State<WarehouseOrderGroupWidget> createState() =>
      _WarehouseOrderGroupWidgetState();
}

class _WarehouseOrderGroupWidgetState extends State<WarehouseOrderGroupWidget> {
  bool get selectAll => widget.group.orders.every((o) => o.selected);

  void updateSelectAll(bool? val) {
    setState(() {
      print("Select All Checkbox clicked: $val");
      for (var order in widget.group.orders) {
        order.selected = val ?? false;
        for (var item in order.items) {
          item.selected = val ?? false;
        }
      }
      print("Updated orders: ${widget.group.orders.map((o) => o.selected)}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Center(
            child: Text('${widget.group.code}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 8),
        Center(
            child: Text(widget.group.customer, style: TextStyle(fontSize: 16))),
        SizedBox(height: 16),
        Row(
          children: [
            Text('Select All', style: TextStyle(fontSize: 16)),
            Checkbox(
              value: selectAll,
              onChanged: (val) {
                print("Select All Checkbox clicked: $val");
                updateSelectAll(val);
              },
            ),
          ],
        ),
        SizedBox(height: 8),
        ...widget.group.orders.map((order) => _buildOrder(order)).toList(),
      ],
    );
  }

  Widget _buildOrder(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('OrderNo. (${order.orderNo})',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Spacer(),
              Checkbox(
                value: order.selected,
                onChanged: (val) {
                  print(
                      "Order Checkbox clicked: $val for OrderNo: ${order.orderNo}");
                  setState(() {
                    order.selected = val!;
                    for (var item in order.items) {
                      item.selected = order.selected;
                    }
                  });
                },
              ),
            ],
          ),
          ...order.items.map((item) => _buildItem(item, order)).toList(),
        ],
      ),
    );
  }

  Widget _buildItem(ItemModel item, OrderModel order) {
    return Row(
      children: [
        SizedBox(width: 16),
        Expanded(
          child: Text('${item.name}, Size, Weight, xx',
              style: TextStyle(fontSize: 15)),
        ),
        Checkbox(
          value: item.selected,
          onChanged: (val) {
            print("Item Checkbox clicked: $val for Item: ${item.name}");
            setState(() {
              item.selected = val!;
              order.selected = order.items.every((i) => i.selected);
              print("Updated item.selected: ${item.selected}");
              print("Updated order.selected: ${order.selected}");
            });
          },
        ),
        // Text('·', style: TextStyle(fontSize: 20)),
      ],
    );
  }
}

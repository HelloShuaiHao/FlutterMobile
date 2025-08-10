import 'package:flutter/material.dart';
import 'WarehouseOrderGroupWidget.dart';
import 'PickupFromWarehouseWidget.dart'; // 用于访问数据结构

class WarehouseOrderGroupWidgetTest extends StatelessWidget {
  const WarehouseOrderGroupWidgetTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 模拟数据
    final testGroup = WarehouseOrderGroup(
      code: 'TEST',
      customer: 'Test Customer',
      orders: [
        OrderModel(
          orderNo: "SO12345",
          items: [
            ItemModel(name: "Item A", size: "L", weight: "2kg"),
            ItemModel(name: "Item B", size: "M", weight: "1kg"),
          ],
        ),
        OrderModel(
          orderNo: "SO23456",
          items: [
            ItemModel(name: "Item C", size: "S", weight: "0.5kg"),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('WarehouseOrderGroupWidget Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: WarehouseOrderGroupWidget(group: testGroup),
        ),
      ),
    );
  }
}

import 'package:mighty_delivery/main/models/OrderListModel.dart';

class GroupedOrderData {
  String? deliveryOrderId; // 分组标准
  List<OrderData>? orders; // 分组中的订单列表
  bool isExpanded; // 是否展开

  GroupedOrderData({this.deliveryOrderId, this.orders, this.isExpanded = true});

  GroupedOrderData.fromJson(Map<String, dynamic> json) : isExpanded = true {
    // 默认为 true
    deliveryOrderId = json['group_name'];
    if (json['orders'] != null) {
      orders = <OrderData>[];
      json['orders'].forEach((v) {
        orders!.add(OrderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_name'] = deliveryOrderId;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

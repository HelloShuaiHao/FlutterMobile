import 'package:mighty_delivery/main/network/http_utils.dart';

class RoutePlanService {
  // 获取车辆的路线计划
  Future<List<Map<String, dynamic>>> getRoutePlansByVehicleId({
    required String vehicleId,
    String? filter,
    String? sorting,
    int? skipCount,
    int? maxResultCount,
  }) async {
    try {
      final queryParams = {
        'VehicleId': vehicleId,
        if (filter != null) 'Filter': filter,
        if (sorting != null) 'Sorting': sorting,
        if (skipCount != null) 'SkipCount': skipCount,
        if (maxResultCount != null) 'MaxResultCount': maxResultCount,
      };

      final response = await HttpUtils.get<Map<String, dynamic>>(
        'https://localhost:7006/api/delivery/route-plans/by-vehicle-id',
        params: queryParams,
      );

      if (response.data != null) {
        final List<dynamic> items = response.data!['items'];
        return items.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load route plans');
      }
    } catch (e) {
      print('Error fetching route plans: $e');
      throw Exception('Failed to fetch route plans');
    }
  }

  Map<String, dynamic> transformNewResponseToExistingFormat(Map<String, dynamic> newResponse) {
    // 提取分页信息
    final pagination = {
      "total_items": newResponse["totalCount"] ?? 0,
      "per_page": 10, // 假设每页 10 条数据
      "currentPage": 1, // 假设当前页为 1
      "totalPages": (newResponse["totalCount"] / 10).ceil(), // 计算总页数
    };

    // 提取订单数据
    final List<dynamic> items = newResponse["items"] ?? [];

    final List<Map<String, dynamic>> transformedData = [];

    for (var item in items) {
      final List<dynamic> routePlanTasks = item["routePlanTasks"] ?? [];

      for (var task in routePlanTasks) {
        final taskHeader = task["taskHeader"] ?? {};
        final pickupDetail = taskHeader["taskDetails"]?.firstWhere(
          (detail) => detail["taskDetailType"] == 0,
          orElse: () => null);
        final deliveryDetail = taskHeader["taskDetails"]?.firstWhere(
            (detail) => detail["taskDetailType"] == 1,
            orElse: () => null);        

        transformedData.add({
          "id": taskHeader["id"],
          // "id": int.tryParse(taskHeader["id"].toString()), // 转换为 int 类型
          "order_tracking_id": taskHeader["trackingNumber"],
          // "client_id": taskHeader["senderId"],
          // "client_id": int.tryParse(taskHeader["senderId"].toString()), // 转换为 int 类型        
          // "client_name": taskHeader["senderName"],
          "date": taskHeader["taskDate"].toString(),
          "pickup_point": pickupDetail != null
              ? {
                  "name": pickupDetail["contactPerson"],
                  "address": pickupDetail["addressLine1"],
                  // "latitude": pickupDetail["addressLatitude"],
                  // "longitude": pickupDetail["addressLongitude"],
                  "latitude": pickupDetail["addressLatitude"]?.toString(),
                  "longitude": pickupDetail["addressLongitude"]?.toString(),
                  "description": pickupDetail["remarks"],
                  "contact_number": pickupDetail["contactNumber"],
                  "start_time": pickupDetail["taskDetailDate"]?.toString(),
                  "end_time": pickupDetail["taskDetailDate"]?.toString(),
                  "instruction": pickupDetail["remarks"],
                }
              : null,
          "delivery_point": deliveryDetail != null
              ? {
                  "name": deliveryDetail["contactPerson"],
                  "address": deliveryDetail["addressLine1"],
                  // "latitude": deliveryDetail["addressLatitude"],
                  // "longitude": deliveryDetail["addressLongitude"],
                  "latitude": pickupDetail["addressLatitude"]?.toString(),
                  "longitude": pickupDetail["addressLongitude"]?.toString(),
                  "description": deliveryDetail["remarks"],
                  "contact_number": deliveryDetail["contactNumber"],
                  // "start_time": deliveryDetail["taskDetailDate"],
                  // "end_time": deliveryDetail["taskDetailDate"],
                  "start_time": deliveryDetail["taskDetailDate"]?.toString(),                  
                  "end_time": deliveryDetail["taskDetailDate"]?.toString(),                  
                  "instruction": deliveryDetail["remarks"],
                }
              : null,
          "country_id": null,
          "country_name": null,
          "city_id": null,
          "city_name": null,
          "parcel_type": "Small",
          "total_weight": taskHeader["totalWeight"],
          "total_distance": null,
          // "pickup_datetime": pickupDetail?["taskDetailDate"],
          // "delivery_datetime": deliveryDetail?["taskDetailDate"],
          // "pickup_datetime": pickupDetail?["taskDetailDate"]?.toString(),
          // "delivery_datetime": deliveryDetail?["taskDetailDate"]?.toString(),          
          // "status": taskHeader["status"],
          "status": taskHeader["status"].toString(),
          "payment_id": null,
          "payment_type": null,
          "payment_status": null,
          "payment_collect_from": null,
          "delivery_man_id": null,
          "delivery_man_name": null,
          "total_amount": null,
          // "vehicle_id": taskHeader["vehicleId"],
          "vehicle_id": int.tryParse(taskHeader["vehicleId"].toString()), // 转换为 int 类型
          // "vehicle_data": {
          //   "id": taskHeader["vehicleId"],
          //   // "id": int.tryParse(taskHeader["vehicleId"].toString()),
          //   "vehicleTypeName": "SmallCar",
          //   "vehicleTypeId": null,
          //   "driverName": null,
          //   "vehicle_register_no": taskHeader["vehicleRegisterNo"],
          // },
        });        
      }
    }

    return {
      "pagination": pagination,
      "data": transformedData,
    };
  }
}
import 'package:dio/dio.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';

class RoutePlanService {
  // 获取车辆的路线计划 getRoutePlansByVehicleIdAndStatusCode
  Future<List<Map<String, dynamic>>> getRoutePlansByVehicleIdAndStatusCode({
    required String vehicleId,
    String? filter,
    String? driverId,
    int? statusCode,
    String? sorting,
    int? skipCount,
    int? maxResultCount,
  }) async {
    try {
      final queryParams = {
        'vehicleId': vehicleId,
        if (filter != null) 'Filter': filter,
        if (driverId != null) 'DriverId': driverId,
        if (statusCode != null) 'statusCode': statusCode.toString(),
        if (sorting != null) 'Sorting': sorting,
        if (skipCount != null) 'SkipCount': skipCount.toString(),
        if (maxResultCount != null) 'MaxResultCount': maxResultCount.toString(),
      };

      final response = await HttpUtils.get<Map<String, dynamic>>(
        'https://localhost:7006/api/delivery/transport-tasks/filter-by-vehicle-and-status',
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

  Map<String, dynamic> transformNewResponseToExistingFormat(
      Map<String, dynamic> newResponse) {
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
      // 提取任务详情
      final List<dynamic> taskDetails = item["taskDetails"] ?? [];
      final pickupDetail = taskDetails.firstWhere(
          (detail) => detail["taskDetailType"] == 0,
          orElse: () => null);
      final deliveryDetail = taskDetails.firstWhere(
          (detail) => detail["taskDetailType"] == 1,
          orElse: () => null);

      // 转换数据格式
      transformedData.add({
        "id": item["id"] ?? "null",
        "order_tracking_id": item["trackingNumber"] ?? "null",
        "date": item["taskDate"].toString(),
        "pickup_point": pickupDetail != null
            ? {
                "name": pickupDetail["contactPerson"] ?? "null",
                "address": pickupDetail["addressLine1"] ?? "null",
                "businessEntityId":
                    pickupDetail["businessEntityId"]?.toString() ?? "null",
                "latitude":
                    pickupDetail["addressLatitude"]?.toString() ?? "null",
                "longitude":
                    pickupDetail["addressLongitude"]?.toString() ?? "null",
                "description": pickupDetail["remarks"] ?? "null",
                "contact_number": pickupDetail["contactNumber"] ?? "null",
                "start_time": pickupDetail["timeWindows"]?.isNotEmpty == true
                    ? "${pickupDetail["taskDetailDate"]} ${pickupDetail["timeWindows"][0]["startTime"]}"
                    : null,
                "end_time": pickupDetail["timeWindows"]?.isNotEmpty == true
                    ? "${pickupDetail["taskDetailDate"]} ${pickupDetail["timeWindows"][0]["endTime"]}"
                    : null,
                "instruction": pickupDetail["remarks"] ?? "null",
              }
            : null,
        "delivery_point": deliveryDetail != null
            ? {
                "name": deliveryDetail["contactPerson"] ??
                    "null", // Added comma here
                "address": deliveryDetail["addressLine1"] ?? "null",
                "businessEntityId":
                    deliveryDetail["businessEntityId"]?.toString() ?? "null",
                "latitude":
                    deliveryDetail["addressLatitude"]?.toString() ?? "null",
                "longitude":
                    deliveryDetail["addressLongitude"]?.toString() ?? "null",
                "description": deliveryDetail["remarks"] ?? "null",
                "contact_number": deliveryDetail["contactNumber"] ?? "null",
                "start_time": deliveryDetail["timeWindows"]?.isNotEmpty == true
                    ? "${deliveryDetail["taskDetailDate"]} ${deliveryDetail["timeWindows"][0]["startTime"]}"
                    : null,
                "end_time": deliveryDetail["timeWindows"]?.isNotEmpty == true
                    ? "${deliveryDetail["taskDetailDate"]} ${deliveryDetail["timeWindows"][0]["endTime"]}"
                    : null,
                "instruction": deliveryDetail["remarks"] ?? "null",
              }
            : null,
        "sender_id": item["senderId"] ?? "null",
        "sender_name": item["senderName"] ?? "null",
        "receiver_id": item["receiverId"] ?? "null",
        "receiver_name": item["receiverName"] ?? "null",
        // "status": item["status"].toString(),
        "status": "not sure", // 这里需要根据实际情况进行转换
        "vehicle_id": int.tryParse(item["vehicleId"] ?? "0"), // 转换为 int 类型
        "vehicle_register_no": item["vehicleRegisterNo"] ?? "null",
        "total_weight": item["totalWeight"],
        "task_items": item["taskItems"] ?? [],

        "country_id": null,
        "country_name": null,
        "city_id": null,
        "city_name": null,
        "parcel_type": "Small",
        "total_distance": null,
        "payment_id": null,
        "payment_type": null,
        "payment_status": null,
        "payment_collect_from": null,
        "delivery_man_id": null,
        "delivery_man_name": null,
        "total_amount": null,
      });
    }

    return {
      "pagination": pagination,
      "data": transformedData,
    };
  }

  // 新增状态的 API 方法
  Future<void> addTaskStatus({
    required String taskId,
    required String statusCode,
    required String name,
    String? senderMessage,
    String? receiverMessage,
    String? colorHex,
  }) async {
    try {
      final requestBody = {
        "statusCode": statusCode,
        "name": name,
        if (senderMessage != null) "senderMessage": senderMessage,
        if (receiverMessage != null) "receiverMessage": receiverMessage,
        if (colorHex != null) "colorHex": colorHex,
      };

      final response = await HttpUtils.post<Map<String, dynamic>>(
        'https://localhost:7006/api/delivery/transport-tasks/$taskId/add-task-status',
        data: requestBody,
        options: Options(
          headers: {
            "Content-Type": "application/json", // 确保设置了正确的 Content-Type
          },
        ),
      );

      if (response.data != null) {
        print("Task status added successfully: ${response.data}");
      } else {
        throw Exception('Failed to add task status');
      }
    } catch (e) {
      print("Error adding task status: $e");
      throw Exception("Failed to add task status");
    }
  }
}

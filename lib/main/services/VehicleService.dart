import 'package:mighty_delivery/main/network/http_utils.dart';

class VehicleService {
  // 获取所有车辆
  Future<List<Map<String, dynamic>>> getAllVehicles({
    List<int>? vehicleStatuses,
    String? filter,
    String? sorting,
    int? skipCount,
    int? maxResultCount,
  }) async {
    try {
      // Construct the query parameters
      final queryParams = {
        if (vehicleStatuses != null) 'VehicleStatuses': vehicleStatuses,
        if (filter != null) 'Filter': filter,
        if (sorting != null) 'Sorting': sorting,
        if (skipCount != null) 'SkipCount': skipCount,
        if (maxResultCount != null) 'MaxResultCount': maxResultCount,
      };

      final response = await HttpUtils.get<Map<String, dynamic>>(
        'https://localhost:7005/api/transport/vehicles',
        params: queryParams,
      );

      if (response.data != null) {
        final List<dynamic> items = response.data!['items'];
        return items.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      throw Exception('Failed to fetch vehicles');
    }
  }
}
import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/services/RoutePlanService.dart';
import 'package:mighty_delivery/main/services/VehicleService.dart';
import 'package:mighty_delivery/main/utils/storage.dart';

class TestVehicleScreen extends StatefulWidget {
  @override
  _TestVehicleScreenState createState() => _TestVehicleScreenState();
}

class _TestVehicleScreenState extends State<TestVehicleScreen> {
  late Future<List<Map<String, dynamic>>> _futureVehicles;

  @override
  void initState() {
    super.initState();
    print("当前进入 test_vehicle_screen.dart 页面");
    // 调用 getAllVehicles 方法获取数据
    _futureVehicles =
        VehicleService().getAllVehicles(vehicleStatuses: [0, 1, 2]);
  }

  void _fetchRoutePlans(String vehicleId) async {
    try {
      final routePlans = await RoutePlanService()
          .getRoutePlansByVehicleIdAndStatusCode(vehicleId: vehicleId);

      // 显示路线计划
      // showDialog 是 Flutter 中用于显示对话框的一个方法。
      // 它会在当前屏幕上弹出一个模态对话框，用户必须与对话框交互后才能返回到主界面。
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Route Plans for Vehicle $vehicleId"),
            content: routePlans.isNotEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: routePlans.map((plan) {
                      return ListTile(
                        title: Text(plan['id'] ?? "No ID"),
                        subtitle: Text(plan['planDate'] ?? "No Plan Date"),
                      );
                    }).toList(),
                  )
                : Text("No route plans found"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error fetching route plans: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch route plans")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Vehicles"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureVehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            final vehicles = snapshot.data!;
            if (vehicles.isEmpty) {
              return Center(child: Text("No vehicles found"));
            }
            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return ListTile(
                  title: Text(vehicle['vehicleTypeName'] ?? "No Name"),
                  subtitle: Text("ID: ${vehicle['id']}"),
                  onTap: () {
                    SpUtil.setJSON(
                      "vehicleId",
                      vehicle['id'],
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Vehicle ${vehicle['id']} saved")));
                    print("Vehicle ID in storage: " +
                        SpUtil.getJSON("vehicleId"));

                    _fetchRoutePlans(vehicle['id'].toString());
                  },
                );
              },
            );
          }
          return Center(child: Text("No data"));
        },
      ),
    );
  }
}

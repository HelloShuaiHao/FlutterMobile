import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ⭐ 新增

class VehicleSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedVehicleId;
  final ValueChanged<String?> onChanged;

  const VehicleSelectionWidget({
    Key? key,
    required this.items,
    this.selectedVehicleId,
    required this.onChanged,
  }) : super(key: key);

  @override
  _VehicleSelectionWidgetState createState() => _VehicleSelectionWidgetState();
}

class _VehicleSelectionWidgetState extends State<VehicleSelectionWidget> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedVehicleId;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Vehicle',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      value: _selectedId,
      hint: const Text("Select a vehicle"),
      items: widget.items.map((vehicle) {
        return DropdownMenuItem<String>(
          value: vehicle["id"],
          child: Text(
            "${vehicle["vehicleTypeName"]} - ${vehicle["vehicleRegisterNo"]}",
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) async {
        // ⭐ 改为 async
        setState(() {
          _selectedId = newValue;
        });
        if (newValue != null) {
          // 保存到 GetStorage
          SpUtil.setJSON("vehicleId", newValue);
          print('[VehicleSelection] ✅ Saved to GetStorage: $newValue');

          // ⭐ 新增：保存到 SharedPreferences
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('vehicleId', newValue);
            print('[VehicleSelection] ✅ Saved to SharedPreferences: $newValue');

            // ⭐ 新增：验证保存结果
            final verified = prefs.getString('vehicleId');
            if (verified == newValue) {
              print('[VehicleSelection] ✅ Verification SUCCESS: $verified');
            } else {
              print('[VehicleSelection] ❌ Verification FAILED!');
            }
          } catch (e) {
            print('[VehicleSelection] ⚠️ Save failed: $e');
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Vehicle $newValue saved")));
          print("Vehicle ID in storage: " + SpUtil.getJSON("vehicleId"));
        }
        widget.onChanged(newValue);
      },
    );
  }
}

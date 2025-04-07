import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/storage.dart';

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
    // _selectedId = widget.selectedVehicleId ??
    //     (widget.items.isNotEmpty ? widget.items[0]["id"] as String : null);
    _selectedId = null;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // 与 TextFormField 类似的装饰
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
      onChanged: (String? newValue) {
        setState(() {
          _selectedId = newValue;
        });
        if (newValue != null) {
          SpUtil.setJSON("vehicleId", newValue);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Vehicle $newValue saved"))
          );
          print("Vehicle ID in storage: " + SpUtil.getJSON("vehicleId"));
        }
        widget.onChanged(newValue);
      },
    );
  }
}
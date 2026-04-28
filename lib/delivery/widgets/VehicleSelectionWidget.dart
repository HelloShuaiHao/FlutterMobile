import 'package:flutter/material.dart';
import 'package:mighty_delivery/delivery/utils/vehicle_search_utils.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedVehicleId;
    _controller = TextEditingController(text: _labelForId(_selectedId));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant VehicleSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedVehicleId != widget.selectedVehicleId) {
      _selectedId = widget.selectedVehicleId;
      _controller.text = _labelForId(_selectedId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _labelForId(String? id) {
    if (id == null || id.isEmpty) return '';
    for (final vehicle in widget.items) {
      if (vehicle['id']?.toString() == id) return vehicleSearchLabel(vehicle);
    }
    return '';
  }

  Future<void> _saveVehicle(Map<String, dynamic> vehicle) async {
    final newValue = vehicle['id']?.toString();
    if (newValue == null || newValue.isEmpty) return;

    setState(() => _selectedId = newValue);
    final label = vehicleSearchLabel(vehicle);
    final plate = selectedVehiclePlate(vehicle);
    _controller.text = label;

    SpUtil.setJSON('vehicleId', newValue);
    SpUtil.setJSON(SELECTED_VEHICLE_LABEL, label);
    SpUtil.setJSON(SELECTED_VEHICLE_PLATE, plate);
    print('[VehicleSelection] Saved to GetStorage: $newValue');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vehicleId', newValue);
      await prefs.setString(SELECTED_VEHICLE_LABEL, label);
      await prefs.setString(SELECTED_VEHICLE_PLATE, plate);
      print('[VehicleSelection] Saved to SharedPreferences: $newValue');
    } catch (e) {
      print('[VehicleSelection] Save failed: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle $newValue saved')),
      );
    }
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Map<String, dynamic>>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: vehicleSearchLabel,
      optionsViewOpenDirection: OptionsViewOpenDirection.down,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return filterVehicles(widget.items, textEditingValue.text);
      },
      onSelected: _saveVehicle,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Vehicle',
            hintText: 'Search or select a vehicle',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onTap: () => setState(() {}),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final optionList = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: optionList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final vehicle = optionList[index];
                    final id = vehicle['id']?.toString();
                    return ListTile(
                      dense: true,
                      selected: id == _selectedId,
                      title: Text(vehicleSearchLabel(vehicle)),
                      onTap: () => onSelected(vehicle),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

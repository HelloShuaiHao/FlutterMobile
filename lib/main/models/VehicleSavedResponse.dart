import 'DeliverymanVehicleListModel.dart';

class VehicleSavedResponse {
  String? message;
  DeliverymanVehicle? data;

  VehicleSavedResponse({this.message, this.data});

  VehicleSavedResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new DeliverymanVehicle.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

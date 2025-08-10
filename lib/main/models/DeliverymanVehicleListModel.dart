import '../../main/models/PaginationModel.dart';

class DeliverymanVehicleListModel {
  final PaginationModel pagination;
  final List<DeliverymanVehicle> data;

  DeliverymanVehicleListModel({
    required this.pagination,
    required this.data,
  });

  factory DeliverymanVehicleListModel.fromJson(Map<String, dynamic> json) => DeliverymanVehicleListModel(
        pagination: PaginationModel.fromJson(json["pagination"]),
        data: List<DeliverymanVehicle>.from(json["data"].map((x) => DeliverymanVehicle.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DeliverymanVehicle {
  final int id;
  final int deliveryManId;
  final String deliveryMan;
  final DateTime startDatetime;
  final DateTime? endDatetime;
  final int isActive;
  final VehicleInfo vehicleInfo;

  DeliverymanVehicle({
    required this.id,
    required this.deliveryManId,
    required this.deliveryMan,
    required this.startDatetime,
    required this.endDatetime,
    required this.isActive,
    required this.vehicleInfo,
  });

  factory DeliverymanVehicle.fromJson(Map<String, dynamic> json) => DeliverymanVehicle(
        id: json["id"],
        deliveryManId: json["delivery_man_id"],
        deliveryMan: json["delivery_man"],
        startDatetime: DateTime.parse(json["start_datetime"]),
        endDatetime: json["end_datetime"] != null ? DateTime.parse(json["end_datetime"]) : null,
        isActive: json["is_active"],
        vehicleInfo: VehicleInfo.fromJson(json["vehicle_info"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "delivery_man_id": deliveryManId,
        "delivery_man": deliveryMan,
        "start_datetime": startDatetime.toIso8601String(),
        "end_datetime": endDatetime != null ? endDatetime!.toIso8601String() : null,
        "is_active": isActive,
        "vehicle_info": vehicleInfo.toJson(),
      };
}

class VehicleInfo {
  final String? make;
  final String? color;
  final String? model;
  final String? address;
  final String? vehicleId;
  final String? fuelType;
  final String? ownerNumber;
  final String? ownerName;
  final String? currentMileage;
  final DateTime? registrationAte;
  final String? transmissionType;
  final String? yearOfManufacture;
  final String? licensePlateNumber;
  final String? vehicleIdentificationNumber;

  VehicleInfo({
    this.make,
    this.color,
    this.model,
    this.address,
    this.vehicleId,
    this.fuelType,
    this.ownerNumber,
    this.ownerName,
    this.currentMileage,
    this.registrationAte,
    this.transmissionType,
    this.yearOfManufacture,
    this.licensePlateNumber,
    this.vehicleIdentificationNumber,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => VehicleInfo(
        make: json["make"],
        color: json["color"],
        model: json["model"],
        address: json["address"],
        vehicleId: json["vehicle_id"],
        fuelType: json["fuel_type"],
        ownerNumber: json["owner_number"],
        ownerName: json["owner_name"],
        currentMileage: json["current_mileage"],
        registrationAte: DateTime.parse(json["registration_date"]),
        transmissionType: json["transmission_type"],
        yearOfManufacture: json["year_of_manufacture"],
        licensePlateNumber: json["license_plate_number"],
        vehicleIdentificationNumber: json["vehicle_identification_number"],
      );

  Map<String, dynamic> toJson() => {
        "make": make,
        "color": color,
        "model": model,
        "address": address,
        "vehicle_id": vehicleId,
        "fuel_type": fuelType,
        "owner_number": ownerNumber,
        "owner_name": ownerName,
        "current_mileage": currentMileage,
        "registration_date": registrationAte != null
            ? "${registrationAte!.year.toString().padLeft(4, '0')}-${registrationAte!.month.toString().padLeft(2, '0')}-${registrationAte!.day.toString().padLeft(2, '0')}"
            : "",
        "transmission_type": transmissionType,
        "year_of_manufacture": yearOfManufacture,
        "license_plate_number": licensePlateNumber,
        "vehicle_identification_number": vehicleIdentificationNumber,
      };
}

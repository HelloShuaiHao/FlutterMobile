import '../../main/models/CreateOrderDetailModel.dart';

class TotalAmountResponse {
  num? fixedAmount;
  num? weightAmount;
  num? distanceAmount;
  List<ExtraCharges>? extraCharges;
  num? vehicleAmount;
  num? insuranceAmount;
  num? diffWeight;
  num? diffDistance;
  num? totalAmount;
  num? baseTotal;

  TotalAmountResponse(
      {this.fixedAmount,
      this.weightAmount,
      this.distanceAmount,
      this.extraCharges,
      this.vehicleAmount,
      this.insuranceAmount,
      this.diffWeight,
      this.diffDistance,
      this.totalAmount,
      this.baseTotal});

  TotalAmountResponse.fromJson(Map<String, dynamic> json) {
    fixedAmount = json['fixed_amount'];
    weightAmount = json['weight_amount'];
    distanceAmount = json['distance_amount'];
    if (json['extra_charges'] != null) {
      extraCharges = <ExtraCharges>[];
      json['extra_charges'].forEach((v) {
        extraCharges!.add(new ExtraCharges.fromJson(v));
      });
    }
    vehicleAmount = json['vehicle_amount'];
    insuranceAmount = json['insurance_amount'];
    diffWeight = json['diff_weight'];
    diffDistance = json['diff_distance'];
    totalAmount = json['total_amount'];
    baseTotal = json['base_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fixed_amount'] = this.fixedAmount;
    data['weight_amount'] = this.weightAmount;
    data['distance_amount'] = this.distanceAmount;
    if (this.extraCharges != null) {
      data['extra_charges'] = this.extraCharges!.map((v) => v.toJson()).toList();
    }
    data['vehicle_amount'] = this.vehicleAmount;
    data['insurance_amount'] = this.insuranceAmount;
    data['diff_weight'] = this.diffWeight;
    data['diff_distance'] = this.diffDistance;
    data['total_amount'] = this.totalAmount;
    data['base_total'] = this.baseTotal;
    return data;
  }
}
//
// class ExtraCharges {
//   int? id;
//   String? title;
//   String? chargesType;
//   num? charges;
//   num? chargeAmount;
//   int? countryId;
//   int? cityId;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//
//   ExtraCharges({
//     this.id,
//     this.title,
//     this.chargesType,
//     this.charges,
//     this.countryId,
//     this.cityId,
//     this.status,
//     this.createdAt,
//     this.chargeAmount,
//     this.updatedAt,
//   });
//
//   ExtraCharges.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     chargesType = json['charges_type'];
//     charges = json['charges'];
//     countryId = json['country_id'];
//     cityId = json['city_id'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     chargeAmount = json['charge_amount'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['title'] = this.title;
//     data['charges_type'] = this.chargesType;
//     data['charges'] = this.charges;
//     data['country_id'] = this.countryId;
//     data['city_id'] = this.cityId;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['charge_amount'] = this.chargeAmount;
//     return data;
//   }
// }

class ordersLatLngResponseList {
  List<Data>? data;

  ordersLatLngResponseList({this.data});

  ordersLatLngResponseList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? orderTrackingId;
  int? id;
  int? clientId;
  String? clientName;
  String? date;
  PickupPoint? pickupPoint;
  PickupPoint? deliveryPoint;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? parcelType;
  int? totalWeight;
  num? totalDistance;
  int? weightCharge;
  // double? distanceCharge;
  String? pickupDatetime;
  String? deliveryDatetime;
  int? parentOrderId;
  String? status;
  // String? paymentId;
  // String? paymentType;
  // String? paymentStatus;
  // String? paymentCollectFrom;
  // int? deliveryManId;
  // String? deliveryManName;
  // int? fixedCharges;
  // List<ExtraCharges>? extraCharges;
  // double? totalAmount;
  // int? totalParcel;
  // String? reason;
  // int? pickupConfirmByClient;
  // int? pickupConfirmByDeliveryMan;
  // String? pickupTimeSignature;
  // String? deliveryTimeSignature;
  // String? autoAssign;
  // String? deletedAt;
  // bool? returnOrderId;
  // String? vehicleId;
  // String? vehicleData;
  // String? vehicleImage;
  // String? isReturn;
  // String? invoice;

  Data({
    this.orderTrackingId,
    this.id,
    this.clientId,
    this.clientName,
    this.date,
    this.pickupPoint,
    this.deliveryPoint,
    this.countryId,
    this.countryName,
    this.cityId,
    this.cityName,
    this.parcelType,
    this.totalWeight,
    this.totalDistance,
    this.weightCharge,
    //  this.distanceCharge,
    this.pickupDatetime,
    this.deliveryDatetime,
    this.parentOrderId,
    this.status,
    // this.paymentId,
    // this.paymentType,
    // this.paymentStatus,
    // this.paymentCollectFrom,
    // this.deliveryManId,
    // this.deliveryManName,
    // this.fixedCharges,
    // this.extraCharges,
    // this.totalAmount,
    // this.totalParcel,
    // this.reason,
    // this.pickupConfirmByClient,
    // this.pickupConfirmByDeliveryMan,
    // this.pickupTimeSignature,
    // this.deliveryTimeSignature,
    // this.autoAssign,
    // this.deletedAt,
    // this.returnOrderId,
    // this.vehicleId,
    // this.vehicleData,
    // this.vehicleImage,
    // this.isReturn,
    // this.invoice
  });

  Data.fromJson(Map<String, dynamic> json) {
    orderTrackingId = json['order_tracking_id'];
    id = json['id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    date = json['date'];
    pickupPoint = json['pickup_point'] != null ? new PickupPoint.fromJson(json['pickup_point']) : null;
    deliveryPoint = json['delivery_point'] != null ? new PickupPoint.fromJson(json['delivery_point']) : null;
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    parcelType = json['parcel_type'];
    totalWeight = json['total_weight'];
    totalDistance = json['total_distance'];
    weightCharge = json['weight_charge'];
    //   distanceCharge = json['distance_charge'];
    pickupDatetime = json['pickup_datetime'];
    deliveryDatetime = json['delivery_datetime'];
    parentOrderId = json['parent_order_id'];
    status = json['status'];
    // paymentId = json['payment_id'];
    // paymentType = json['payment_type'];
    // paymentStatus = json['payment_status'];
    // paymentCollectFrom = json['payment_collect_from'];
    // deliveryManId = json['delivery_man_id'];
    // deliveryManName = json['delivery_man_name'];
    // fixedCharges = json['fixed_charges'];
    // if (json['extra_charges'] != null) {
    //   extraCharges = <ExtraCharges>[];
    //   json['extra_charges'].forEach((v) {
    //     extraCharges!.add(new ExtraCharges.fromJson(v));
    //   });
    // }
    //  totalAmount = json['total_amount'];
    // totalParcel = json['total_parcel'];
    //  reason = json['reason'];
    //  pickupConfirmByClient = json['pickup_confirm_by_client'];
    //  pickupConfirmByDeliveryMan = json['pickup_confirm_by_delivery_man'];
    //  pickupTimeSignature = json['pickup_time_signature'];
    //  deliveryTimeSignature = json['delivery_time_signature'];
    //  autoAssign = json['auto_assign'];
    //  deletedAt = json['deleted_at'];
    //  returnOrderId = json['return_order_id'];
    //  vehicleId = json['vehicle_id'];
    //  vehicleData = json['vehicle_data'];
    //  vehicleImage = json['vehicle_image'];
    //  isReturn = json['is_return'];
    //  invoice = json['invoice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_tracking_id'] = this.orderTrackingId;
    data['id'] = this.id;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['date'] = this.date;
    if (this.pickupPoint != null) {
      data['pickup_point'] = this.pickupPoint!.toJson();
    }
    if (this.deliveryPoint != null) {
      data['delivery_point'] = this.deliveryPoint!.toJson();
    }
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['parcel_type'] = this.parcelType;
    data['total_weight'] = this.totalWeight;
    data['total_distance'] = this.totalDistance;
    data['weight_charge'] = this.weightCharge;
    //   data['distance_charge'] = this.distanceCharge;
    data['pickup_datetime'] = this.pickupDatetime;
    data['delivery_datetime'] = this.deliveryDatetime;
    data['parent_order_id'] = this.parentOrderId;
    data['status'] = this.status;
    // data['payment_id'] = this.paymentId;
    // data['payment_type'] = this.paymentType;
    // data['payment_status'] = this.paymentStatus;
    // data['payment_collect_from'] = this.paymentCollectFrom;
    // data['delivery_man_id'] = this.deliveryManId;
    // data['delivery_man_name'] = this.deliveryManName;
    // data['fixed_charges'] = this.fixedCharges;
    // if (this.extraCharges != null) {
    //   data['extra_charges'] = this.extraCharges!.map((v) => v.toJson()).toList();
    // }
    // data['total_amount'] = this.totalAmount;
    // data['total_parcel'] = this.totalParcel;
    // data['reason'] = this.reason;
    // data['pickup_confirm_by_client'] = this.pickupConfirmByClient;
    // data['pickup_confirm_by_delivery_man'] = this.pickupConfirmByDeliveryMan;
    // data['pickup_time_signature'] = this.pickupTimeSignature;
    // data['delivery_time_signature'] = this.deliveryTimeSignature;
    // data['auto_assign'] = this.autoAssign;
    // data['deleted_at'] = this.deletedAt;
    // data['return_order_id'] = this.returnOrderId;
    // data['vehicle_id'] = this.vehicleId;
    // data['vehicle_data'] = this.vehicleData;
    // data['vehicle_image'] = this.vehicleImage;
    // data['is_return'] = this.isReturn;
    // data['invoice'] = this.invoice;
    return data;
  }
}

class PickupPoint {
  String? address;
  String? endTime;
  String? latitude;
  String? longitude;
  String? startTime;
  String? description;
  String? instruction;
  String? contactNumber;

  PickupPoint(
      {this.address,
      this.endTime,
      this.latitude,
      this.longitude,
      this.startTime,
      this.description,
      this.instruction,
      this.contactNumber});

  PickupPoint.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    endTime = json['end_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    startTime = json['start_time'];
    description = json['description'];
    instruction = json['instruction'];
    contactNumber = json['contact_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['end_time'] = this.endTime;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['start_time'] = this.startTime;
    data['description'] = this.description;
    data['instruction'] = this.instruction;
    data['contact_number'] = this.contactNumber;
    return data;
  }
}

class ExtraCharges {
  String? key;
  int? value;
  String? valueType;

  ExtraCharges({this.key, this.value, this.valueType});

  ExtraCharges.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
    valueType = json['value_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    data['value_type'] = this.valueType;
    return data;
  }
}

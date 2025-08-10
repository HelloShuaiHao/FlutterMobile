class CreateOrderDetailsResponse {
  CityDetail? cityDetail;
  List<VehicleDetail>? vehicleDetail;
  List<UseraddressDetail>? useraddressDetail;
  List<StaticDetails>? staticDetails;
  AppSettingDetail? appSettingDetail;

  CreateOrderDetailsResponse(
      {this.cityDetail,
      this.vehicleDetail,
      this.useraddressDetail,
      this.staticDetails,
      this.appSettingDetail});

  CreateOrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    cityDetail = json['city-detail'] != null
        ? new CityDetail.fromJson(json['city-detail'])
        : null;
    if (json['vehicle-detail'] != null) {
      vehicleDetail = <VehicleDetail>[];
      json['vehicle-detail'].forEach((v) {
        vehicleDetail!.add(new VehicleDetail.fromJson(v));
      });
    }
    if (json['useraddress-detail'] != null) {
      useraddressDetail = <UseraddressDetail>[];
      json['useraddress-detail'].forEach((v) {
        useraddressDetail!.add(new UseraddressDetail.fromJson(v));
      });
    }
    if (json['static-details'] != null) {
      staticDetails = <StaticDetails>[];
      json['static-details'].forEach((v) {
        staticDetails!.add(new StaticDetails.fromJson(v));
      });
    }
    appSettingDetail = json['app-setting-detail'] != null
        ? new AppSettingDetail.fromJson(json['app-setting-detail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cityDetail != null) {
      data['city-detail'] = this.cityDetail!.toJson();
    }
    if (this.vehicleDetail != null) {
      data['vehicle-detail'] =
          this.vehicleDetail!.map((v) => v.toJson()).toList();
    }
    if (this.useraddressDetail != null) {
      data['useraddress-detail'] =
          this.useraddressDetail!.map((v) => v.toJson()).toList();
    }
    if (this.staticDetails != null) {
      data['static-details'] =
          this.staticDetails!.map((v) => v.toJson()).toList();
    }
    if (this.appSettingDetail != null) {
      data['app-setting-detail'] = this.appSettingDetail!.toJson();
    }
    return data;
  }
}

class CityDetail {
  int? id;
  String? name;
  String? address;
  int? countryId;
  String? countryName;

  // Country? country;
  int? status;
  num? fixedCharges;
  List<ExtraCharges>? extraCharges;
  num? cancelCharges;
  int? minDistance;
  int? minWeight;
  num? perDistanceCharges;
  num? perWeightCharges;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? commissionType;
  num? adminCommission;

  CityDetail(
      {this.id,
      this.name,
      this.address,
      this.countryId,
      this.countryName,
      //  this.country,
      this.status,
      this.fixedCharges,
      this.extraCharges,
      this.cancelCharges,
      this.minDistance,
      this.minWeight,
      this.perDistanceCharges,
      this.perWeightCharges,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.commissionType,
      this.adminCommission});

  CityDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    // country = json['country'] != null ? new Country.fromJson(json['country']) : null;
    status = json['status'];
    fixedCharges = json['fixed_charges'];
    if (json['extra_charges'] != null) {
      extraCharges = <ExtraCharges>[];
      json['extra_charges'].forEach((v) {
        extraCharges!.add(new ExtraCharges.fromJson(v));
      });
    }
    cancelCharges = json['cancel_charges'];
    minDistance = json['min_distance'];
    minWeight = json['min_weight'];
    perDistanceCharges = json['per_distance_charges'];
    perWeightCharges = json['per_weight_charges'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    commissionType = json['commission_type'];
    adminCommission = json['admin_commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    // if (this.country != null) {
    //   data['country'] = this.country!.toJson();
    // }
    data['status'] = this.status;
    data['fixed_charges'] = this.fixedCharges;
    if (this.extraCharges != null) {
      data['extra_charges'] =
          this.extraCharges!.map((v) => v.toJson()).toList();
    }
    data['cancel_charges'] = this.cancelCharges;
    data['min_distance'] = this.minDistance;
    data['min_weight'] = this.minWeight;
    data['per_distance_charges'] = this.perDistanceCharges;
    data['per_weight_charges'] = this.perWeightCharges;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['commission_type'] = this.commissionType;
    data['admin_commission'] = this.adminCommission;
    return data;
  }
}

// class Country {
//   int? id;
//   String? name;
//   String? code;
//   String? distanceType;
//   String? weightType;
//   Null? links;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//   Null? deletedAt;
//
//   Country(
//       {this.id,
//       this.name,
//       this.code,
//       this.distanceType,
//       this.weightType,
//       this.links,
//       this.status,
//       this.createdAt,
//       this.updatedAt,
//       this.deletedAt});
//
//   Country.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     code = json['code'];
//     distanceType = json['distance_type'];
//     weightType = json['weight_type'];
//     links = json['links'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     deletedAt = json['deleted_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['code'] = this.code;
//     data['distance_type'] = this.distanceType;
//     data['weight_type'] = this.weightType;
//     data['links'] = this.links;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['deleted_at'] = this.deletedAt;
//     return data;
//   }
// }

class ExtraCharges {
  int? id;
  String? title;
  String? chargesType;
  int? charges;
  int? countryId;
  int? cityId;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  ExtraCharges({
    this.id,
    this.title,
    this.chargesType,
    this.charges,
    this.countryId,
    this.cityId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  ExtraCharges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    chargesType = json['charges_type'];
    charges = json['charges'];
    countryId = json['country_id'];
    cityId = json['city_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    //  chargeAmount = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['charges_type'] = this.chargesType;
    data['charges'] = this.charges;
    data['country_id'] = this.countryId;
    data['city_id'] = this.cityId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class VehicleDetail {
  int? id;
  String? title;
  String? type;
  String? size;
  String? capacity;

  //Null? cityIds;
  //Null? cityText;
  int? status;
  String? description;
  int? price;
  int? minKm;
  int? perKmCharge;
  String? vehicleImage;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  VehicleDetail(
      {this.id,
      this.title,
      this.type,
      this.size,
      this.capacity,
//      this.cityIds,
      //     this.cityText,
      this.status,
      this.description,
      this.price,
      this.minKm,
      this.perKmCharge,
      this.vehicleImage,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  VehicleDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    size = json['size'];
    capacity = json['capacity'];
    //  cityIds = json['city_ids'];
    // cityText = json['city_text'];
    status = json['status'];
    description = json['description'];
    price = json['price'];
    minKm = json['min_km'];
    perKmCharge = json['per_km_charge'];
    vehicleImage = json['vehicle_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['type'] = this.type;
    data['size'] = this.size;
    data['capacity'] = this.capacity;
    //  data['city_ids'] = this.cityIds;
    //  data['city_text'] = this.cityText;
    data['status'] = this.status;
    data['description'] = this.description;
    data['price'] = this.price;
    data['min_km'] = this.minKm;
    data['per_km_charge'] = this.perKmCharge;
    data['vehicle_image'] = this.vehicleImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class UseraddressDetail {
  int? id;
  int? userId;
  String? userName;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? addressType;
  String? address;
  String? latitude;
  String? longitude;
  String? contactNumber;
  String? createdAt;
  String? updatedAt;

  UseraddressDetail(
      {this.id,
      this.userId,
      this.userName,
      this.countryId,
      this.countryName,
      this.cityId,
      this.cityName,
      this.addressType,
      this.address,
      this.latitude,
      this.longitude,
      this.contactNumber,
      this.createdAt,
      this.updatedAt});

  UseraddressDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    addressType = json['address_type'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    contactNumber = json['contact_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['address_type'] = this.addressType;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['contact_number'] = this.contactNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class StaticDetails {
  int? id;
  String? type;
  String? label;
  String? value;
  String? createdAt;
  String? updatedAt;

  StaticDetails(
      {this.id,
      this.type,
      this.label,
      this.value,
      this.createdAt,
      this.updatedAt});

  StaticDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    label = json['label'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['label'] = this.label;
    data['value'] = this.value;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class AppSettingDetail {
  String? currencyCode;
  String? currency;
  String? currencyPosition;
  int? isVehicleInOrder;
  String? isInsuranceAllow;
  String? insurancePercentage;
  String? insuranceDescription;
  int? isBiddingEnabled;

  AppSettingDetail({
    this.currencyCode,
    this.currency,
    this.currencyPosition,
    this.isVehicleInOrder,
    this.isBiddingEnabled,
  });

  AppSettingDetail.fromJson(Map<String, dynamic> json) {
    currencyCode = json['currency_code'];
    currency = json['currency'];
    currencyPosition = json['currency_position'];
    isVehicleInOrder = json['is_vehicle_in_order'];
    isInsuranceAllow = json['insurance_allow'];
    insurancePercentage = json['insurance_perntage'];
    insuranceDescription = json['insurance_description'];
    isBiddingEnabled = json['is_bidding_in_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency_code'] = this.currencyCode;
    data['currency'] = this.currency;
    data['currency_position'] = this.currencyPosition;
    data['is_vehicle_in_order'] = this.isVehicleInOrder;
    data['insurance_allow'] = this.isInsuranceAllow;
    data['insurance_perntage'] = this.insurancePercentage;
    data['insurance_description'] = this.insuranceDescription;
    data['is_bidding_in_order'] = this.isBiddingEnabled;
    return data;
  }
}

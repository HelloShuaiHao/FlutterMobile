import '../../main/models/PaginationModel.dart';

class AddressListModel {
  PaginationModel? pagination;
  List<AddressData>? data;

  AddressListModel({this.pagination, this.data});

  AddressListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <AddressData>[];
      json['data'].forEach((v) {
        data!.add(new AddressData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddressData {
  int? id;
  int? userId;
  String? userName;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? address;
  String? latitude;
  String? longitude;
  String? contactNumber;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? addressType;

  AddressData(
      {this.id,
      this.userId,
      this.userName,
      this.countryId,
      this.countryName,
      this.cityId,
      this.cityName,
      this.address,
      this.latitude,
      this.longitude,
      this.contactNumber,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.addressType});

  AddressData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    contactNumber = json['contact_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    addressType = json['address_type'];
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
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['contact_number'] = this.contactNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['address_type'] = this.addressType;
    return data;
  }
}

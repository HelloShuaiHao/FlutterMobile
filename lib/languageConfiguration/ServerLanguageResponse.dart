class ServerLanguageResponse {
  bool? status;
  int? currentVersionNo;
  List<LanguageJsonData>? data;
  bool? isAllowDeliveryMan;
  String? themeColor;

  ServerLanguageResponse({this.status, this.data, this.currentVersionNo});

  ServerLanguageResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    currentVersionNo = json['version_code'];
    // themeColor = json['theme_color'];
    themeColor = "#4682B4"; // 设置默认主题颜色
    isAllowDeliveryMan = json['allow_deliveryman'];
    if (json['data'] != null) {
      data = <LanguageJsonData>[];
      json['data'].forEach((v) {
        data!.add(new LanguageJsonData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['version_code'] = this.currentVersionNo;
    data['theme_color'] = this.themeColor;
    data['allow_deliveryman'] = this.isAllowDeliveryMan;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LanguageJsonData {
  int? id;
  String? languageName;
  String? languageCode;
  String? countryCode;
  String? languageImage;
  int? isRtl;
  int? isDefaultLanguage;
  List<ContentData>? contentData;
  String? createdAt;
  String? updatedAt;

  LanguageJsonData(
      {this.id,
      this.languageName,
      this.isRtl,
      this.contentData,
      this.isDefaultLanguage,
      this.createdAt,
      this.updatedAt,
      this.languageCode,
      this.countryCode,
      this.languageImage});

  LanguageJsonData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    languageName = json['language_name'];
    isDefaultLanguage = json['id_default_language'];
    languageCode = json['language_code'] == null ? "en" : json['language_code'];
    countryCode = json['country_code'];
    isRtl = json['is_rtl'];
    if (json['contentdata'] != null) {
      contentData = <ContentData>[];
      json['contentdata'].forEach((v) {
        contentData!.add(new ContentData.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    languageImage = json['language_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['language_name'] = this.languageName;
    data['country_code'] = this.countryCode;
    data['language_code'] = this.languageCode;
    data['id_default_language'] = this.isDefaultLanguage;
    data['is_rtl'] = this.isRtl;
    if (this.contentData != null) {
      data['contentdata'] = this.contentData!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['language_image'] = this.languageImage;
    return data;
  }
}

class ContentData {
  int? keywordId;
  String? keywordName;
  Map<String, String>? keywordValue; // 修改为支持多语言的 Map

  ContentData({this.keywordId, this.keywordName, this.keywordValue});

  ContentData.fromJson(Map<String, dynamic> json) {
    keywordId = json['keyword_id'];
    keywordName = json['keyword_name'];

    // 处理不同的数据结构
    if (json['keyword_value'] is String) {
      // 如果是字符串，转换为多语言格式
      keywordValue = {'en': json['keyword_value']};
    } else if (json['keyword_value'] is Map) {
      // 如果已经是多语言格式，直接赋值
      keywordValue = Map<String, String>.from(json['keyword_value']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['keyword_id'] = this.keywordId;
    data['keyword_name'] = this.keywordName;
    data['keyword_value'] = this.keywordValue;
    return data;
  }
}

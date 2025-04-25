import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../extensions/shared_pref.dart';
import '../main.dart';
import '../main/utils/Constants.dart';
import 'LanguageDefaultJson.dart';
import 'LocalLanguageResponse.dart';
import 'ServerLanguageResponse.dart';

const LanguageJsonDataRes = 'LanguageJsonDataRes'; // DO NOT CHANGE
const CURRENT_LAN_VERSION = 'LanguageData'; // DO NOT CHANGE
const LanguageVersion = '0'; // DO NOT CHANGE
const SELECTED_LANGUAGE_CODE = 'selected_language_code'; // DO NOT CHANGE
const SELECTED_LANGUAGE_COUNTRY_CODE = 'selected_language_country_code'; // DO NOT CHANGE
const IS_SELECTED_LANGUAGE_CHANGE = 'isSelectedLanguageChange';

Locale defaultLanguageLocale = Locale(defaultLanguageCode, defaultCountryCode);

Locale setDefaultLocate() {
  // 加载本地语言数据
  initJsonFile(); // 确保本地语言数据已加载

  // 如果本地语言数据存在，优先使用本地语言数据
  if (defaultLanguageDataKeys.isNotEmpty) {
    String selectedLanguageCode = getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode);
    defaultLanguageLocale = Locale(selectedLanguageCode, defaultCountryCode);
    return defaultLanguageLocale;
  }

  // 如果本地语言数据为空，回退到服务器语言数据
  // String getJsonData = getStringAsync(LanguageJsonDataRes, defaultValue: "");
  // if (getJsonData.isNotEmpty) {
  //   ServerLanguageResponse languageSettings = ServerLanguageResponse.fromJson(json.decode(getJsonData.trim()));
  //   if (languageSettings.data!.isNotEmpty) {
  //     defaultServerLanguageData = languageSettings.data;
  //     performLanguageOperation(defaultServerLanguageData);
  //   }
  // }

  return defaultLanguageLocale;
}

performLanguageOperation(List<LanguageJsonData>? _defaultServerLanguageData) {
  String selectedLanguageCode = getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: "");
  bool isFoundLocalSelectedLanguage = false;
  bool isFoundSelectedLanguageFromServer = false;

  for (int index = 0; index < _defaultServerLanguageData!.length; index++) {
    if (selectedLanguageCode.isNotEmpty) {
      if (_defaultServerLanguageData[index].languageCode == selectedLanguageCode) {
        isFoundLocalSelectedLanguage = true;
        defaultLanguageLocale =
            Locale(_defaultServerLanguageData[index].languageCode!, _defaultServerLanguageData[index].countryCode!);
        selectedServerLanguageData = _defaultServerLanguageData[index];
        break;
      }
    }
    if (_defaultServerLanguageData[index].isDefaultLanguage == 1) {
      isFoundSelectedLanguageFromServer = true;
      defaultLanguageLocale =
          Locale(_defaultServerLanguageData[index].languageCode!, _defaultServerLanguageData[index].countryCode!);
      selectedServerLanguageData = _defaultServerLanguageData[index];
    }
  }

  if (!isFoundLocalSelectedLanguage && !isFoundSelectedLanguageFromServer) {
    selectedServerLanguageData = null;
  }
}

List<Locale> getSupportedLocales() {
  print("get supported called");
  List<Locale> list = [];
  if (defaultServerLanguageData != null && defaultServerLanguageData!.length > 0) {
    for (int index = 0; index < defaultServerLanguageData!.length; index++) {
      list.add(Locale(defaultServerLanguageData![index].languageCode!, defaultServerLanguageData![index].countryCode!));
    }
  } else {
    list.add(defaultLanguageLocale);
  }
  return list;
}

String getContentValueFromKey(int keywordId) {
  String selectedLanguageCode = getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode);

  String defaultKeyValue = defaultKeyNotFoundValue;
  bool isFoundKey = false;
  // 优先从本地语言数据中查找
  // for (int index = 0; index < defaultLanguageDataKeys.length; index++) {
  //   if (defaultLanguageDataKeys[index].keywordId == keywordId) {
  //     defaultKeyValue = defaultLanguageDataKeys[index].keywordValue!;
  //     isFoundKey = true;
  //     break;
  //   }
  // }
  
  for (var content in defaultLanguageDataKeys) {
    if (content.keywordId == keywordId) {
      if (content.keywordValue != null && content.keywordValue!.containsKey(selectedLanguageCode)) {
        return content.keywordValue![selectedLanguageCode]!;
      }
      return content.keywordValue?['en'] ?? defaultKeyValue; // 默认返回英文
    }
  }

  return "$defaultKeyValue ($keywordId)";

  // 如果本地未找到，再从服务器语言数据中查找
  // if (!isFoundKey && selectedServerLanguageData != null) {
  //   for (int index = 0; index < selectedServerLanguageData!.contentData!.length; index++) {
  //     if (selectedServerLanguageData!.contentData![index].keywordId == keywordId) {
  //       defaultKeyValue = selectedServerLanguageData!.contentData![index].keywordValue!;
  //       isFoundKey = true;
  //       break;
  //     }
  //   }
  // }

  // if (selectedServerLanguageData != null) {
  //   for (int index = 0; index < selectedServerLanguageData!.contentData!.length; index++) {
  //     if (selectedServerLanguageData!.contentData![index].keywordId == keywordId) {
  //       defaultKeyValue = selectedServerLanguageData!.contentData![index].keywordValue!;
  //       isFoundKey = true;
  //       break;
  //     }
  //   }
  // } else {
  //   for (int index = 0; index < defaultLanguageDataKeys.length; index++) {
  //     if (defaultLanguageDataKeys[index].keywordId == keywordId) {
  //       defaultKeyValue = defaultLanguageDataKeys[index].keywordValue!;
  //       isFoundKey = true;
  //       break;
  //     }
  //   }
  // }

  // if (!isFoundKey) {
  //   defaultKeyValue = defaultKeyValue + "($keywordId)";
  // }
  // return defaultKeyValue.toString().trim();
}

initJsonFile() async {
  print("init josn");
  final String jsonString = await rootBundle.loadString('assets/staticjson/keyword_list.json');
  final list = json.decode(jsonString) as List;
  print("list==========================${list}");
  List<LocalLanguageResponse> finalList =
      list.map((jsonElement) => LocalLanguageResponse.fromJson(jsonElement)).toList();
  defaultLanguageDataKeys.clear();
  print("final list length finallist${finalList.length}");

  for (int index = 0; index < finalList.length; index++) {
    for (int i = 0; i < finalList[index].keywordData!.length; i++) {
      // print(
      //     "final list keywordData ${finalList[index].keywordData![i].keywordValue}");
      defaultLanguageDataKeys.add(ContentData(
          keywordId: finalList[index].keywordData![i].keywordId,
          keywordName: finalList[index].keywordData![i].keywordName,
          keywordValue: finalList[index].keywordData![i].keywordValue));
    }
  }
}

// DO NOT CHANGE

String getCountryCode() {
  String defaultCode = countryCode!;
  String selectedLang = getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguageCode);
  if (defaultServerLanguageData != null && defaultServerLanguageData!.length > 0) {
    for (int index = 0; index < defaultServerLanguageData!.length; index++) {
      if (selectedLang == defaultServerLanguageData![index].languageCode) {
        List<String> selectedCoutry = defaultServerLanguageData![index].countryCode!.split("-");
        if (selectedCoutry.length > 0) {
          defaultCode = selectedCoutry[1];
        }
      }
    }
  }

  return defaultCode;
}

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../delivery/fragment/DHomeFragment.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/screens/VerificationListScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../languageConfiguration/LanguageDataConstant.dart';
import '../../languageConfiguration/LanguageDefaultJson.dart';
import '../../languageConfiguration/ServerLanguageResponse.dart';
import '../../main.dart';
import '../../main/models/CityListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/LoginScreen.dart';
import '../../main/screens/WalkThroughScreen.dart';
import '../../main/utils/Constants.dart';
import '../../user/screens/DashboardScreen.dart';
import '../utils/Common.dart';
import '../utils/Images.dart';
import 'UserCitySelectScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("当前进入 splash_screen.dart 页面");
    init();
  }

  Future<void> init() async {
    String versionNo = await getStringAsync(CURRENT_LAN_VERSION, defaultValue: LanguageVersion);
    // Language version update is giving issues
    await getLanguageList("").then((value) {
      appStore.setThemeColor(value.themeColor!);
      appStore.updateTheme(colorFromHex(value.themeColor!));
      appStore.setIsAllowDeliveryMan(value.isAllowDeliveryMan ?? false);
      appStore.setLoading(false);
      if (value.status == true) {
        setValue(CURRENT_LAN_VERSION, value.currentVersionNo.toString());
        if (value.data!.length > 0) {
          defaultServerLanguageData = value.data;
          performLanguageOperation(defaultServerLanguageData);
          setValue(LanguageJsonDataRes, value.toJson());
          // Check if default language set from server
          bool isSetLanguage = getBoolAsync(IS_SELECTED_LANGUAGE_CHANGE, defaultValue: false);
          if (!isSetLanguage) {
            for (int i = 0; i < value.data!.length; i++) {
              if (value.data![i].isDefaultLanguage == 1) {
                setValue(SELECTED_LANGUAGE_CODE, value.data![i].languageCode);
                setValue(SELECTED_LANGUAGE_COUNTRY_CODE, value.data![i].countryCode);
                appStore.setLanguage(value.data![i].languageCode!, context: context);
                break;
              }
            }
          }
        } else {
          defaultServerLanguageData = [];
          selectedServerLanguageData = null;
          setValue(LanguageJsonDataRes, "");
        }
      } else {
        String getJsonData = getStringAsync(LanguageJsonDataRes, defaultValue: "");
        if (getJsonData.isNotEmpty) {
          ServerLanguageResponse languageSettings = ServerLanguageResponse.fromJson(json.decode(getJsonData.trim()));
          if (languageSettings.data!.length > 0) {
            defaultServerLanguageData = languageSettings.data;
            performLanguageOperation(defaultServerLanguageData);
          }
        }
      }
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
    Future.delayed(
      Duration(seconds: 1),
      () async {
        if (appStore.isLoggedIn && getIntAsync(USER_ID) != 0) {
          await getUserDetail(getIntAsync(USER_ID)).then((value) async {
            setValue(IS_VERIFIED_DELIVERY_MAN, !value.documentVerifiedAt.isEmptyOrNull);
            if (value.deliverymanVehicleHistory != null) {
              setValue(VEHICLE, value.deliverymanVehicleHistory![0].toJson());
            }
            appStore.setReferralCode(value.referralCode.validate());
            appStore.setUserType(value.userType.validate());

            if (value.deletedAt != null) {
              logout(context);
            } else {
              setValue(OTP_VERIFIED, value.otpVerifyAt != null);

              //update app version
              Future<PackageInfo> packageInfoFuture = PackageInfo.fromPlatform();
              final packageInfo = await packageInfoFuture;
              if (value.app_version.isEmptyOrNull || value.app_version != packageInfo.version) {
                await updateUserStatus({"id": getIntAsync(USER_ID), "app_version": packageInfo.version})
                    .then((value) {});
              }

              if (value.emailVerifiedAt.isEmptyOrNull ||
                  value.otpVerifyAt.isEmptyOrNull ||
                  (value.documentVerifiedAt.isEmptyOrNull && getStringAsync(USER_TYPE) == DELIVERY_MAN)) {
                VerificationListScreen().launch(context);
              } else if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
                if (getStringAsync(USER_TYPE) == CLIENT) {
                  DashboardScreen().launch(context, isNewTask: true);
                } else {
                  // DeliveryDashBoard().launch(context, isNewTask: true);
                  DHomeFragment().launch(context, isNewTask: true);
                }
              } else {
                UserCitySelectScreen().launch(context, isNewTask: true);
              }
            }
          }).catchError((e) {
            log(e);
          });
        } else {
          if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
            WalkThroughScreen().launch(context, isNewTask: true);
          } else {
            LoginScreen().launch(context, isNewTask: true);
          }
        }
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snap.hasData) {
            return Center(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  40.height,
                  Image.asset(ic_logo, height: 80, width: 80, fit: BoxFit.fill)
                      .cornerRadiusWithClipRRect(defaultRadius),
                  16.height,
                  Text(language.appName == "$defaultKeyNotFoundValue(9)" ? mAppName : language.appName,
                          style: boldTextStyle(size: 20), textAlign: TextAlign.center)
                      .expand(),
                  Text('v ${snap.data!.version.validate()}', style: secondaryTextStyle(size: 12)),
                  16.height,
                ],
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}

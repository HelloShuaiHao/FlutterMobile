import 'dart:convert';
import 'package:date_format/date_format.dart';
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
    String versionNo = await getStringAsync(CURRENT_LAN_VERSION,
        defaultValue: LanguageVersion);
    // Language version update is giving issues

    initJsonFile(); // 使用本地 JSON 文件初始化语言数据
    performLanguageOperation(defaultServerLanguageData); // 直接操作本地数据
    appStore.setLoading(false);

    Future.delayed(
      Duration(seconds: 1),
      () async {
        if (appStore.isLoggedIn && getIntAsync(USER_ID) != 0) {
          await getUserDetail(getIntAsync(USER_ID)).then((value) async {
            setValue(IS_VERIFIED_DELIVERY_MAN,
                !value.documentVerifiedAt.isEmptyOrNull);
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
              Future<PackageInfo> packageInfoFuture =
                  PackageInfo.fromPlatform();
              final packageInfo = await packageInfoFuture;
              if (value.app_version.isEmptyOrNull ||
                  value.app_version != packageInfo.version) {
                await updateUserStatus({
                  "id": getIntAsync(USER_ID),
                  "app_version": packageInfo.version
                }).then((value) {});
              }

              if (value.emailVerifiedAt.isEmptyOrNull ||
                  value.otpVerifyAt.isEmptyOrNull ||
                  (value.documentVerifiedAt.isEmptyOrNull &&
                      getStringAsync(USER_TYPE) == DELIVERY_MAN)) {
                VerificationListScreen().launch(context);
              } else if (CityModel.fromJson(getJSONAsync(CITY_DATA))
                  .name
                  .validate()
                  .isNotEmpty) {
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
                  Text(
                    mAppName,
                    style: boldTextStyle(size: 20),
                    textAlign: TextAlign.center,
                  ).expand(),
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

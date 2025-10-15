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
import '../../main.dart';
import '../../main/models/CityListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/LoginScreen.dart';
import '../../main/screens/WalkThroughScreen.dart';
import '../../main/utils/Constants.dart';
import '../../user/screens/DashboardScreen.dart';
import '../utils/Images.dart';
import 'UserCitySelectScreen.dart';
import '../../main/utils/storage.dart';

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
    await getStringAsync(CURRENT_LAN_VERSION, defaultValue: LanguageVersion);

    initJsonFile(); // 使用本地 JSON 文件初始化语言数据
    performLanguageOperation(defaultServerLanguageData); // 直接操作本地数据
    appStore.setLoading(false);

    Future.delayed(
      Duration(seconds: 1),
      () async {
        final storedUserId = getIntAsync(USER_ID);
        final hasToken = SpUtil.token.val.isNotEmpty;
        debugPrint(
            '[Splash] isLoggedIn=${appStore.isLoggedIn} userId=$storedUserId tokenLen=${SpUtil.token.val.length}');
        if (appStore.isLoggedIn && (storedUserId != 0 || hasToken)) {
          // 如果 userId 还没拿到但有 token，尝试延迟获取一次（可选）
          if (storedUserId == 0) {
            // 这里可以调用一个 /me 接口（如果存在），当前先直接进入主界面，后续再刷新用户资料
            debugPrint(
                '[Splash] userId missing but token present -> skip fetch, go home');
            DHomeFragment().launch(context, isNewTask: true);
            return;
          }
          await getUserDetail(storedUserId).then((value) async {
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
            debugPrint('[Splash] getUserDetail error -> fallback to home');
            DHomeFragment().launch(context, isNewTask: true);
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

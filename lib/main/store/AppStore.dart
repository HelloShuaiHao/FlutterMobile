import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobx/mobx.dart';

import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../languageConfiguration/AppLocalizations.dart';
import '../../languageConfiguration/BaseLanguage.dart';
import '../../languageConfiguration/LanguageDataConstant.dart';
import '../../main.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Constants.dart';
import '../utils/dynamic_theme.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoading = false;

  @observable
  bool isLoggedIn = false;

  @observable
  String userEmail = '';

  @observable
  int allUnreadCount = 0;

  @observable
  String selectedLanguage = "";

  @observable
  bool isDarkMode = false;

  @observable
  bool isFiltering = false;

  @observable
  String uid = '';

  @observable
  bool isOtpVerifyOnPickupDelivery = true;

  @observable
  String currencyCode = CURRENCY_CODE;

  @observable
  String currencySymbol = CURRENCY_SYMBOL;

  @observable
  num availableBal = 0;

  @observable
  int isVehicleOrder = 0;

  @observable
  String userProfile = '';

  @observable
  String currencyPosition = CURRENCY_POSITION_LEFT;

  @observable
  String invoiceCompanyName = mInvoiceCompanyName;

  @observable
  String invoiceContactNumber = mInvoiceContactNumber;

  @observable
  String invoiceAddress = mInvoiceAddress;
  @observable
  String invoiceCompanyLogo = '';
  @observable
  String distanceUnit = '';
  @observable
  String userType = '';
  @observable
  String copyRight = '';
  @observable
  String siteEmail = '';
  @observable
  bool isAllowDeliveryMan = true;
  @observable
  String referralCode = '';
  @observable
  String maxAmountEarning = '';
  @observable
  String themeColor = '0xff00000';

  // @observable
  // String orderTrackingIdPrefixId = 'DOCS';
  @observable
  String isInsuranceAllowed = '0';
  @observable
  String insurancePercentage = '0';
  @observable
  String insuranceDescription = '';
  @observable
  String claimDuration = '';

  @action
  Future<void> setLoading(bool val) async {
    isLoading = val;
  }

  @observable
  String isBiddingEnabled = '0';

  @action
  Future<void> setIsBiddingStatus(String val) async {
    isBiddingEnabled = val;
  }

  @action
  Future<void> setLogin(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(IS_LOGGED_IN, val);
  }

  @action
  Future<void> setUserEmail(String val, {bool isInitialization = false}) async {
    userEmail = val;
  }

  @action
  Future<void> setUId(String val, {bool isInitializing = false}) async {
    uid = val;
    if (!isInitializing) await setValue(UID, val);
  }

  @action
  Future<void> setAllUnreadCount(int val) async {
    allUnreadCount = val;
  }

  @action
  Future<void> setOtpVerifyOnPickupDelivery(bool val) async {
    isOtpVerifyOnPickupDelivery = val;
  }

  @action
  Future<void> setCurrencyCode(String val) async {
    currencyCode = val;
  }

  @action
  Future<void> setCurrencySymbol(String val) async {
    currencySymbol = val;
  }

  @action
  Future<void> setCurrencyPosition(String val) async {
    currencyPosition = val;
  }

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    setDefaultLocate();
    selectedLanguage = aCode;
    if (context != null) language = BaseLanguage.of(context)!;
    language = (await AppLocalizations().load(Locale(selectedLanguage)));
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = viewLineColor;

      defaultLoaderBgColorGlobal = Colors.black26;
      defaultLoaderAccentColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = ColorUtils.colorPrimary;
      shadowColorGlobal = Colors.black12;
    }
  }

  @action
  Future<void> setFiltering(bool val) async {
    isFiltering = val;
  }

  @action
  void setInvoiceCompanyName(String val) {
    invoiceCompanyName = val;
  }

  @action
  void setInvoiceCompanyLogo(String val) {
    invoiceCompanyLogo = val;
  }

  @action
  void setInvoiceContactNumber(String val) {
    invoiceContactNumber = val;
  }

  @action
  void setCompanyAddress(String val) {
    invoiceAddress = val;
  }

  @action
  Future<void> setUserProfile(String val, {bool isInitializing = false}) async {
    userProfile = val;
    if (!isInitializing) await setValue(USER_PROFILE_PHOTO, val);
  }

  @action
  void setDistanceUnit(String val) {
    distanceUnit = val;
  }

  @action
  void setUserType(String val) {
    userType = val;
  }

  @action
  Future<void> setCopyRight(String val) async {
    copyRight = val;
  }

  @action
  Future<void> setSiteEmail(String val) async {
    siteEmail = val;
  }

  @action
  Future<void> setIsAllowDeliveryMan(bool val) async {
    isAllowDeliveryMan = val;
  }

  @action
  Future<void> setReferralCode(String val) async {
    referralCode = val;
  }

  @action
  Future<void> setMaxAmountPerMonth(String val) async {
    maxAmountEarning = val;
  }

  @action
  Future<void> setThemeColor(String val) async {
    themeColor = val;
  }

  // @action
  // Future<void> setOrderTrackingIdPrefix(String val) async {
  //   orderTrackingIdPrefixId = val;
  // }

  @action
  Future<void> setInsurancePercentage(String val) async {
    insurancePercentage = val;
  }

  @action
  Future<void> setIsInsuranceAllowed(String val) async {
    isInsuranceAllowed = val;
  }

  @action
  Future<void> setInsuranceDescription(String val) async {
    insuranceDescription = val;
  }

  @action
  Future<void> setClaimDuration(String val) async {
    claimDuration = val;
  }

  @observable
  ThemeData lightTheme = ThemeData(
    primarySwatch: createMaterialColor(ColorUtils.colorPrimary),
    primaryColor: ColorUtils.colorPrimary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.lato().fontFamily,
    iconTheme: IconThemeData(color: Colors.black),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.grey,
    dividerColor: dividerColor,
    cardColor: Colors.white,
    tabBarTheme: TabBarTheme(labelColor: Colors.black),
    appBarTheme: AppBarTheme(
        color: ColorUtils.colorPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent)),
    dialogTheme: DialogTheme(shape: dialogShape()),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
    colorScheme: ColorScheme.light(
      primary: ColorUtils.colorPrimary,
    ),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  @observable
  ThemeData darkTheme = ThemeData(
    primarySwatch: createMaterialColor(ColorUtils.colorPrimary),
    primaryColor: ColorUtils.colorPrimary,
    scaffoldBackgroundColor: ColorUtils.scaffoldColorDark,
    fontFamily: GoogleFonts.lato().fontFamily,
    iconTheme: IconThemeData(color: Colors.white),
    dialogBackgroundColor: ColorUtils.scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: ColorUtils.scaffoldSecondaryDark,
    tabBarTheme: TabBarTheme(labelColor: Colors.white),
    appBarTheme: AppBarTheme(
      color: ColorUtils.scaffoldSecondaryDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    ),
    dialogTheme: DialogTheme(shape: dialogShape()),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: ColorUtils.appButtonColorDark),
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: ColorUtils.appButtonColorDark),
    colorScheme: ColorScheme.dark(
      primary: ColorUtils.colorPrimary,
    ),
  ).copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ));

  @action
  void updateTheme(Color newColor) {
    ColorUtils.updateColors(appStore.themeColor);
    lightTheme = ThemeData(
      primarySwatch: createMaterialColor(newColor),
      primaryColor: newColor,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.lato().fontFamily,
      iconTheme: IconThemeData(color: Colors.black),
      dialogBackgroundColor: Colors.white,
      unselectedWidgetColor: Colors.grey,
      dividerColor: dividerColor,
      cardColor: Colors.white,
      tabBarTheme: TabBarTheme(labelColor: Colors.black),
      appBarTheme: AppBarTheme(
          color: newColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.transparent)),
      dialogTheme: DialogTheme(shape: dialogShape()),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
      colorScheme: ColorScheme.light(
        primary: newColor,
      ),
    ).copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
    darkTheme = ThemeData(
      primarySwatch: createMaterialColor(newColor),
      primaryColor: newColor,
      scaffoldBackgroundColor: ColorUtils.scaffoldColorDark,
      fontFamily: GoogleFonts.lato().fontFamily,
      iconTheme: IconThemeData(color: Colors.white),
      dialogBackgroundColor: ColorUtils.scaffoldSecondaryDark,
      unselectedWidgetColor: Colors.white60,
      dividerColor: Colors.white12,
      cardColor: ColorUtils.scaffoldSecondaryDark,
      tabBarTheme: TabBarTheme(labelColor: Colors.white),
      appBarTheme: AppBarTheme(
        color: ColorUtils.scaffoldSecondaryDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      ),
      dialogTheme: DialogTheme(shape: dialogShape()),
      snackBarTheme:
          SnackBarThemeData(backgroundColor: ColorUtils.appButtonColorDark),
      bottomSheetTheme:
          BottomSheetThemeData(backgroundColor: ColorUtils.appButtonColorDark),
      colorScheme: ColorScheme.dark(
        primary: newColor,
      ),
    ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ));
  }
}

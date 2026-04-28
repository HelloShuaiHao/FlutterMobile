import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mighty_delivery/main/background_geolocation_headless.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/logutil.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../main/services/OrdersMessageService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main/models/models.dart';
import '../main/screens/SplashScreen.dart';
import '../main/utils/Constants.dart';
import '../main/utils/daily_logout_policy.dart';
import '../main/utils/location_access_policy.dart';
import '../main/utils/location_event_payload.dart';
import 'extensions/common.dart';
import 'extensions/shared_pref.dart';
import 'languageConfiguration/AppLocalizations.dart';
import 'languageConfiguration/BaseLanguage.dart';
import 'languageConfiguration/LanguageDataConstant.dart';
import 'languageConfiguration/LanguageDefaultJson.dart';
import 'languageConfiguration/ServerLanguageResponse.dart';
import 'main/models/FileModel.dart';
import 'main/services/AuthServices.dart';
import 'main/services/NotificationService.dart';
import 'main/services/UserServices.dart';
import 'main/store/AppStore.dart';
import 'main/network/RestApis.dart';
import 'main/utils/Common.dart';
import 'main/utils/firebase_options.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'main/services/LocationTrackingService.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late SharedPreferences sharedPreferences;
AppStore appStore = AppStore();
late BaseLanguage language;
// Added by SK
LanguageJsonData? selectedServerLanguageData;
List<LanguageJsonData>? defaultServerLanguageData = [];

UserService userService = UserService();
//ChatMessageService chatMessageService = ChatMessageService();
AuthServices authService = AuthServices();
OrdersMessageService ordersMessageService = OrdersMessageService();
NotificationService notificationService = NotificationService();
late List<FileModel> fileList = [];
bool isCurrentlyOnNoInternet = false;
StreamSubscription<Position>? positionStream;
bool mIsEnterKey = false;
String mSelectedImage = "assets/default_wallpaper.png";

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp().then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });
  } else {
    await Firebase.initializeApp(
      name: "dev project",
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });
  }

  await LogUtil.init();
  await GetStorage.init();
  // 重要
  await HttpUtils.init(unAuthHandle: () {
    // 退出登录
    // cl
  });
  // -----------------

  // await initialize(aLocaleLanguageList: languageList());
  sharedPreferences = await SharedPreferences.getInstance();
  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE,
      defaultValue: defaultLanguageCode));
  try {
    appStore.setLogin(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
    appStore.setUserEmail(getStringAsync(USER_EMAIL), isInitialization: true);
    appStore.setUserProfile(getStringAsync(USER_PROFILE_PHOTO),
        isInitializing: true);
    FilterAttributeModel? filterData =
        FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    appStore.setFiltering(filterData.orderStatus != null ||
        !filterData.fromDate.isEmptyOrNull ||
        !filterData.toDate.isEmptyOrNull);
    print("===========setLanguage${appStore.selectedLanguage}");
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == appThemeMode.themeModeLight) {
      appStore.setDarkMode(false);
    } else if (themeModeIndex == appThemeMode.themeModeDark) {
      appStore.setDarkMode(true);
    }
    initJsonFile();
    oneSignalSettings();
  } catch (e) {
    print("error========${e.toString()}");
  }

  // 接受所有证书
  HttpOverrides.global = MyHttpOverrides();

  // ⭐ 关键：注册 Headless 回调（必须在 runApp 之前）
  print('[MAIN] Registering headless task...');
  bg.BackgroundGeolocation.registerHeadlessTask(
      backgroundGeolocationHeadlessTask);
  print('[MAIN] ✅ Headless task registered');

  // ⭐ 启动时无条件启动位置追踪（如果有 vehicleId 才会上传）
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // 等待 1 秒，让 Headless boot 事件完成处理
    await Future.delayed(const Duration(seconds: 1));
    try {
      final isLoggedIn = getBoolAsync(IS_LOGGED_IN);
      final hasToken = getStringAsync(USER_TOKEN).isNotEmpty;
      final isDeliveryMan = getStringAsync(USER_TYPE) == DELIVERY_MAN;

      if (!(isLoggedIn && hasToken && isDeliveryMan)) {
        print(
            '[MAIN] Skip location tracking on launch: isLoggedIn=$isLoggedIn hasToken=$hasToken isDeliveryMan=$isDeliveryMan');
        await LocationTrackingService.instance.stopTracking();
        return;
      }

      print('[MAIN] Starting location tracking on app launch...');
      // 先检查冷启动恢复
      await LocationTrackingService.instance.ensureColdStartInit();
      // 无条件启动追踪（内部会检查 vehicleId 决定是否上传）
      await LocationTrackingService.instance.startTracking(
        identityUserId: getStringAsync(USER_TOKEN),
      );
      print('[MAIN] ✅ Location tracking started on app launch');
    } catch (e) {
      print('[MAIN] Location tracking start error: $e');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? color;
  Timer? _dailyLogoutTimer;
  Timer? _locationAccessTimer;
  final ValueNotifier<bool> _isLocationBlockedNotifier = ValueNotifier(false);
  bool _isForcingDailyLogout = false;
  bool _gpsLostSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保在 MaterialApp 构建完成后调用
      try {
        final context = getContext;
        print("Context initialized: $context");
      } catch (e) {
        print("Error initializing context: $e");
      }
    });

    init();
    _scheduleDailyLogoutCheck();
    _startLocationAccessMonitor();
    //  getColor();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _forceDailyLogoutIfNeeded();
      _scheduleDailyLogoutCheck();
      _checkLocationAccess();
    }
  }

  DateTime? _lastDailyLogoutAt() {
    final raw = getStringAsync(lastDailyForcedLogoutAtKey);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  void _scheduleDailyLogoutCheck() {
    _dailyLogoutTimer?.cancel();
    final now = DateTime.now();
    final next = nextDailyLogoutAt(now);
    _dailyLogoutTimer = Timer(next.difference(now), () async {
      await _forceDailyLogoutIfNeeded();
      _scheduleDailyLogoutCheck();
    });
  }

  Future<void> _forceDailyLogoutIfNeeded() async {
    if (_isForcingDailyLogout || !getBoolAsync(IS_LOGGED_IN)) return;

    final now = DateTime.now();
    if (!shouldForceDailyLogout(now: now, lastLogoutAt: _lastDailyLogoutAt())) {
      return;
    }

    _isForcingDailyLogout = true;
    try {
      await setValue(lastDailyForcedLogoutAtKey, now.toIso8601String());
      await LocationTrackingService.instance.stopTracking();
      final context = navigatorKey.currentContext;
      if (context != null) {
        await logout(context);
      } else {
        await appStore.setLogin(false);
        await setValue(IS_LOGGED_IN, false);
      }
      print('[MAIN] Forced daily logout at ${now.toIso8601String()}');
    } catch (e) {
      print('[MAIN] Forced daily logout failed: $e');
    } finally {
      _isForcingDailyLogout = false;
    }
  }

  void _startLocationAccessMonitor() {
    _locationAccessTimer?.cancel();
    _checkLocationAccess();
    _locationAccessTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkLocationAccess(),
    );
  }

  bool _shouldEnforceLocationAccess() {
    return getBoolAsync(IS_LOGGED_IN) &&
        getStringAsync(USER_TOKEN).isNotEmpty &&
        getStringAsync(USER_TYPE) == DELIVERY_MAN;
  }

  Future<void> _checkLocationAccess() async {
    if (!_shouldEnforceLocationAccess()) {
      _gpsLostSent = false;
      _isLocationBlockedNotifier.value = false;
      return;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final permissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      final blocked = isLocationAccessBlocked(
        permissionGranted: permissionGranted,
        serviceEnabled: serviceEnabled,
      );
      final wasBlocked = _isLocationBlockedNotifier.value;

      if (blocked) {
        _isLocationBlockedNotifier.value = true;
        if (!_gpsLostSent) {
          _gpsLostSent = true;
          await LocationTrackingService.instance
              .sendCurrentLocationEvent(LocationEventAddress.gpsLost);
        }
        return;
      } else {
        _gpsLostSent = false;
        if (wasBlocked) {
          await LocationTrackingService.instance.startTracking(
            identityUserId: getStringAsync(USER_TOKEN),
          );
        }
      }

      _isLocationBlockedNotifier.value = false;
    } catch (e) {
      print('[MAIN] Location access check failed: $e');
    }
  }

  // getColor() async {
  //   await getLanguageList(0).then((value) {
  //     color = value.themeColor;
  //     appStore.setThemeColor(value.themeColor!);
  //     appStore.updateTheme(colorFromHex(value.themeColor!));
  //
  //     setState(() {});
  //   });
  // }

  void init() async {
    // _connectivitySubscription =
    //     Connectivity().onConnectivityChanged.listen((e) {
    //   if (e.contains(ConnectivityResult.none)) {
    //     log('not connected');
    //     isCurrentlyOnNoInternet = true;
    //     push(NoInternetScreen());
    //   } else {
    //     if (isCurrentlyOnNoInternet) {
    //       pop();
    //       isCurrentlyOnNoInternet = false;
    //       //   nb.toast(language.internetIsConnected);
    //     }
    //     log('connected');
    //   }
    // });
  }

  @override
  void dispose() {
    _dailyLogoutTimer?.cancel();
    _locationAccessTimer?.cancel();
    _isLocationBlockedNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    _connectivitySubscription.cancel();
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isLocationBlockedNotifier,
              builder: (context, blocked, _) {
                return Stack(
                  children: [
                    child!,
                    if (blocked) const _LocationAccessBlockedOverlay(),
                  ],
                );
              },
            ),
          );
        },
        title: mAppName,
        debugShowCheckedModeBanner: false,
        theme: appStore.lightTheme,
        darkTheme: appStore.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SplashScreen(),
        // home: MyTestHomePage(title: 'Background Geolocation Demo'), // 修改启动界面为 MyTestHomePage
        // home: TestVehicleScreen(),
        // home: DashboardScreen(),
        // home: PickupFromWarehouseWidget(),
        // home: WarehouseOrderGroupWidgetTest(),
        // home: DeliveryWidget(),

        supportedLocales: getSupportedLocales(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CountryLocalizations.delegate,
          AppLocalizations(),
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(
            appStore.selectedLanguage.validate(value: defaultLanguageCode)),
      );
    });
  }
}

class _LocationAccessBlockedOverlay extends StatelessWidget {
  const _LocationAccessBlockedOverlay();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.location_off, size: 44),
                  const SizedBox(height: 16),
                  const Text(
                    'Location access is required',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please enable location permission and device location services to continue using the app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: Geolocator.openLocationSettings,
                    child: const Text('Open Location Settings'),
                  ),
                  TextButton(
                    onPressed: Geolocator.openAppSettings,
                    child: const Text('Open App Settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// 禁用证书 禁用于dev环境
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // 接受所有证书（不安全，仅用于开发调试）
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }
}

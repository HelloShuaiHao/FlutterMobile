//region App name
import 'package:flutter/material.dart';
import '../../extensions/extension_util/int_extensions.dart';

import '../../extensions/colors.dart';
import '../../extensions/common.dart';

const mAppName = 'LPT';
//endregion

//region Baseurl
//Note: Domain url is where you uploaded your laravel code

//test
const DOMAIN_URL =
    'https://meetmighty.com/mobile/delivery-admin'; // Don't add slash at the end of the url
// Don't add slash at the end of the url
//endregion

//region Google map key
const googleMapAPIKey = 'AIzaSyCGRSk7rUwHzf8vhRIzPp3bmiJDaRt8Ev4';
//endregion

// region onesignal keys
const mOneSignalAppId = 'YOUR ONE SIGNAL APP ID';
const mOneSignalRestKey = 'YOUR ONE SIGNAL REST KEY';
const mOneSignalChannelId = 'YOUR ONE SIGNAL CHANNEL ID';
//endregion

//region  firebase data  for firebase_options.dart
const String FIREBASE_API_KEY = "FIREBASE_API_KEY";
const String FIREBASE_APP_ID = "FIREBASE_APP_ID";
const String FIREBASE_MESSAGING_SENDER_ID = "FIREBASE_MESSAGING_SENDER_ID";
const String FIREBASE_PROJECT_ID = "FIREBASE_PROJECT_ID";
const String FIREBASE_STORAGE_BUCKET = "FIREBASE_STORAGE_BUCKET";

//region  firebase data  for firebase_options.dart FOR IOS APP USE
const String FIREBASE_APP_ID_IOS = "FIREBASE_APP_ID_IOS";

//for ios
const String ANDROID_CLIENT_ID = 'ANDROID_CLIENT_ID';
const String IOS_CLIENT_ID = 'IOS_CLIENT_ID';
const String IOS_BUNDLE_ID = 'IOS_BUNDLE_ID';
//endregion

//region languages and phone code
//const defaultLanguageCode = "en";
const defaultPhoneCode = '+65';
//endregion

//region country symnbol and code
const CURRENCY_SYMBOL = '\$';
const CURRENCY_CODE = 'INR';
//endregion
const mPrivacyPolicy = "$DOMAIN_URL/privacypolicy";
const mTermAndCondition = "$DOMAIN_URL/termofservice";
//endregion

const mInvoiceCompanyName = 'Roberts Private Limited';
const mInvoiceAddress = 'Sarah Street 9, Beijing, Ahmedabad';
const mInvoiceContactNumber = '+91 9845345665';
double defaultRadius = 10;
const THEME_MODE_INDEX = 'theme_mode_index';
double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;
double? defaultInkWellRadius;
Color? defaultInkWellSplashColor;
Color? defaultInkWellHoverColor;
Color? defaultInkWellHighlightColor;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
double defaultAppButtonElevation = 4.0;
double defaultAppBarElevation = 1.0;
int passwordLengthGlobal = 6;
PageRouteAnimation? pageRouteAnimationGlobal;
bool enableAppButtonScaleAnimationGlobal = true;
int? appButtonScaleAnimationDurationGlobal;
Duration pageRouteTransitionDurationGlobal = 400.milliseconds;
int defaultElevation = 4;
var customDialogHeight = 140.0;
var customDialogWidth = 220.0;
double defaultAppButtonRadius = 10.0;
double defaultBlurRadius = 4.0;
double defaultSpreadRadius = 0.5;
Color defaultLoaderBgColorGlobal = Colors.white;
Color? defaultLoaderAccentColorGlobal;
bool forceEnableDebug = false;
double textBoldSizeGlobal = 16;
double textPrimarySizeGlobal = 16;
double textSecondarySizeGlobal = 14;
String? fontFamilyBoldGlobal;
String? fontFamilyPrimaryGlobal;
String? fontFamilySecondaryGlobal;
FontWeight fontWeightBoldGlobal = FontWeight.bold;
FontWeight fontWeightPrimaryGlobal = FontWeight.normal;
FontWeight fontWeightSecondaryGlobal = FontWeight.normal;
ShapeBorder? defaultDialogShape;
//region contact num lenghth
const minContactLength = 8;
const maxContactLength = 15;
const digitAfterDecimal = 2;
//endregion

//region url
const mBaseUrl = "$DOMAIN_URL/api/";
//endregion

//region bank list
const BANK_LIST = [
  'HDFC',
  'Bank of baroda',
  'State bank of india',
  'Bank of India',
  'Indian Bank',
];
//endregion

//region SharedReference keys
const IS_LOGGED_IN = 'IS_LOGIN';
const IS_FIRST_TIME = 'IS_FIRST_TIME';

const USER_ID = 'USER_ID';
const NAME = 'NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_TOKEN = 'USER_TOKEN';
const USER_CONTACT_NUMBER = 'USER_CONTACT_NUMBER';
const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_TYPE = 'USER_TYPE';
const USER_NAME = 'USER_NAME';
const USER_PASSWORD = 'USER_PASSWORD';
const USER_ADDRESS = 'USER_ADDRESS';
const STATUS = 'STATUS';
const PLAYER_ID = 'PLAYER_ID';
const FILTER_DATA = 'FILTER_DATA';
const UID = 'UID';
const IS_VERIFIED_DELIVERY_MAN = 'IS_VERIFIED_DELIVERY_MAN';
const RECENT_ADDRESS_LIST = 'RECENT_ADDRESS_LIST';
const OTP_VERIFIED = "OTP_VERIFIED";
const REMEMBER_ME = 'REMEMBER_ME';
const COUNTRY_ID = 'COUNTRY_ID';
const COUNTRY_DIAL_CODE = 'COUNTRY_DIAL_CODE';
const COUNTRY_DATA = 'COUNTRY_DATA';
const CITY_ID = 'City';
const CITY_DATA = 'CITY_DATA';
const VEHICLE = 'VEHICLE';

const EMAIL_VERIFIED = 'EMAIL_VERIFIED_AT';
const IS_EMAIL_VERIFICATION = 'IS_EMAIL_VERIFICATION';
const LOGIN_TYPE = 'LOGIN_TYPE';
//endregion

//region login type
const LoginTypeGoogle = 'google';
const LoginTypeApple = 'apple';
//endregion

//region user role
const CLIENT = 'client';
const DELIVERY_MAN = 'delivery_man';
const ADMIN = 'admin';
const DEMO_ADMIN = 'demo+admin';
//endregion

//region charge type
const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';
//endregion

//region payment type
const PAYMENT_TYPE_STRIPE = 'stripe';
const PAYMENT_TYPE_RAZORPAY = 'razorpay';
const PAYMENT_TYPE_PAYSTACK = 'paystack';
const PAYMENT_TYPE_FLUTTERWAVE = 'flutterwave';
const PAYMENT_TYPE_PAYPAL = 'paypal';
const PAYMENT_TYPE_PAYTABS = 'paytabs';
const PAYMENT_TYPE_MERCADOPAGO = 'mercadopago';
const PAYMENT_TYPE_PAYTM = 'paytm';
const PAYMENT_TYPE_MYFATOORAH = 'myfatoorah';
const PAYMENT_TYPE_CASH = 'cash';
const PAYMENT_TYPE_WALLET = 'wallet';
//endregion

//region payment status
const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';
const PAYMENT_ON_DELIVERY = "on_delivery";
const PAYMENT_ON_PICKUP = "on_pickup";
//end region

//region keys
const RESTORE = 'restore';
const FORCE_DELETE = 'forcedelete';
const DELETE_USER = 'deleted_at';
const DECLINE = 'decline';
const REQUESTED = 'requested';
const APPROVED = 'approved';
const COMPLETED = 'completed';
//endregion

//region OrderStatus
const ORDER_CREATED = 'create';
const ORDER_ACCEPTED = 'active';
const ORDER_CANCELLED = 'cancelled';
const ORDER_DELAYED = 'delayed';
const ORDER_ASSIGNED = 'courier_assigned';
const ORDER_ARRIVED = 'courier_arrived';
const ORDER_PICKED_UP = 'courier_picked_up';
const ORDER_DELIVERED = 'completed';
const ORDER_DRAFT = 'draft';
const ORDER_DEPARTED = 'courier_departed';
const ORDER_TRANSFER = 'courier_transfer';
const ORDER_PAYMENT = 'payment_status_message';
const ORDER_FAIL = 'failed';
const ORDER_SHIPPED = 'shipped';
const ORDER_PICK_UP_TIME = 'pickup_time';
const ORDER_DELIVERY_TIME = 'delivery_time';

const TEST_A = 'test_a';
const TEST_B = 'test_b';
const TEST_C = 'test_c';
//endregion

// region CountName
const TODAY_ORDER = 'todayOrder';
const REMAINING_ORDER = 'remainingOrder';
const COMPLETED_ORDER = 'completedOrder';
const INPROGRESS_ORDER = 'inProgressOrder';
const TOTAL_EARNING = 'commission';
const WALLET_BALANCE = 'walletBalance';
const PENDING_WITHDRAW_REQUEST = 'pendingWithdReq';
const COMPLETED_WITHDRAW_REQUEST = 'completedWithReq';
//endregion

//region transaction keys
const TRANSACTION_ORDER_FEE = "order_fee";
const TRANSACTION_TOPUP = "topup";
const TRANSACTION_ORDER_CANCEL_CHARGE = "order_cancel_charge";
const TRANSACTION_ORDER_CANCEL_REFUND = "order_cancel_refund";
const TRANSACTION_CORRECTION = "correction";
const TRANSACTION_COMMISSION = "commission";
const TRANSACTION_WITHDRAW = "withdraw";
//endregion

const stripeURL = 'https://api.stripe.com/v1/payment_intents';

//region appTheme
class AppThemeMode {
  final int themeModeLight = 0;
  final int themeModeDark = 1;
  final int themeModeSystem = 2;
}

/* Theme Mode Type */
const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

AppThemeMode appThemeMode = AppThemeMode();
//endregion
/* Theme Mode Type */

//region FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const ORDERS_COLLECTION = "orders";
const ORDERS_MESSAGES_COLLECTION = "orderMessages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const CHAT_DATA_IMAGES = "chatImages";
//endregion

//region chat
const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;
const TEXT = "TEXT";
const IMAGE = "IMAGE";
const VIDEO = "VIDEO";
const AUDIO = "AUDIO";

List<String> rtlLanguage = ['ar', 'ur'];

enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
}

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}

//endregion
const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";
const INSURANCE_CHARGE = "insurance_charges";

//region Currency Position
const CURRENCY_POSITION_LEFT = 'left';
const CURRENCY_POSITION_RIGHT = 'right';
//endregion
const CREDIT = 'credit';

const mStripeIdentifier = 'IN';
const DISTANCE_UNIT_KM = 'km';
const DISTANCE_UNIT_MILE = 'mile';
const double MILES_PER_KM = 0.621371;
const String CITY_NOT_FOUND_EXCEPTION = "City has been not found.";

//store checker constants
const PLAY_STORE = "Play Store";
const GOOGLE_PACKAGE_INSTALLER = "Google Package installer";
const RUSTORE = "RuStore";
const LOCAL_SOURCE = "Local Source";
const AMAZON_STORE = "Amazon Store";
const HUAWEI_APP_GALLERY = "Huawei App Gallery";
const SAMSUNG_GALAXY_STORE = "Samsung Galaxy Store";
const SAMSUNG_SMART_SWITCH_MOBILE = "Samsung Smart Switch Mobile";
const XIAOMI_GET_APPS = "Xiaomi Get Apps";
const OPPO_APP_MARKET = "Oppo App Market";
const VIVO_APP_STORE = "Vivo App Store";
const OTHER_SOURCE = "Other Source";
const APP_STORE = "App Store";
const TEST_FLIGHT = "Test Flight";
const UNKNOWN_SOURCE = "Unknown Source";
String? countryCode = "IN";

const CURRENT_LATITUDE = 'CURRENT_LATITUDE';
const CURRENT_LONGITUDE = 'CURRENT_LONGITUDE';
const CURRENT_CITY = 'CURRENT_CITY';

const FONT_SIZE_PREF = 'FONT_SIZE_PREF';
const int cancelOrderDuration = 60;
const STATUS_PENDING = 'pending';
const STATUS_IN_REVIEW = 'inreview';
const STATUS_REJECTED = 'reject';

// apex
const ACCESS_TOKEN = 'ACCESS_TOKEN';
const MY_DOMAIN_URL =
    'https://localhost'; // Don't add slash at the end of the url
const MY_IDENTITY_PORT = '7500';
const MY_MOBILE_PORT = '7013';
const MY_Base_Url = "$MY_DOMAIN_URL" + ":$MY_IDENTITY_PORT/api/";
const MY_SIGNALR_BASE_URL =
    "$MY_DOMAIN_URL" + ":$MY_MOBILE_PORT" + "/signalr-hubs/messaging";

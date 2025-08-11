import 'dart:convert';
import 'dart:core';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/colors.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/CouponListResponseModel.dart';
import '../../main/screens/CouponListScreen.dart';
import '../../main/utils/DataProviders.dart';
import '../../user/screens/insurance_details_screen.dart';
import '../../user/screens/packaging_symbols_info.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/components/OrderAmountSummaryWidget.dart';
import '../../main/components/PickAddressBottomSheet.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/CreateOrderDetailModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/PaymentModel.dart';
import '../../main/models/TotalAmountResponse.dart';
import '../../main/models/VehicleModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/components/CreateOrderConfirmationDialog.dart';
import '../../user/screens/DashboardScreen.dart';
import 'PaymentScreen.dart';

class CreateOrderScreen extends StatefulWidget {
  final OrderData? orderData;

  CreateOrderScreen({this.orderData});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CityDetail? cityData;
  List<StaticDetails> parcelTypeList = [];

  TextEditingController parcelTypeCont = TextEditingController();
  TextEditingController weightController = TextEditingController(text: '1');
  TextEditingController totalParcelController =
      TextEditingController(text: '1');

  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPersonNameCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController pickInstructionCont = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  TextEditingController pickFromTimeController = TextEditingController();
  TextEditingController pickToTimeController = TextEditingController();

  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController deliverPersonNameCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();
  TextEditingController deliverInstructionCont = TextEditingController();
  TextEditingController deliverDateController = TextEditingController();
  TextEditingController deliverFromTimeController = TextEditingController();
  TextEditingController deliverToTimeController = TextEditingController();
  TextEditingController insuranceAmountController = TextEditingController();

  FocusNode pickPhoneFocus = FocusNode();
  FocusNode pickPersonNameFocus = FocusNode();
  FocusNode pickDesFocus = FocusNode();
  FocusNode pickInstructionFocus = FocusNode();
  FocusNode deliveryPesonNameFocus = FocusNode();
  FocusNode deliverPhoneFocus = FocusNode();
  FocusNode deliveryInstructionFocus = FocusNode();
  FocusNode deliverDesFocus = FocusNode();

  String deliverCountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  DateTime? pickFromDateTime,
      pickToDateTime,
      deliverFromDateTime,
      deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat, pickLong, deliverLat, deliverLong;

  int selectedTabIndex = 0;

  bool isDeliverNow = true;
  int isSelected = 1;

  bool? isCash = false;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;
  TotalAmountResponse? totalAmountResponse;

  DateTime? currentBackPressTime;
  num totalDistance = 0;
  List<UseraddressDetail> addressList = [];
  UseraddressDetail? pickAddressData;
  UseraddressDetail? deliveryAddressData;
  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;
  num insuranceAmount = 0.0;
  num vehicleCharge = 0.0;

  List<PaymentModel> mPaymentList = getPaymentItems();

  List<ExtraChargeRequestModel> extraChargeList = [];

  int? selectedVehicle;
  List<VehicleDetail> vehicleList = [];
  VehicleData? vehicleData;
  List<Marker> markers = [];
  GoogleMapController? googleMapController;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final List<Map<String, String>> selectedPackingSymbols = [];
  final List<Map<String, String>> packingSymbolsItems = getPackagingSymbols();
  int insuranceSelectedOption = 1;
  List<String> appBarTitleList = [
    language.createOrder,
    language.pickupInformation,
    language.deliveryInformation,
    language.reviewRoute,
    language.details
  ];
  CouponListResponseModel? couponListResponseModel;
  CouponModel? selectedCoupon;
  bool isAppliedCoupon = false;
  bool biddingSelectedOption = false;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    afterBuildCreated(() {
      init();
    });
  }

  getStaticDetailsForOrder() async {
    await getCreateOrderDetails(getIntAsync(CITY_ID)).then((value) async {
      appStore.setLoading(false);
      await setValue(CITY_DATA, value.cityDetail!.toJson());
      cityData = value.cityDetail;
      value.useraddressDetail!.forEach((element) {
        addressList.add(element);
      });
      if (addressList.isNotEmpty) {
        pickAddressData = addressList.first;
        deliveryAddressData = addressList.first;
      }
      List<UseraddressDetail> list = [];
      addressList.forEach((e) {
        list.add(e);
      });
      setValue(RECENT_ADDRESS_LIST,
          list.map((element) => jsonEncode(element)).toList());
      vehicleList.clear();
      vehicleList = value.vehicleDetail!;
      if (value.vehicleDetail!.isNotEmpty)
        selectedVehicle = value.vehicleDetail![0].id;
      parcelTypeList.clear();
      parcelTypeList.addAll(value.staticDetails!);
      appStore.setCurrencyCode(
          value.appSettingDetail!.currencyCode ?? CURRENCY_CODE);
      appStore.setCurrencySymbol(
          value.appSettingDetail!.currency ?? CURRENCY_SYMBOL);
      appStore.setCurrencyPosition(
          value.appSettingDetail!.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.setIsInsuranceAllowed(
          value.appSettingDetail!.isInsuranceAllow.toString());
      appStore.setInsurancePercentage(
          value.appSettingDetail!.insurancePercentage.toString());
      appStore.setInsuranceDescription(
          value.appSettingDetail!.insuranceDescription.toString());
      appStore.setIsBiddingStatus(
          value.appSettingDetail!.isBiddingEnabled.toString());
      appStore.isVehicleOrder = value.appSettingDetail!.isVehicleInOrder ?? 0;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  getCouponList() async {
    try {
      await getCouponListApi(1).then((value) async {
        couponListResponseModel = value;
        if (value.data != null && value.data!.isNotEmpty) {
          selectedCoupon = value.data!.first;
          log("SELECTED COUPON LEN::::::: ${selectedCoupon}");
        } else {
          selectedCoupon = null;
          log("VALUE OF SELECTEDCOUPON IS::::::::::: ${selectedCoupon}");
        }
      });
    } catch (e, s) {
      log("COUPON ERROR ${e} STACK TRACE ${s}");
    }
  }

  Future<void> init() async {
    pickupCountryCode =
        CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.isEmptyOrNull
            ? defaultPhoneCode
            : CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.validate();
    deliverCountryCode =
        CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.isEmptyOrNull
            ? defaultPhoneCode
            : CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).code.validate();
    await getStaticDetailsForOrder();
    await getCouponList();
    if (widget.orderData != null) {
      if (widget.orderData!.totalWeight != 0)
        weightController.text = widget.orderData!.totalWeight!.toString();
      if (widget.orderData!.totalParcel != null)
        totalParcelController.text = widget.orderData!.totalParcel!.toString();
      parcelTypeCont.text = widget.orderData!.parcelType.validate();

      pickAddressCont.text = widget.orderData!.pickupPoint!.address.validate();
      pickPersonNameCont.text = widget.orderData!.pickupPoint!.name.validate();
      deliverPersonNameCont.text =
          widget.orderData!.deliveryPoint!.name.validate();
      deliverInstructionCont.text =
          widget.orderData!.deliveryPoint!.instruction.validate();
      pickInstructionCont.text =
          widget.orderData!.pickupPoint!.instruction.validate();
      pickLat = widget.orderData!.pickupPoint!.latitude.validate();
      pickLong = widget.orderData!.pickupPoint!.longitude.validate();
      if (widget.orderData!.pickupPoint!.contactNumber
              .validate()
              .split(" ")
              .length ==
          1) {
        pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      } else {
        pickupCountryCode = widget.orderData!.pickupPoint!.contactNumber
            .validate()
            .split(" ")
            .first;
        pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      }
      pickDesCont.text = widget.orderData!.pickupPoint!.description.validate();

      deliverAddressCont.text =
          widget.orderData!.deliveryPoint!.address.validate();
      deliverLat = widget.orderData!.deliveryPoint!.latitude.validate();
      deliverLong = widget.orderData!.deliveryPoint!.longitude.validate();
      if (widget.orderData!.deliveryPoint!.contactNumber
              .validate()
              .split(" ")
              .length ==
          1) {
        deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      } else {
        deliverCountryCode = widget.orderData!.deliveryPoint!.contactNumber
            .validate()
            .split(" ")
            .first;
        deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      }
      deliverDesCont.text =
          widget.orderData!.deliveryPoint!.description.validate();

      paymentCollectFrom = widget.orderData!.paymentCollectFrom
          .validate(value: PAYMENT_ON_PICKUP);
    }
  }

  getDistance() async {
    String? originLat = pickLat;
    String? originLong = pickLong;
    String? destinationLat = deliverLat;
    String? destinationLong = deliverLong;
    String origins = "${originLat},${originLong}";
    String destinations = "${destinationLat},${destinationLong}";
    await getDistanceBetweenLatLng(origins, destinations).then((value) async {
      double distanceInKms = value.rows[0].elements[0].distance.text
          .toString()
          .split(' ')[0]
          .toDouble();
      if (appStore.distanceUnit == DISTANCE_UNIT_MILE) {
        totalDistance = (MILES_PER_KM * distanceInKms);
      } else {
        totalDistance = distanceInKms;
      }
      setState(() {});
      await getTotalForOrder();
    });
  }

  getTotalForOrder() async {
    print("getTotalForOrder called");
    appStore.setLoading(true);
    Map request = {
      "city_id": getIntAsync(CITY_ID).toString(),
      if (appStore.isVehicleOrder != 0)
        "vehicle_id": vehicleList
            .firstWhere((element) => element.id == selectedVehicle)
            .id,
      "is_insurance":
          insuranceSelectedOption == 0 && appStore.isInsuranceAllowed == "1",
      // "is_insurance": 0,
      "total_weight": weightController.text.toDouble(),
      "total_distance": totalDistance,
      "insurance_amount": insuranceAmountController.text.isEmpty
          ? 0
          : insuranceAmountController.text
    };
    await getTotalAmountForOrder(request).then((value) {
      print("getTotalForOrder response");
      appStore.setLoading(false);
      print("------------request${request.toString()}");
      totalAmountResponse = value;
      print("---------------${totalAmountResponse!.baseTotal}");
      if (value.vehicleAmount != null) {
        vehicleCharge = value.vehicleAmount!;
      }
      setState(() {});
    });
  }

  double calculateTotalAmount() {
    double totalAmount = totalAmountResponse!.totalAmount?.toDouble() ?? 0.00;
    double result = 0.00;

    if (selectedCoupon?.valueType == "fixed") {
      double couponAmount = selectedCoupon?.discountAmount?.toDouble() ?? 0;
      double finalTotal =
          (totalAmount - couponAmount).clamp(0.00, double.infinity);
      result = isAppliedCoupon ? finalTotal : totalAmount;
    } else if (selectedCoupon?.valueType == "percentage") {
      double percentage = selectedCoupon?.discountAmount?.toDouble() ?? 0;
      double discountAmount = (totalAmount * percentage) / 100;
      double finalAmount =
          (totalAmount - discountAmount).clamp(0.00, double.infinity);

      result = isAppliedCoupon ? finalAmount : totalAmount;
    } else if (selectedCoupon == null && isAppliedCoupon == false) {
      result = totalAmount.toDouble();
    }

    return (result * 100).round() / 100;
  }

  createOrderApiCall(String orderStatus) async {
    List<Map<String, String>> packaging_symbols = [];
    selectedPackingSymbols.map((item) {
      packaging_symbols.add({'key': item["key"]!, 'title': item['title']!});
    }).toList();
    extraChargeList.clear();
    if (totalAmountResponse!.extraCharges != null) {
      totalAmountResponse!.extraCharges!.forEach((element) {
        extraChargeList.add(ExtraChargeRequestModel(
            key: element.title!.toLowerCase().replaceAll(' ', "_"),
            value: element.charges,
            valueType: element.chargesType));
      });
    }
    print("total_amount${totalAmountResponse!.totalAmount!}");
    print("insurance${insuranceAmount}");
    print("weight${totalAmountResponse!.weightAmount!.toDouble()}");
    print("distance_charge${totalAmountResponse!.distanceAmount!.toDouble()}");
    print("vehicle_charge${vehicleCharge}");

    appStore.setLoading(true);
    Map req = {
      "id": widget.orderData != null ? widget.orderData!.id : "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      //   if (appStore.isVehicleOrder != 0) "vehicle_id": selectedVehicle.toString(),
      if (!selectedVehicle.toString().isEmptyOrNull &&
          selectedVehicle != 0 &&
          appStore.isVehicleOrder != 0)
        "vehicle_id": selectedVehicle.toString(),
      if (vehicleCharge != 0.0) "vehicle_charge": vehicleCharge,
      "pickup_point": {
        "start_time": (!isDeliverNow && pickFromDateTime != null)
            ? pickFromDateTime.toString()
            : DateTime.now().toString(),
        "end_time": (!isDeliverNow && pickToDateTime != null)
            ? pickToDateTime!.toString()
            : null,
        "address": pickAddressCont.text,
        "latitude": pickLat,
        "longitude": pickLong,
        "name": pickPersonNameCont.text.toString(),
        "description": pickDesCont.text,
        "instruction": pickInstructionCont.text,
        "contact_number": '$pickupCountryCode${pickPhoneCont.text.trim()}',
      },
      "delivery_point": {
        "start_time": (!isDeliverNow && deliverFromDateTime != null)
            ? deliverFromDateTime.toString()
            : null,
        "end_time": (!isDeliverNow && deliverToDateTime != null)
            ? deliverToDateTime.toString()
            : null,
        "address": deliverAddressCont.text,
        "latitude": deliverLat,
        "longitude": deliverLong,
        "description": deliverDesCont.text,
        "name": deliverPersonNameCont.text.toString(),
        "instruction": deliverInstructionCont.text,
        "contact_number": '$deliverCountryCode${deliverPhoneCont.text.trim()}',
      },
      "packaging_symbols": packaging_symbols,
      "extra_charges": extraChargeList,
      "parcel_type": parcelTypeCont.text,
      "total_weight": weightController.text.toDouble(),
      "total_distance":
          totalDistance.toStringAsFixed(digitAfterDecimal).validate(),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": totalAmountResponse!.fixedAmount!.toDouble(),
      "parent_order_id": "",
      "bid_type": biddingSelectedOption ? 1 : 0,
      "total_amount": calculateTotalAmount(),
      "weight_charge": totalAmountResponse!.weightAmount!.toDouble(),
      "distance_charge": totalAmountResponse!.distanceAmount!.toDouble(),
      "total_parcel": totalParcelController.text.toInt(),
      "insurance_charge": insuranceAmount,
      "discount_amount":
          (totalAmountResponse!.totalAmount! - calculateTotalAmount()),
      "coupon_code": selectedCoupon?.couponCode ?? null,
    };

    log("req----" + req.toString());
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(req.toString())
        .forEach((match) => print(match.group(0)));
    await createOrder(req).then((value) async {
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
      if (isSelected == 2) {
        PaymentScreen(
                orderId: value.orderId.validate(),
                totalAmount: (totalAmountResponse!.totalAmount!))
            .launch(context);
      } else if (isSelected == 3) {
        log("-----available balance ${appStore.availableBal.toString()}-----------${totalAmountResponse!.totalAmount}----------${insuranceAmount}----------${(totalAmountResponse!.totalAmount! + insuranceAmount)}");
        if (appStore.availableBal > (totalAmountResponse!.totalAmount!)) {
          savePaymentApiCall(
              paymentType: PAYMENT_TYPE_WALLET,
              paymentStatus: PAYMENT_PAID,
              totalAmount: (calculateTotalAmount()).toString(),
              orderID: value.orderId.toString());
        }
      } else {
        DashboardScreen().launch(
          context,
          isNewTask: true,
        );
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  /// Save Payment
  Future<void> savePaymentApiCall(
      {String? paymentType,
      String? totalAmount,
      String? orderID,
      String? txnId,
      String? paymentStatus = PAYMENT_PENDING,
      Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": orderID,
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": totalAmount,
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    appStore.setLoading(true);

    savePayment(req).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString());
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      appStore.setLoading(false);
      print(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void setMapFitToCenter(Set<Polyline> p) {
    double minLat = p.first.points.first.latitude;
    double minLong = p.first.points.first.longitude;
    double maxLat = p.first.points.first.latitude;
    double maxLong = p.first.points.first.longitude;

    p.forEach((poly) {
      poly.points.forEach((point) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLong) minLong = point.longitude;
        if (point.longitude > maxLong) maxLong = point.longitude;
      });
    });
    googleMapController?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong)),
        20));
  }

  setPolylines() async {
    print("setPolyline");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapAPIKey,
        request: PolylineRequest(
            origin: PointLatLng(pickLat.toDouble(), pickLong.toDouble()),
            destination:
                PointLatLng(deliverLat.toDouble(), deliverLong.toDouble()),
            mode: TravelMode.driving));
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("--address not found ---");
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          width: 5,
          points: polylineCoordinates);
      _polylines.add(polyline);
    });
  }

  Widget createOrderWidget1() {
    return Observer(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              scheduleOptionWidget(
                  context, isDeliverNow, ic_clock, language.deliveryNow)
                  .onTap(() {
                isDeliverNow = true;
                setState(() {});
              }).expand(),
              8.width,
              scheduleOptionWidget(
                  context, !isDeliverNow, ic_schedule, language.schedule)
                  .onTap(() {
                isDeliverNow = false;
                setState(() {});
              }).expand(),
            ],
          ),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              enableBidOptionWidget(context, biddingSelectedOption,
                  Icons.handshake_outlined, language.bids)
                  .onTap(() {
                biddingSelectedOption = !biddingSelectedOption;
                setState(() {});
              }).expand(),
              const Spacer(),
            ],
          ).visible(appStore.isBiddingEnabled == "1"),
          16.height,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.pickTime, style: boldTextStyle()),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorUtils.borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: Column(
                  children: [
                    DateTimePicker(
                      controller: pickDateController,
                      type: DateTimePickerType.date,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30)),
                      onChanged: (value) {
                        pickDate = DateTime.parse(value);
                        deliverDate = null;
                        deliverDateController.clear();
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return language.fieldRequiredMsg;
                        return null;
                      },
                      decoration: commonInputDecoration(
                          suffixIcon: Icons.calendar_today,
                          hintText: language.date),
                    ),
                    16.height,
                    Row(
                      children: [
                        DateTimePicker(
                          controller: pickFromTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            pickFromTime = TimeOfDay.fromDateTime(
                                DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty)
                              return language.fieldRequiredMsg;

                            // Check if today’s date is selected
                            DateTime now = DateTime.now();
                            DateTime selectedDateTime =
                                DateFormat('hh:mm').parse(value!);
                            DateTime selectedDateWithTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedDateTime.hour,
                                selectedDateTime.minute);
                            if (pickDate!.year == now.year &&
                                pickDate!.month == now.month &&
                                pickDate!.day == now.day) {
                              // Add 1 hour to the current time if the selected date is today
                              if (selectedDateWithTime
                                  .isBefore(now.add(Duration(hours: 1)))) {
                                return language.scheduleOrderTimeMsg;
                              }
                            } else {
                              double fromTimeInHour = pickFromTime!.hour +
                                  pickFromTime!.minute / 60;
                              double toTimeInHour =
                                  pickToTime!.hour + pickToTime!.minute / 60;
                              double difference = toTimeInHour - fromTimeInHour;
                              if (difference <= 0) {
                                return language.endTimeValidationMsg;
                              }
                            }

                            return null;
                          },
                          decoration: commonInputDecoration(
                              suffixIcon: Icons.access_time,
                              hintText: language.from),
                        ).expand(),
                        16.width,
                        DateTimePicker(
                          controller: pickToTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            pickToTime = TimeOfDay.fromDateTime(
                                DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty)
                              return language.fieldRequiredMsg;
                            double fromTimeInHour =
                                pickFromTime!.hour + pickFromTime!.minute / 60;
                            double toTimeInHour =
                                pickToTime!.hour + pickToTime!.minute / 60;
                            double difference = toTimeInHour - fromTimeInHour;
                            // Check if today’s date is selected
                            DateTime now = DateTime.now();
                            DateTime selectedDateTime =
                                DateFormat('hh:mm').parse(value!);
                            DateTime selectedDateWithTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedDateTime.hour,
                                selectedDateTime.minute);
                            if (pickDate!.year == now.year &&
                                pickDate!.month == now.month &&
                                pickDate!.day == now.day) {
                              // Add 1 hour to the current time if the selected date is today
                              if (selectedDateWithTime
                                  .isBefore(now.add(Duration(hours: 1)))) {
                                return language.scheduleOrderTimeMsg;
                              }
                            }
                            if (difference <= 0) {
                              return language.endTimeValidationMsg;
                            }
                            return null;
                          },
                          decoration: commonInputDecoration(
                              suffixIcon: Icons.access_time,
                              hintText: language.to),
                        ).expand()
                      ],
                    ),
                  ],
                ),
              ),
              16.height,
              Text(language.deliverTime, style: boldTextStyle()),
              16.height,
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorUtils.borderColor,
                      width: appStore.isDarkMode ? 0.2 : 1),
                  borderRadius: BorderRadius.circular(defaultRadius),
                ),
                child: Column(
                  children: [
                    DateTimePicker(
                      controller: deliverDateController,
                      type: DateTimePickerType.date,
                      initialDate: pickDate ?? DateTime.now(),
                      firstDate: pickDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30)),
                      onChanged: (value) {
                        deliverDate = DateTime.parse(value);
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty) return language.fieldRequiredMsg;

                        return null;
                      },
                      decoration: commonInputDecoration(
                          suffixIcon: Icons.calendar_today,
                          hintText: language.date),
                    ),
                    16.height,
                    Row(
                      children: [
                        DateTimePicker(
                          controller: deliverFromTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            deliverFromTime = TimeOfDay.fromDateTime(
                                DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value.validate().isEmpty)
                              return language.fieldRequiredMsg;
                            double fromTimeInHour = deliverFromTime!.hour +
                                deliverFromTime!.minute / 60;
                            double toTimeInHour = deliverToTime!.hour +
                                deliverToTime!.minute / 60;
                            double difference = toTimeInHour - fromTimeInHour;
                            // Check if today’s date is selected
                            DateTime now = DateTime.now();
                            DateTime selectedDateTime =
                                DateFormat('hh:mm').parse(value!);
                            DateTime selectedDateWithTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedDateTime.hour,
                                selectedDateTime.minute);
                            if (pickDate!.year == now.year &&
                                pickDate!.month == now.month &&
                                pickDate!.day == now.day) {
                              // Add 1 hour to the current time if the selected date is today
                              if (selectedDateWithTime
                                  .isBefore(now.add(Duration(hours: 1)))) {
                                return language.scheduleOrderTimeMsg;
                              }
                            }
                            if (difference <= 0) {
                              return language.endTimeValidationMsg;
                            }
                            return null;
                          },
                          decoration: commonInputDecoration(
                              suffixIcon: Icons.access_time,
                              hintText: language.from),
                        ).expand(),
                        16.width,
                        DateTimePicker(
                          controller: deliverToTimeController,
                          type: DateTimePickerType.time,
                          onChanged: (value) {
                            deliverToTime = TimeOfDay.fromDateTime(
                                DateFormat('hh:mm').parse(value));
                            setState(() {});
                          },
                          validator: (value) {
                            if (value!.isEmpty)
                              return language.fieldRequiredMsg;
                            if (value.validate().isEmpty)
                              return language.fieldRequiredMsg;
                            double fromTimeInHour = deliverFromTime!.hour +
                                deliverFromTime!.minute / 60;
                            double toTimeInHour = deliverToTime!.hour +
                                deliverToTime!.minute / 60;
                            double difference = toTimeInHour - fromTimeInHour;
                            // Check if today’s date is selected
                            DateTime now = DateTime.now();
                            DateTime selectedDateTime =
                                DateFormat('hh:mm').parse(value);
                            DateTime selectedDateWithTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                selectedDateTime.hour,
                                selectedDateTime.minute);
                            if (deliverDate!.year == now.year &&
                                deliverDate!.month == now.month &&
                                deliverDate!.day == now.day) {
                              // Add 1 hour to the current time if the selected date is today
                              if (selectedDateWithTime
                                  .isBefore(now.add(Duration(hours: 1)))) {
                                return language.scheduleOrderTimeMsg;
                              }
                            }
                            if (difference <= 0) {
                              return language.endTimeValidationMsg;
                            }
                            return null;
                          },
                          decoration: commonInputDecoration(
                              suffixIcon: Icons.access_time,
                              hintText: language.to),
                        ).expand()
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).visible(!isDeliverNow),
          16.height,
          // Text(language.weight, style: boldTextStyle()),
          // 8.height,

          Row(
            children: [
              Text(language.weight, style: primaryTextStyle()).expand(),
              3.width,
              //   Text(" (${appStore.distanceUnit})", style: secondaryTextStyle()).expand(),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorUtils.borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.grey)
                          .paddingAll(12)
                          .onTap(() {
                        if (weightController.text.toDouble() > 1) {
                          weightController.text =
                              (weightController.text.toDouble() - 1).toString();
                        }
                      }),
                      VerticalDivider(
                          thickness: 1, color: context.dividerColor),
                      Container(
                        width: 50,
                        child: AppTextField(
                          controller: weightController,
                          textAlign: TextAlign.center,
                          maxLength: 5,
                          textFieldType: TextFieldType.PHONE,
                          decoration: InputDecoration(
                            counterText: '',
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: ColorUtils.colorPrimary)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      VerticalDivider(
                          thickness: 1, color: context.dividerColor),
                      Icon(Icons.add,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.grey)
                          .paddingAll(12)
                          .onTap(() {
                        weightController.text =
                            (weightController.text.toDouble() + 1).toString();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          16.height,
          // Text(language.numberOfParcels, style: boldTextStyle()),
          // 8.height,
          Row(
            children: [
              Text(language.numberOfParcels, style: primaryTextStyle())
                  .expand(),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: ColorUtils.borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius)),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.grey)
                          .paddingAll(12)
                          .onTap(() {
                        if (totalParcelController.text.toInt() > 1) {
                          totalParcelController.text =
                              (totalParcelController.text.toInt() - 1)
                                  .toString();
                        }
                      }),
                      VerticalDivider(
                          thickness: 1, color: context.dividerColor),
                      Container(
                        width: 50,
                        child: AppTextField(
                          controller: totalParcelController,
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          textFieldType: TextFieldType.PHONE,
                          decoration: InputDecoration(
                            counterText: '',
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: ColorUtils.colorPrimary)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      VerticalDivider(
                          thickness: 1, color: context.dividerColor),
                      Icon(Icons.add,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.grey)
                          .paddingAll(12)
                          .onTap(() {
                        totalParcelController.text =
                            (totalParcelController.text.toInt() + 1).toString();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          16.height,
          Text(language.parcelType, style: primaryTextStyle()),
          8.height,
          AppTextField(
            controller: parcelTypeCont,
            textFieldType: TextFieldType.OTHER,
            decoration: commonInputDecoration(),
            validator: (value) {
              if (value!.isEmpty) return language.fieldRequiredMsg;
              return null;
            },
          ),
          8.height,
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: parcelTypeList.map((item) {
              return Chip(
                backgroundColor: context.scaffoldBackgroundColor,
                label: Text(item.label!, style: secondaryTextStyle()),
                elevation: 0,
                labelStyle: primaryTextStyle(color: Colors.grey),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  side: BorderSide(
                      color: ColorUtils.borderColor,
                      width: appStore.isDarkMode ? 0.2 : 1),
                ),
              ).onTap(() {
                parcelTypeCont.text = item.label!;
                setState(() {});
              });
            }).toList(),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.labels, style: primaryTextStyle()),
              Icon(Icons.info,
                      color: appStore.isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : ColorUtils.colorPrimary)
                  .onTap(() {
                PackagingSymbolsInfo().launch(context);
              })
            ],
          ),
          16.height,
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: packingSymbolsItems.map((item) {
              bool isSelected = selectedPackingSymbols.contains(item);
              return Container(
                width: 70,
                decoration: boxDecorationWithRoundedCorners(),
                child: Stack(
                  children: [
                    Image.asset(
                      item['image']!,
                      width: 24,
                      height: 24,
                      color: appStore.isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : ColorUtils.colorPrimary,
                    ).center().paddingAll(10),
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ).onTap(() {
                setState(() {
                  if (isSelected) {
                    selectedPackingSymbols.remove(item);
                  } else {
                    selectedPackingSymbols.add(item);
                  }
                });

                setState(() {});
              });
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget createOrderWidget2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.location, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: pickAddressCont,
              readOnly: true,
              textInputAction: TextInputAction.next,
              nextFocus: pickPhoneFocus,
              textFieldType: TextFieldType.MULTILINE,
              decoration:
                  commonInputDecoration(suffixIcon: Icons.location_on_outlined),
              validator: (value) {
                if (value!.isEmpty) return language.fieldRequiredMsg;
                if (pickLat == null || pickLong == null)
                  return language.pleaseSelectValidAddress;
                return null;
              },
              onTap: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(defaultRadius))),
                  context: context,
                  builder: (context) {
                    return PickAddressBottomSheet(
                      onPick: (address) {
                        pickAddressCont.text = address.address ?? "";
                        pickLat = address.latitude.toString();
                        pickLong = address.longitude.toString();
                        pickPhoneCont.text =
                            address.contactNumber.validate().substring(4);
                        setState(() {});
                      },
                    );
                  },
                ).then((value) {
                  addressList = (getStringListAsync(RECENT_ADDRESS_LIST) ?? [])
                      .map((e) => UseraddressDetail.fromJson(jsonDecode(e)))
                      .toList();
                  if (addressList.isNotEmpty) {
                    pickAddressData = addressList.first;
                    deliveryAddressData = addressList.first;
                  }
                  setState(() {});
                });
              },
            ),
            16.height,
            Text(language.contactNumber, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: pickPhoneCont,
              focus: pickPhoneFocus,
              nextFocus: pickDesFocus,
              textFieldType: TextFieldType.PHONE,
              decoration: commonInputDecoration(
                  suffixIcon: Icons.phone,
                  prefixIcon: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryCodePicker(
                          initialSelection: pickupCountryCode,
                          showCountryOnly: false,
                          dialogSize: Size(
                              context.width() - 60, context.height() * 0.6),
                          showFlag: true,
                          showFlagDialog: true,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          textStyle: primaryTextStyle(),
                          dialogBackgroundColor: Theme.of(context).cardColor,
                          barrierColor: Colors.black12,
                          dialogTextStyle: primaryTextStyle(),
                          searchDecoration: InputDecoration(
                            iconColor: Theme.of(context).dividerColor,
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: ColorUtils.colorPrimary)),
                          ),
                          searchStyle: primaryTextStyle(),
                          onInit: (c) {
                            pickupCountryCode = c!.dialCode!;
                          },
                          onChanged: (c) {
                            pickupCountryCode = c.dialCode!;
                          },
                        ),
                        VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                      ],
                    ),
                  )),
              textInputAction: TextInputAction.go,
              validator: (value) {
                if (value!.trim().isEmpty) return language.fieldRequiredMsg;
                //  if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
        16.height,
        Text(language.pickupPersonName, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickPersonNameCont,
          textInputAction: TextInputAction.done,
          focus: pickPersonNameFocus,
          textFieldType: TextFieldType.NAME,
          decoration: commonInputDecoration(),
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            return null;
          },
        ),
        16.height,
        Text(language.pickupDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: pickDesCont,
          focusNode: pickDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        16.height,
        Text(language.pickupInstructions, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: pickInstructionCont,
          focusNode: pickInstructionFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 2,
          minLines: 2,
        ),
      ],
    );
  }

  Widget createOrderWidget3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.deliveryLocation, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: deliverAddressCont,
              readOnly: true,
              textInputAction: TextInputAction.next,
              nextFocus: deliverPhoneFocus,
              textFieldType: TextFieldType.MULTILINE,
              decoration:
                  commonInputDecoration(suffixIcon: Icons.location_on_outlined),
              validator: (value) {
                if (value!.isEmpty) return language.fieldRequiredMsg;
                if (deliverLat == null || deliverLong == null)
                  return language.pleaseSelectValidAddress;
                return null;
              },
              onTap: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(defaultRadius))),
                  context: context,
                  builder: (context) {
                    return PickAddressBottomSheet(
                      onPick: (address) {
                        deliverAddressCont.text = address.address ?? "";
                        deliverLat = address.latitude.toString();
                        deliverLong = address.longitude.toString();
                        deliverPhoneCont.text =
                            address.contactNumber.validate().substring(4);
                        setState(() {});
                      },
                      isPickup: false,
                    );
                  },
                ).then((value) {
                  addressList = (getStringListAsync(RECENT_ADDRESS_LIST) ?? [])
                      .map((e) => UseraddressDetail.fromJson(jsonDecode(e)))
                      .toList();
                  if (addressList.isNotEmpty) {
                    pickAddressData = addressList.first;
                    deliveryAddressData = addressList.first;
                  }
                  setState(() {});
                });
              },
            ),
            16.height,
            Text(language.deliveryContactNumber, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: deliverPhoneCont,
              textInputAction: TextInputAction.go,
              focus: deliverPhoneFocus,
              nextFocus: deliverDesFocus,
              textFieldType: TextFieldType.PHONE,
              decoration: commonInputDecoration(
                suffixIcon: Icons.phone,
                prefixIcon: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryCodePicker(
                        initialSelection: deliverCountryCode,
                        showCountryOnly: false,
                        dialogSize:
                            Size(context.width() - 60, context.height() * 0.6),
                        showFlag: true,
                        showFlagDialog: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: primaryTextStyle(),
                        dialogBackgroundColor: Theme.of(context).cardColor,
                        barrierColor: Colors.black12,
                        dialogTextStyle: primaryTextStyle(),
                        searchDecoration: InputDecoration(
                          iconColor: Theme.of(context).dividerColor,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: ColorUtils.colorPrimary)),
                        ),
                        searchStyle: primaryTextStyle(),
                        onInit: (c) {
                          deliverCountryCode = c!.dialCode!;
                        },
                        onChanged: (c) {
                          deliverCountryCode = c.dialCode!;
                        },
                      ),
                      VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) return language.fieldRequiredMsg;
                //if (value!.length < 8 || value.length > 15) return "please enter valid mobile number";
                if (value.trim().length < minContactLength ||
                    value.trim().length > maxContactLength)
                  return language.phoneNumberInvalid;
                return null;
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        16.height,
        Text(language.deliveryPersonName, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverPersonNameCont,
          textInputAction: TextInputAction.go,
          focus: deliveryPesonNameFocus,
          textFieldType: TextFieldType.NAME,
          decoration: commonInputDecoration(),
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            // if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
            return null;
          },
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: deliverDesCont,
          focusNode: deliverDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        16.height,
        Text(language.deliveryInstructions, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: deliverInstructionCont,
          focusNode: deliveryInstructionFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 2,
          minLines: 2,
        ),
      ],
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      googleMapController = controller;
      setPolylines().then((_) => setMapFitToCenter(_polylines));
    });
  }

  Widget createOrderWidget4() {
    return Column(
      children: [
        markers.isNotEmpty
            ? Container(
                width: context.width(),
                height: context.height() * 0.80,
                child: GoogleMap(
                  markers: markers.map((e) => e).toSet(),
                  polylines: _polylines,
                  mapType: MapType.normal,
                  cameraTargetBounds: CameraTargetBounds.unbounded,
                  initialCameraPosition: CameraPosition(
                      bearing: 192.8334901395799,
                      // target: LatLng(isPickSavedAddress ? pickAddressData!.latitude.toDouble() : pickLat.toDouble(),
                      //     isPickSavedAddress ? pickAddressData!.longitude.toDouble() : pickLong.toDouble()),
                      target: LatLng(pickLat.toDouble(), pickLong.toDouble()),
                      zoom: 12),
                  onMapCreated: onMapCreated,
                  tiltGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () =>
                          EagerGestureRecognizer(), // Allow all gestures on the map
                    ),
                  },
                  // trafficEnabled: true,
                ),
              )
            : loaderWidget(),
      ],
    );
  }

  Widget createOrderWidget5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.packageInformation, style: boldTextStyle()),
          8.height,
          Container(
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border:
                  Border.all(color: ColorUtils.colorPrimary.withOpacity(0.2)),
              backgroundColor: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rowWidget(
                    title: language.parcelType, value: parcelTypeCont.text),
                8.height,
                rowWidget(
                    title: language.weight,
                    value:
                        '${weightController.text} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}'),
                8.height,
                rowWidget(
                    title: language.numberOfParcels,
                    value: '${totalParcelController.text}'),
              ],
            ),
          ),
          16.height,
          addressComponent(
              title: language.pickupLocation,
              // address: isPickSavedAddress ? pickAddressData!.address.validate() : pickAddressCont.text,
              // phoneNumber: isPickSavedAddress
              //     ? pickAddressData!.contactNumber.validate()
              //     : '$pickupCountryCode ${pickPhoneCont.text.trim()}'),
              address: pickAddressCont.text,
              phoneNumber: '$pickupCountryCode ${pickPhoneCont.text.trim()}',
              personName: pickPersonNameCont.text,
              information: pickDesCont.text,
              instruction: pickInstructionCont.text),
          16.height,
          addressComponent(
              title: language.deliveryLocation,
              // address: isDeliverySavedAddress ? deliveryAddressData!.address.validate() : deliverAddressCont.text,
              // phoneNumber: isDeliverySavedAddress
              //     ? deliveryAddressData!.contactNumber.validate()
              //     : '$deliverCountryCode ${deliverPhoneCont.text.trim()}'),
              address: deliverAddressCont.text,
              phoneNumber:
                  '$deliverCountryCode ${deliverPhoneCont.text.trim()}',
              personName: deliverPersonNameCont.text,
              information: deliverDesCont.text,
              instruction: deliverInstructionCont.text),
          Visibility(
            visible: appStore.isVehicleOrder != 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(language.selectVehicle, style: boldTextStyle()),
                8.height,
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedVehicle,
                  decoration: commonInputDecoration(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: primaryTextStyle(),
                  isDense: false,
                  items: vehicleList.map<DropdownMenuItem<int>>((item) {
                    String str =
                        "${language.name} : ${item.title}, ${language.price} :${appStore.currencySymbol} "
                        "${item.price.validate()}, "
                        "${language.capacity} : ${item.capacity.validate()},${language.perKmCharge} :${appStore.currencySymbol} ${item.perKmCharge.validate()}";
                    return DropdownMenuItem(
                      value: item.id,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            commonCachedNetworkImage(
                                item.vehicleImage.validate(),
                                height: 40,
                                width: 40),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // Align to start
                              children: [
                                Container(
                                  width: context.width() * 0.6,
                                  child: Text(
                                    str,
                                    style: primaryTextStyle(),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                                // Row(
                                //   children: [
                                //     Container(
                                //         width: 100, child: Text("${language.name} : ", style: secondaryTextStyle())),
                                //     Text(
                                //       "${item.title.validate()} ",
                                //       style: primaryTextStyle(),
                                //     ),
                                //   ],
                                // ),
                                // Row(
                                //   children: [
                                //     Container(
                                //         width: 100, child: Text("${language.price} : ", style: secondaryTextStyle())),
                                //     Text(
                                //       "${printAmount(item.price.validate())}",
                                //       style: primaryTextStyle(),
                                //     ).paddingRight(10),
                                //   ],
                                // ),
                                // Row(
                                //   children: [
                                //     Container(
                                //         width: 100,
                                //         child: Text("${language.capacity} : ", style: secondaryTextStyle())),
                                //     Text(
                                //       "${item.capacity.validate()} ",
                                //       style: primaryTextStyle(),
                                //     ),
                                //   ],
                                // ),
                                // Row(
                                //   children: [
                                //     Container(
                                //         width: 100,
                                //         child: Text("${language.perKmCharge} : ", style: secondaryTextStyle())),
                                //     Text(
                                //       "${printAmount(item.perKmCharge.validate())}",
                                //       style: primaryTextStyle(),
                                //     ).paddingRight(10),
                                //   ],
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedVehicle = value;
                    setState(() {});
                    getTotalForOrder();
                  },
                  validator: (value) {
                    if (selectedVehicle == null)
                      return language.fieldRequiredMsg;
                    return null;
                  },
                ),
              ],
            ),
          ),
          16.height,
          //insurance start
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.insurance, style: boldTextStyle()),
              Icon(Icons.info, color: ColorUtils.themeColor).onTap(() {
                InsuranceDetailsScreen(appStore.insuranceDescription)
                    .launch(context);
              }).visible(!appStore.insuranceDescription.isEmptyOrNull)
            ],
          ).visible(appStore.isInsuranceAllowed == "1"),
          16.height.visible(appStore.isInsuranceAllowed == "1"),
          InsuranceOptionsWidget(0, language.addCourierInsurance)
              .visible(appStore.isInsuranceAllowed == "1"),
          16.height.visible(appStore.isInsuranceAllowed == "1"),
          InsuranceOptionsWidget(1, language.noThanksRisk)
              .visible(appStore.isInsuranceAllowed == "1"),
          16.height.visible(insuranceSelectedOption == 0),
          if (appStore.isInsuranceAllowed == "1") ...[
            12.height,
            Text(language.approxParcelValue, style: primaryTextStyle())
                .visible(insuranceSelectedOption == 0),
            9.height,
            AppTextField(
              controller: insuranceAmountController,
              textFieldType: TextFieldType.NUMBER,
              decoration: commonInputDecoration(isFill: false),
              onChanged: (val) async {
                if (!val.isEmptyOrNull) {
                  insuranceAmount = (double.parse(val) *
                          appStore.insurancePercentage.toDouble()) /
                      100;
                  await getTotalForOrder();
                  setState(() {});
                } else {
                  insuranceAmount = 0;
                  await getTotalForOrder();
                  setState(() {});
                }
              },
              onFieldSubmitted: (val) async {
                if (!val.isEmptyOrNull) {
                  insuranceAmount = (double.parse(val) *
                          appStore.insurancePercentage.toDouble()) /
                      100;
                  await getTotalForOrder();
                  setState(() {});
                } else {
                  insuranceAmount = 0;
                  await getTotalForOrder();
                  setState(() {});
                }
              },
              validator: (value) {
                if (value!.isEmpty) return language.fieldRequiredMsg;
                return null;
              },
            ).visible(insuranceSelectedOption == 0),
            //16.height,
          ],
          // insurance end
          //Coupon start
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${language.offersAndBenefits}", style: boldTextStyle()),
              8.height,
              Container(
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  border: Border.all(
                      color: ColorUtils.colorPrimary.withOpacity(0.2)),
                  backgroundColor: isAppliedCoupon
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    color: ColorUtils.colorPrimary,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      selectedCoupon?.couponCode.toString() ??
                                          "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: boldTextStyle(
                                          color: ColorUtils.colorPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                selectedCoupon?.valueType == "fixed"
                                    ? "${language.save} ${appStore.currencySymbol}${selectedCoupon?.discountAmount} ${language.onThisOrder}"
                                    : "${language.save} ${selectedCoupon?.discountAmount}% ${language.onThisOrder}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: secondaryTextStyle(),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            appStore.setLoading(true);
                            await Future.delayed(Duration(seconds: 1));
                            isAppliedCoupon = !isAppliedCoupon;
                            appStore.setLoading(false);
                            setState(() {});
                          },
                          child: Text(
                            isAppliedCoupon ? language.cancel : language.apply,
                            style: boldTextStyle(
                              color: isAppliedCoupon
                                  ? darkRed
                                  : ColorUtils.colorPrimary,
                            ),
                          ),
                        ),
                      ],
                    ).paddingAll(16),
                    10.height.visible(selectedCoupon == null ? false : true),
                    Divider(color: Colors.grey.withOpacity(0.3), height: 0.5)
                        .visible(selectedCoupon == null ? false : true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${language.moreCoupons}",
                            style: primaryTextStyle(size: 16)),
                        Icon(
                          Icons.navigate_next,
                          size: 18,
                        )
                      ],
                    )
                        .paddingAll(8)
                        .visible(selectedCoupon == null ? false : true)
                        .onTap(isAppliedCoupon
                            ? null
                            : () {
                                CouponListScreen()
                                    .launch(context)
                                    .then((result) {
                                  if (result != null) {
                                    selectedCoupon = result;
                                    setState(() {});
                                  }

                                  setState(() {});
                                });
                              }),
                  ],
                ),
              ),
            ],
          ).visible(selectedCoupon == null ? false : true),
          // Coupon end
          16.height,
          if (totalAmountResponse != null)
            OrderAmountDataWidget(
                fixedAmount: totalAmountResponse!.fixedAmount!.toDouble(),
                distanceAmount: totalAmountResponse!.distanceAmount!.toDouble(),
                extraCharges: totalAmountResponse!.extraCharges!,
                vehicleAmount: totalAmountResponse!.vehicleAmount!.toDouble(),
                insuranceAmount: insuranceAmount.toDouble(),
                diffWeight: totalAmountResponse!.diffWeight!.toDouble(),
                diffDistance: totalAmountResponse!.diffDistance!.toDouble(),
                totalAmount: totalAmountResponse!.totalAmount!.toDouble(),
                weightAmount: totalAmountResponse!.weightAmount!.toDouble(),
                perWeightCharge: cityData!.perWeightCharges!.toDouble(),
                perKmCityDataCharge: cityData!.perDistanceCharges!.toDouble(),
                coupon: selectedCoupon ?? null,
                isAppliedCoupon: isAppliedCoupon,
                perkmVehiclePrice: vehicleList
                    .firstWhere((element) => element.id == selectedVehicle)
                    .perKmCharge!
                    .toDouble(),
                baseTotal: totalAmountResponse!.baseTotal!.toDouble()),

          16.height,
          Text(language.payment, style: boldTextStyle()),
          16.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mPaymentList.map((mData) {
              return Container(
                width: (context.width() - 48) / 3,
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: boxDecorationWithRoundedCorners(
                    border: Border.all(
                        color: isSelected == mData.index
                            ? ColorUtils.colorPrimary
                            : ColorUtils.borderColor),
                    backgroundColor: Colors.transparent),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageIcon(AssetImage(mData.image.validate()),
                        size: 20,
                        color: isSelected == mData.index
                            ? ColorUtils.colorPrimary
                            : ColorUtils.dividerColor),
                    8.width,
                    Text(mData.title!,
                        style: primaryTextStyle(
                            color: isSelected == mData.index
                                ? ColorUtils.colorPrimary
                                : textSecondaryColorGlobal)),
                  ],
                ),
              ).onTap(() {
                isSelected = mData.index!;
                setState(() {});
              });
            }).toList(),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.paymentCollectFrom, style: boldTextStyle()),
              16.width,
              DropdownButtonFormField<String>(
                isExpanded: true,
                isDense: true,
                value: paymentCollectFrom,
                decoration: commonInputDecoration(),
                items: [
                  DropdownMenuItem(
                      value: PAYMENT_ON_PICKUP,
                      child: Text(language.pickupLocation,
                          style: primaryTextStyle(), maxLines: 1)),
                  DropdownMenuItem(
                      value: PAYMENT_ON_DELIVERY,
                      child: Text(language.deliveryLocation,
                          style: primaryTextStyle(), maxLines: 1)),
                ],
                onChanged: (value) {
                  paymentCollectFrom = value!;
                  setState(() {});
                },
              ).expand(),
            ],
          ).visible(isSelected == 1),
        ],
      ),
    );
  }

  // Widget InsuranceOptionsWidget(int value, String text) {
  //   return Container(
  //     decoration: boxDecorationWithRoundedCorners(
  //         backgroundColor: insuranceSelectedOption == value
  //             ? ColorUtils.colorPrimary
  //             : Colors.grey.withOpacity(0.1)),
  //     //  padding: EdgeInsets.all(8.0),
  //     child: Row(
  //       children: [
  //         Radio<int>(
  //           value: value,
  //           groupValue: insuranceSelectedOption,
  //           onChanged: (int? newValue) async {
  //             print("---------${value}");
  //             if (newValue != insuranceSelectedOption) {
  //               insuranceSelectedOption = value;
  //               if (insuranceSelectedOption == 0) {
  //                 // Do nothing...
  //                 log("I am here2....");
  //               } else {
  //                 log("I am here....");
  //                 insuranceAmountController.clear();
  //                 insuranceAmount = 0.0;
  //                 setState(() {});
  //               }
  //             }
  //             await  getTotalForOrder();
  //           },
  //           fillColor: MaterialStateProperty.resolveWith<Color?>(
  //             (Set<MaterialState> states) {
  //               if (states.contains(MaterialState.selected)) {
  //                 return Colors.white;
  //               }
  //               return ColorUtils.colorPrimary;
  //             },
  //           ),
  //           activeColor: Colors.white,
  //         ),
  //         SizedBox(width: 8),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Text(text,
  //                 style: primaryTextStyle(
  //                     color: insuranceSelectedOption == value
  //                         ? Colors.white
  //                         : ColorUtils.themeColor)),
  //             if (insuranceSelectedOption == 0 && value == 0)
  //               Text(
  //                 insuranceSelectedOption == 0
  //                     ? "${appStore.insurancePercentage} ${language.ofApproxParcelValue}"
  //                     : "",
  //                 style: secondaryTextStyle(
  //                     color: Colors.white.withOpacity(0.5), size: 13),
  //               ),
  //           ],
  //         ).expand(),
  //         Text(
  //           insuranceSelectedOption == 0
  //               ? "${printAmount(insuranceAmount)}"
  //               : "",
  //           style: primaryTextStyle(color: Colors.white),
  //         ).visible(value == 0).paddingOnly(right: 10),
  //       ],
  //     ),
  //   ).onTap(() async {
  //     setState(() {
  //       insuranceSelectedOption = value;
  //       if (insuranceSelectedOption == 0) {
  //         // Do nothing...
  //         log("I am here2....");
  //       } else {
  //         log("I am here....");
  //         insuranceAmountController.clear();
  //         insuranceAmount = 0.0;
  //         setState(() {});
  //       }
  //       await  getTotalForOrder();
  //     });
  //     setState(() {});
  //   });
  // }
  //

  Widget InsuranceOptionsWidget(int value, String text) {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: insuranceSelectedOption == value
            ? ColorUtils.colorPrimary
            : Colors.grey.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Radio<int>(
            value: value,
            groupValue: insuranceSelectedOption,
            onChanged: (int? newValue) {
              _onOptionSelected(newValue);
            },
            fillColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return ColorUtils.colorPrimary;
              },
            ),
            activeColor: Colors.white,
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: primaryTextStyle(
                  color: insuranceSelectedOption == value
                      ? Colors.white
                      : ColorUtils.themeColor,
                ),
              ),
              if (value == 0 && insuranceSelectedOption == 0)
                Text(
                  "${appStore.insurancePercentage} ${language.ofApproxParcelValue}",
                  style: secondaryTextStyle(
                    color: Colors.white.withOpacity(0.5),
                    size: 13,
                  ),
                ),
            ],
          ).expand(),
          Text(
            insuranceSelectedOption == 0 ? printAmount(insuranceAmount) : "",
            style: primaryTextStyle(color: Colors.white),
          ).visible(value == 0).paddingOnly(right: 10),
        ],
      ),
    ).onTap(() => _onOptionSelected(value));
  }

  void _onOptionSelected(int? newValue) async {
    if (newValue == null || newValue == insuranceSelectedOption) return;

    setState(() {
      insuranceSelectedOption = newValue;
      if (insuranceSelectedOption != 0) {
        insuranceAmountController.clear();
        insuranceAmount = 0.0;
      }
    });

    await getTotalForOrder();
  }

  Widget rowWidget({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: secondaryTextStyle()),
        16.width,
        Text(value,
                style: boldTextStyle(size: 14),
                maxLines: 3,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis)
            .expand(),
      ],
    );
  }

  Widget addressComponent({
    required String title,
    required String address,
    required String phoneNumber,
    required String personName,
    required String instruction,
    required String information,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: boldTextStyle()),
            Text(language.viewMore, style: secondaryTextStyle(size: 12))
                .onTap(() {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      //   contentPadding: EdgeInsets.all(8),
                      title: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.details, style: boldTextStyle()),
                                Icon(Icons.close, size: 20).onTap(() {
                                  pop();
                                })
                              ]),
                          10.height,
                          Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.withOpacity(0.5))
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${language.contactPersonName} :",
                                  style: secondaryTextStyle()),
                              Text(personName, style: boldTextStyle()),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${language.information} :",
                                  style: secondaryTextStyle()),
                              Text(information, style: boldTextStyle()),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${language.instruction}",
                                  style: secondaryTextStyle()),
                              Text(instruction, style: boldTextStyle()),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            }),
          ],
        ),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.2)),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address, style: primaryTextStyle()),
              8.height.visible(address.isNotEmpty),
              Row(
                children: [
                  Icon(Icons.call, size: 14),
                  8.width,
                  Text(phoneNumber, style: secondaryTextStyle())
                      .visible(phoneNumber.isNotEmpty),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget progressIndicator() {
    return CircularPercentIndicator(
      radius: 20.0,
      lineWidth: 2.0,
      percent:
          ((selectedTabIndex + 1) / 5) > 1 ? 1 : (selectedTabIndex + 1) / 5,
      animation: true,
      center: Text((selectedTabIndex + 1).toInt().toString() + " /5",
          style: boldTextStyle(size: 11, color: Colors.white)),
      backgroundColor: Colors.white.withOpacity(0.25),
      progressColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          await showInDialog(
            context,
            contentPadding: EdgeInsets.all(16),
            builder: (p0) {
              return CreateOrderConfirmationDialog(
                onCancel: () {
                  finish(context);
                  finish(context);
                },
                onSuccess: () async {
                  finish(context);
                  if (totalAmountResponse == null) {
                    await getTotalForOrder();
                    await createOrderApiCall(ORDER_DRAFT);
                  } else {
                    createOrderApiCall(ORDER_DRAFT);
                  }
                },
                message: language.saveDraftConfirmationMsg,
                primaryText: language.saveDraft,
              );
            },
          );
          return false;
        } else {
          selectedTabIndex--;
          setState(() {});
          return false;
        }
      },
      child: CommonScaffoldComponent(
        // appBarTitle: language.createOrder,

        appBar: commonAppBarWidget(appBarTitleList[selectedTabIndex], actions: [
          Row(
            children: [
              progressIndicator(),
              10.width,
            ],
          )
        ]),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding:
                  EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedTabIndex == 0) createOrderWidget1(),
                    if (selectedTabIndex == 1) createOrderWidget2(),
                    if (selectedTabIndex == 2) createOrderWidget3(),
                    if (selectedTabIndex == 3) createOrderWidget4(),
                    if (selectedTabIndex == 4) createOrderWidget5(),
                  ],
                ),
              ),
            ),
            Observer(
              builder: (context) => loaderWidget().visible(appStore.isLoading),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (selectedTabIndex != 0)
                outlineButton(language.previous, () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  selectedTabIndex--;
                  setState(() {});
                }, color: ColorUtils.colorPrimary)
                    .paddingRight(isRTL ? 4 : 16)
                    .paddingLeft(isRTL ? 16 : 0)
                    .expand(),
              commonButton(
                  selectedTabIndex != 4 ? language.next : language.createOrder,
                  () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                log('------selected tab index${selectedTabIndex}');
                if (selectedTabIndex == 2) {
                  markers.clear();
                  markers.add(
                    Marker(
                      markerId: MarkerId("1"),
                      position: LatLng(pickLat.toDouble(), pickLong.toDouble()),
                      infoWindow: InfoWindow(title: language.sourceLocation),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  );
                  markers.add(
                    Marker(
                      markerId: MarkerId("2"),
                      position:
                          LatLng(deliverLat.toDouble(), deliverLong.toDouble()),
                      infoWindow:
                          InfoWindow(title: language.destinationLocation),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                    ),
                  );
                  getDistance();
                  setState(() {});
                }
                if (selectedTabIndex != 4) {
                  if (_formKey.currentState!.validate()) {
                    Duration difference = Duration();
                    Duration differenceCurrentTime = Duration();
                    if (!isDeliverNow) {
                      pickFromDateTime = pickDate!.add(Duration(
                          hours: pickFromTime!.hour,
                          minutes: pickFromTime!.minute));
                      pickToDateTime = pickDate!.add(Duration(
                          hours: pickToTime!.hour,
                          minutes: pickToTime!.minute));
                      deliverFromDateTime = deliverDate!.add(Duration(
                          hours: deliverFromTime!.hour,
                          minutes: deliverFromTime!.minute));
                      deliverToDateTime = deliverDate!.add(Duration(
                          hours: deliverToTime!.hour,
                          minutes: deliverToTime!.minute));
                      difference =
                          pickFromDateTime!.difference(deliverFromDateTime!);
                      differenceCurrentTime =
                          DateTime.now().difference(pickFromDateTime!);
                    }
                    if (differenceCurrentTime.inMinutes > 0)
                      return toast(language.pickupCurrentValidationMsg);
                    if (difference.inMinutes > 0)
                      return toast(language.pickupDeliverValidationMsg);
                    selectedTabIndex++;
                    if (selectedTabIndex == 4) {
                      //  await getTotalAmount();
                    }
                    setState(() {});
                  }
                } else {
                  if (insuranceSelectedOption == 0 &&
                      insuranceAmountController.text.isEmptyOrNull) {
                    toast(language.insuranceAmountValidation);
                    return;
                  }
                  if (isSelected == 3 &&
                      //      (appStore.availableBal < (totalAmountResponse!.totalAmount! + insuranceAmount))) {
                      (appStore.availableBal <
                          (totalAmountResponse!.totalAmount! +
                              insuranceAmount))) {
                    showInDialog(
                      getContext,
                      contentPadding: EdgeInsets.all(16),
                      builder: (p0) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(language.balanceInsufficientCashPayment,
                                style: primaryTextStyle(size: 16),
                                textAlign: TextAlign.center),
                            30.height,
                            Row(
                              children: [
                                commonButton(language.cancel, () {
                                  finish(getContext, 0);
                                }).expand(),
                                6.width,
                                commonButton(language.process, () {
                                  //      if (appStore.isInsuranceAllowed == true && insuranceSelectedOption == 0)
                                  // createOrderApiCall(ORDER_CREATED);
                                  // finish(getContext, 1);
                                  showConfirmDialogCustom(
                                    context,
                                    title: language.createOrderConfirmationMsg,
                                    note: language
                                        .pleaseAvoidSendingProhibitedItems,
                                    positiveText: language.yes,
                                    primaryColor: ColorUtils.colorPrimary,
                                    negativeText: language.no,
                                    onAccept: (v) {
                                      createOrderApiCall(ORDER_CREATED);
                                      finish(getContext);
                                    },
                                  );
                                }).expand(),
                                6.width,
                                commonButton(language.draft, () {
                                  createOrderApiCall(ORDER_DRAFT);
                                  finish(getContext, 2);
                                }).expand(),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showConfirmDialogCustom(
                      context,
                      title: language.createOrderConfirmationMsg,
                      note: language.pleaseAvoidSendingProhibitedItems,
                      positiveText: language.yes,
                      primaryColor: ColorUtils.colorPrimary,
                      negativeText: language.no,
                      onAccept: (v) {
                        createOrderApiCall(ORDER_CREATED);
                      },
                    );
                  }
                }
              }).expand()
            ],
          ),
        ),
      ),
    );
  }
}

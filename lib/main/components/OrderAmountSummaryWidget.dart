import 'package:flutter/material.dart';
import 'package:mighty_delivery/extensions/colors.dart';
import 'package:mighty_delivery/main/models/CouponListResponseModel.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/num_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/CreateOrderDetailModel.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main/utils/Common.dart';
import '../../main.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class OrderAmountDataWidget extends StatefulWidget {
  static String tag = '/OrderSummeryWidget';

  final List<ExtraCharges>? extraCharges;

  // final num? productAmount;
  // final num? vehiclePrice;
  final double fixedAmount;
  final double weightAmount;
  final double distanceAmount;
  final double vehicleAmount;
  final double? insuranceAmount;
  final double? diffWeight;
  final double? diffDistance;
  final double? totalAmount;
  final double? baseTotal;
  double? perWeightCharge;
  double? perkmVehiclePrice;
  double? perKmCityDataCharge;
  final CouponModel? coupon;
  final bool isAppliedCoupon;

  OrderAmountDataWidget({
    required this.fixedAmount,
    required this.weightAmount,
    required this.distanceAmount,
    required this.vehicleAmount,
    required this.insuranceAmount,
    required this.diffWeight,
    required this.diffDistance,
    required this.totalAmount,
    required this.extraCharges,
    required this.baseTotal,
    required this.perWeightCharge,
    required this.perkmVehiclePrice,
    required this.perKmCityDataCharge,
    required this.coupon,
    required this.isAppliedCoupon,
  });

  @override
  OrderAmountDataWidgetState createState() => OrderAmountDataWidgetState();
}

class OrderAmountDataWidgetState extends State<OrderAmountDataWidget> {
  double baseTotal = 0;
  double? extraChargesTotal = 0;

  @override
  void initState() {
    super.initState();
    baseTotal = widget.baseTotal!.toDouble();
    cal();
    setState(() {});
  }

  cal() async {
    double chargesTotal = 0;
    widget.extraCharges!.forEach((element) async {
      double i = 0;
      if (element.chargesType == CHARGE_TYPE_PERCENTAGE) {
        i = (widget.baseTotal!.toDouble() * element.charges!.toDouble() * 0.01)
            .toStringAsFixed(digitAfterDecimal)
            .toDouble();
      } else {
        i = element.charges!.toStringAsFixed(digitAfterDecimal).toDouble();
      }

      chargesTotal = chargesTotal += element.charges!;
    });
    extraChargesTotal = chargesTotal;
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  double calculateTotalAmount() {
    double totalAmount = widget.totalAmount?.toDouble() ?? 0.00;
    double result = 0.00;

    if (widget.coupon?.valueType == "fixed") {
      double couponAmount = widget.coupon?.discountAmount?.toDouble() ?? 0;
      double finalTotal =
      (totalAmount - couponAmount).clamp(0.00, double.infinity);
      result = widget.isAppliedCoupon ? finalTotal : totalAmount;
    } else if (widget.coupon?.valueType == "percentage") {
      double percentage = widget.coupon?.discountAmount?.toDouble() ?? 0;
      double discountAmount = (totalAmount * percentage) / 100;
      double finalAmount =
      (totalAmount - discountAmount).clamp(0.00, double.infinity);

      result = widget.isAppliedCoupon ? finalAmount : totalAmount;
    } else if (widget.coupon == null && widget.isAppliedCoupon == false) {
      result = totalAmount.toDouble();
    }

    return (result * 100).round() / 100;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (appStore.isVehicleOrder == 1)
            Row(
              children: [
                Text("${language.vehicle} ${language.price.toLowerCase()}",
                    style: secondaryTextStyle()),
                4.width,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        '(${widget.diffDistance!.toStringAsFixed(digitAfterDecimal)} x ',
                        style: secondaryTextStyle()),
                    Text(
                        '${widget.perkmVehiclePrice!.toStringAsFixed(digitAfterDecimal)})',
                        style: secondaryTextStyle()),
                  ],
                ).visible(widget.diffDistance!.toDouble() > 0).expand(),
                16.width,
                Text('${printAmount(widget.vehicleAmount)}',
                    style: boldTextStyle(size: 14)),
              ],
            ).paddingBottom(8),
          // ).paddingBottom(8).visible(widget.vehicleAmount != 0),
          Row(
            children: [
              Text(language.weightCharge, style: secondaryTextStyle()),
              4.width,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('(${widget.diffWeight} x ', style: secondaryTextStyle()),
                  Text('${widget.perWeightCharge})',
                      style: secondaryTextStyle()),
                ],
              ).visible(widget.diffWeight!.toDouble() > 0).expand(),
              16.width,
              Text('${printAmount(widget.weightAmount)}',
                  style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(widget.weightAmount != 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.deliveryCharge, style: secondaryTextStyle()),
              16.width,
              Text('${printAmount(widget.fixedAmount)}',
                  style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(widget.fixedAmount.validate() != 0),
          if (appStore.isInsuranceAllowed == "1" && widget.insuranceAmount != 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.insuranceCharge, style: secondaryTextStyle()),
                16.width,
                Text('${printAmount(widget.insuranceAmount)}',
                    style: boldTextStyle(size: 14)),
              ],
            ).paddingBottom(8),
          Row(
            children: [
              Text(language.distanceCharge, style: secondaryTextStyle()),
              4.width,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      '(${widget.diffDistance!.toStringAsFixed(digitAfterDecimal)}',
                      style: secondaryTextStyle()),
                  Icon(Icons.close, color: Colors.grey, size: 12),
                  Text('${widget.perKmCityDataCharge})',
                      style: secondaryTextStyle()),
                ],
              ).visible(widget.diffDistance!.toDouble() > 0).expand(),
              16.width,
              Text('${printAmount(widget.distanceAmount)}',
                  style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(widget.distanceAmount != 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.extraCharges, style: boldTextStyle(size: 14)),
              8.height,
              Column(
                  children: List.generate(widget.extraCharges!.length, (index) {
                ExtraCharges mData = widget.extraCharges!.elementAt(index);
                print("-----------${mData.charges}");
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                          mData.title!
                              .replaceAll("_", " ")
                              .capitalizeFirstLetter(),
                          style: secondaryTextStyle()),
                      4.width,
                      Text('(${mData.chargesType == CHARGE_TYPE_PERCENTAGE ? '${mData.charges}%' : '${printAmount(mData.charges!.toDouble())}'})',
                              style: secondaryTextStyle())
                          .expand(),
                      16.width,
                      Text(
                          '${printAmount(countExtraCharge(totalAmount: widget.baseTotal!, chargesType: !mData.chargesType.isEmptyOrNull ? mData.chargesType! : "", charges: mData.charges!))}',
                          style: boldTextStyle(size: 14)),
                    ],
                  ),
                );
              }).toList()),
            ],
          ).visible(widget.extraCharges!.length != 0),
          widget.coupon != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.couponApplied,
                        style: boldTextStyle(color: darkRed)),
                    Text(printAmount((widget.totalAmount! - calculateTotalAmount()) ?? 0),
                        style: boldTextStyle(color: darkRed))
                  ],
                )
                  .paddingBottom(8)
                  .visible(widget.isAppliedCoupon && widget.coupon != null)
              : SizedBox.shrink(),
          Divider(color: context.dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.total,
                  style: boldTextStyle(
                    size: 18,
                    color: Colors.green,
                  )),
              // Text('${printAmount((extraChargesTotal! + baseTotal + widget.insuranceAmount!.toDouble()))}',
              Text('${appStore.currencySymbol} ${calculateTotalAmount()}',
                  style: boldTextStyle(
                    size: 18,
                    color: Colors.green,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

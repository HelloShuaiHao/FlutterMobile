import 'package:flutter/material.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/num_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/utils/Common.dart';
import '../../main.dart';
import '../models/OrderDetailModel.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class OrderSummeryWidget extends StatefulWidget {
  static String tag = '/OrderSummeryWidget';

  final List<ExtraChargeRequestModel> extraChargesList;
  // final num? productAmount;
  final num? vehiclePrice;
  final num totalDistance;
  final num totalWeight;
  final num distanceCharge;
  final num weightCharge;
  final num totalAmount;
  final String? status;
  final Payment? payment;
  final bool? isDetail;
  final num? insuranceCharge;
  final num? baseTotal;
  final bool? isInsuranceChargeDisplay;

  OrderSummeryWidget(
      {
      //this.productAmount,
      this.vehiclePrice,
      required this.extraChargesList,
      required this.totalDistance,
      required this.totalWeight,
      required this.distanceCharge,
      required this.weightCharge,
      required this.totalAmount,
      this.status,
      this.payment,
      this.isDetail = false,
      this.insuranceCharge = 0,
      this.isInsuranceChargeDisplay = false,
      this.baseTotal});

  @override
  OrderSummeryWidgetState createState() => OrderSummeryWidgetState();
}

class OrderSummeryWidgetState extends State<OrderSummeryWidget> {
  num fixedCharges = 0;
  num minDistance = 0;
  num minWeight = 0;
  num perDistanceCharges = 0;
  num perWeightCharges = 0;
  List<ExtraChargeRequestModel> extraList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    widget.extraChargesList.forEach((element) {
      if (element.key == FIXED_CHARGES) {
        fixedCharges = element.value!;
      } else if (element.key == MIN_DISTANCE) {
        minDistance = element.value!;
      } else if (element.key == MIN_WEIGHT) {
        minWeight = element.value!;
      } else if (element.key == PER_DISTANCE_CHARGE) {
        perDistanceCharges = element.value!;
      } else if (element.key == PER_WEIGHT_CHARGE) {
        perWeightCharges = element.value!;
      } else {
        extraList.add(element);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
          if (widget.isInsuranceChargeDisplay!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.insuranceCharge, style: secondaryTextStyle()),
                16.width,
                Text('${printAmount(widget.insuranceCharge)}', style: boldTextStyle(size: 14)),
              ],
            ).paddingBottom(8).visible(widget.isInsuranceChargeDisplay!),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${language.vehicle} ${language.price.toLowerCase()}", style: secondaryTextStyle()),
              16.width,
              Text('${printAmount(widget.vehiclePrice)}', style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(widget.vehiclePrice.validate() != 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.deliveryCharge, style: secondaryTextStyle()),
              16.width,
              Text('${printAmount(fixedCharges)}', style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(fixedCharges.validate() != 0),
          Row(
            children: [
              Text(language.distanceCharge, style: secondaryTextStyle()),
              4.width,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('(${(widget.totalDistance - minDistance).toStringAsFixed(digitAfterDecimal)}',
                      style: secondaryTextStyle()),
                  Icon(Icons.close, color: Colors.grey, size: 12),
                  Text('$perDistanceCharges)', style: secondaryTextStyle()),
                ],
              ).expand(),
              16.width,
              Text('${printAmount(widget.distanceCharge)}', style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(widget.distanceCharge != 0),
          Row(
            children: [
              Text(language.weightCharge, style: secondaryTextStyle()),
              4.width,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('(${widget.totalWeight - minWeight} x ', style: secondaryTextStyle()),
                  Text('$perWeightCharges)', style: secondaryTextStyle()),
                ],
              ).expand(),
              16.width,
              Text('${printAmount(widget.weightCharge)}', style: boldTextStyle(size: 14)),
            ],
          ).paddingBottom(8).visible(widget.weightCharge != 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.height,
              Text(language.extraCharges, style: boldTextStyle(size: 14)),
              8.height,
              Column(
                  children: List.generate(extraList.length, (index) {
                ExtraChargeRequestModel mData = extraList.elementAt(index);
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(mData.key!.replaceAll("_", " "), style: primaryTextStyle()),
                      SizedBox(width: 4),
                      Expanded(
                          child: Text(
                              '(${mData.valueType == CHARGE_TYPE_PERCENTAGE ? '${mData.value}%' : '${printAmount(mData.value ?? 0)}'})',
                              style: secondaryTextStyle())),
                      SizedBox(width: 16),
                      Text(
                          '${printAmount(countExtraCharge(totalAmount: (fixedCharges + widget.weightCharge + widget.vehiclePrice.validate() + widget.distanceCharge + widget.insuranceCharge.validate()), chargesType: mData.valueType!, charges: mData.value!))}',
                          style: boldTextStyle(size: 14)),
                    ],
                  ),
                );
              }).toList()),
            ],
          ).visible(extraList.length != 0),
          Divider(color: context.dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.total,
                  style: boldTextStyle(
                      size: 18,
                      color: Colors.green,
                      decoration: (widget.status.validate() == ORDER_CANCELLED &&
                              widget.payment != null &&
                              widget.payment!.deliveryManFee == 0)
                          ? TextDecoration.lineThrough
                          : null)),
              Text('${printAmount(widget.totalAmount.validate())}',
                  style: boldTextStyle(
                      size: 18,
                      color: Colors.green,
                      decoration: (widget.status.validate() == ORDER_CANCELLED &&
                              widget.payment != null &&
                              widget.payment!.deliveryManFee == 0)
                          ? TextDecoration.lineThrough
                          : null)),
            ],
          ),
          if (widget.status.validate() == ORDER_CANCELLED &&
              widget.payment != null &&
              widget.payment!.deliveryManFee == 0) ...[
            5.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.orderCancelCharge,
                    style: boldTextStyle(
                      size: 18,
                      color: Colors.red,
                    )),
                Text('${printAmount(widget.payment!.cancelCharges.validate())}',
                    style: boldTextStyle(
                      size: 18,
                      color: Colors.red,
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

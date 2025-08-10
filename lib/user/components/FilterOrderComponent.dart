import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/models.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

class FilterOrderComponent extends StatefulWidget {
  static String tag = '/FilterOrderComponent';

  @override
  FilterOrderComponentState createState() => FilterOrderComponentState();
}

class FilterOrderComponentState extends State<FilterOrderComponent> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  FilterAttributeModel? filterData;

  DateTime? fromDate, toDate;
  List<String> statusList = [
    ORDER_CREATED,
    ORDER_ACCEPTED,
    ORDER_CANCELLED,
    ORDER_ASSIGNED,
    ORDER_ARRIVED,
    ORDER_PICKED_UP,
    ORDER_DELIVERED,
    ORDER_DEPARTED,
    ORDER_SHIPPED
  ];
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    if (filterData != null) {
      selectedStatus = filterData!.orderStatus;
      if (filterData!.fromDate != null) {
        fromDate = DateTime.tryParse(filterData!.fromDate!);
        if (fromDate != null) {
          fromDateController.text = fromDate.toString();
        }
      }
      if (filterData!.toDate != null) {
        toDate = DateTime.tryParse(filterData!.toDate!);
        if (toDate != null) {
          toDateController.text = toDate.toString();
        }
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.all(4),
                  decoration: boxDecorationWithRoundedCorners(
                      boxShape: BoxShape.circle, backgroundColor: Colors.transparent, border: Border.all()),
                  child: Icon(
                    AntDesign.close,
                    size: 16,
                  ).onTap(() {
                    finish(context);
                  }),
                ),
                Text(language.filter, style: boldTextStyle()).expand(),
                TextButton(
                  child: Text(language.reset, style: boldTextStyle()),
                  onPressed: () {
                    selectedStatus = null;
                    fromDate = null;
                    toDate = null;
                    fromDateController.clear();
                    toDateController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                ),
              ],
            ),
            Divider(height: 20, color: context.dividerColor),
            Text(language.status, style: boldTextStyle()),
            8.height,
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: statusList.map((item) {
                return Chip(
                  backgroundColor: selectedStatus == item ? ColorUtils.colorPrimary : Colors.transparent,
                  label: Text(orderStatus(item)),
                  elevation: 0,
                  labelStyle:
                      primaryTextStyle(size: 14, color: selectedStatus == item ? white : textPrimaryColorGlobal),
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    side: BorderSide(
                        color: selectedStatus == item ? ColorUtils.colorPrimary : ColorUtils.borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                  ),
                ).onTap(() {
                  selectedStatus = item;
                  setState(() {});
                });
              }).toList(),
            ),
            16.height,
            Text(language.date, style: boldTextStyle()),
            16.height,
            Row(
              children: [
                DateTimePicker(
                  controller: fromDateController,
                  type: DateTimePickerType.date,
                  fieldHintText: language.from,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  onChanged: (value) {
                    fromDate = DateTime.parse(value);
                    fromDateController.text = value;
                    setState(() {});
                  },
                  validator: (value) {
                    if (fromDate == null && toDate != null) {
                      return language.mustSelectStartDate;
                    }
                    return null;
                  },
                  decoration: commonInputDecoration(suffixIcon: Ionicons.calendar_outline, hintText: language.from),
                ).expand(),
                16.width,
                DateTimePicker(
                  controller: toDateController,
                  type: DateTimePickerType.date,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2010),
                  onChanged: (value) {
                    toDate = DateTime.parse(value);
                    toDateController.text = value;
                    setState(() {});
                  },
                  validator: (value) {
                    if (fromDate != null && toDate != null) {
                      Duration difference = fromDate!.difference(toDate!);
                      if (difference.inDays >= 0) {
                        return language.toDateValidationMsg;
                      }
                    }
                    return null;
                  },
                  decoration: commonInputDecoration(suffixIcon: Ionicons.calendar_outline, hintText: language.to),
                ).expand(),
              ],
            ),
            20.height,
            commonButton(language.applyFilter, () {
              if (_formKey.currentState!.validate()) {
                finish(context);
                if (fromDate != null && toDate == null) {
                  toDate = DateTime.parse(DateTime.now().toString());
                }
                setValue(
                    FILTER_DATA,
                    FilterAttributeModel(
                            orderStatus: selectedStatus, fromDate: fromDate.toString(), toDate: toDate.toString())
                        .toJson());
                appStore.setFiltering(selectedStatus != null || fromDate != null || toDate != null);
                LiveStream().emit("UpdateOrderData");
              }
            }, width: context.width()),
          ],
        ),
      ),
    );
  }
}

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import '../../extensions/common.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

class FilterCountScreen extends StatefulWidget {
  const FilterCountScreen({super.key});

  @override
  State<FilterCountScreen> createState() => _FilterCountScreenState();
}

class _FilterCountScreenState extends State<FilterCountScreen> {
  List<String?> filterString = [
    language.today,
    language.yesterday,
    language.thisWeek,
    language.thisMonth,
    language.thisYear,
    language.custom
  ];
  int? currentIndex = 0;
  TextEditingController pickFromTimeController = TextEditingController();
  TextEditingController pickToTimeController = TextEditingController();

  DateTime now = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime(now.year, now.month, now.day);
    endDate = startDate!.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.topLeft,
            decoration: boxDecorationWithShadow(
                backgroundColor: ColorUtils.colorPrimary,
                borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.orderFilter, style: boldTextStyle(size: 20, color: Colors.white)).paddingLeft(12),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            children: List.generate(
              filterString.length,
              (index) {
                return RadioListTile(
                  value: index,
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  groupValue: currentIndex,
                  activeColor: ColorUtils.colorPrimary,
                  title: Text(filterString[index]!, style: primaryTextStyle()),
                  onChanged: (dynamic val) {
                    currentIndex = index;
                    DateTime now = DateTime.now();
                    switch (val) {
                      case 0:
                        startDate = DateTime(now.year, now.month, now.day);
                        endDate = startDate!.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));
                        break;
                      case 1:
                        startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
                        endDate = DateTime(now.year, now.month, now.day).subtract(Duration(milliseconds: 1));
                        break;
                      case 2:
                        final weekDay = now.weekday;
                        startDate = now.subtract(Duration(days: weekDay - 1));
                        startDate = DateTime(startDate!.year, startDate!.month, startDate!.day);
                        endDate = startDate!.add(Duration(days: 7)).subtract(Duration(milliseconds: 1));
                        break;
                      case 3:
                        startDate = DateTime(now.year, now.month, 1);
                        endDate = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));
                        break;
                      case 4:
                        startDate = DateTime(now.year, 1, 1);
                        endDate = DateTime(now.year + 1, 1, 1).subtract(Duration(milliseconds: 1));
                        break;
                      case 5:
                        break;
                    }
                    setState(() {});
                  },
                );
              },
            ),
          ),
          if (currentIndex == 5) ...[
            DateTimePicker(
              controller: pickFromTimeController,
              type: DateTimePickerType.date,
              firstDate: DateTime(1999),
              lastDate: DateTime(2050),
              onChanged: (value) {
                startDate = DateTime.parse(value);
              },
              validator: (value) {
                if (value!.isEmpty) return language.fieldRequiredMsg;
                return null;
              },
              decoration: commonInputDecoration(hintText: "${language.from} ${language.date}"),
            ).paddingOnly(left: 65, right: 15),
            5.height,
            DateTimePicker(
              controller: pickToTimeController,
              type: DateTimePickerType.date,
              firstDate: DateTime(1999),
              lastDate: DateTime(2050),
              onChanged: (value) {
                endDate = DateTime.parse(value);
              },
              validator: (value) {
                if (value!.isEmpty) return language.fieldRequiredMsg;
                return null;
              },
              decoration: commonInputDecoration(hintText: "${language.to} ${language.date}"),
            ).paddingOnly(left: 65, right: 15),
            5.height,
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              commonButton(
                language.ok,
                () {
                  if (currentIndex != 5) {
                    finish(context, [startDate, endDate]);
                  } else {
                    if (pickFromTimeController.text.isEmpty || pickToTimeController.text.isEmpty) {
                      toast(language.mustSelectDate);
                    } else {
                      finish(context, [startDate, endDate]);
                    }
                  }
                },
                // width: context.width(),
              ).paddingOnly(bottom: 22),
            ],
          ),
        ],
      ),
    );
  }
}

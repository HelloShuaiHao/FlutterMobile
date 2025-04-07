import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/LiveStream.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/DataProviders.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

class CancelOrderDialog extends StatefulWidget {
  static String tag = '/CancelOrderDialog';

  final int orderId;
  final Function? onUpdate;

  CancelOrderDialog({required this.orderId, this.onUpdate});

  @override
  CancelOrderDialogState createState() => CancelOrderDialogState();
}

class CancelOrderDialogState extends State<CancelOrderDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController reasonController = TextEditingController();
  String? reason;

  List<String> userCancelOrderReasonList = getUserCancelReasonList();
  List<String> deliveryBoyCancelOrderReasonList = getDeliveryCancelReasonList();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    LiveStream().on('UpdateLanguage', (p0) {
      userCancelOrderReasonList.clear();
      deliveryBoyCancelOrderReasonList.clear();
      userCancelOrderReasonList.addAll(getUserCancelReasonList());
      deliveryBoyCancelOrderReasonList.addAll(getDeliveryCancelReasonList());
      setState(() {});
    });
  }

  updateOrderApiCall() async {
    finish(context);
    appStore.setLoading(true);
    await updateOrder(
      orderId: widget.orderId,
      reason: reason!.validate().trim() != language.other.trim() ? reason : reasonController.text,
      orderStatus: ORDER_CANCELLED,
    ).then((value) {
      appStore.setLoading(false);
      widget.onUpdate!.call();
      toast(language.orderCancelledSuccessfully);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.cancelOrder, style: boldTextStyle(size: 18)),
              Icon(
                Ionicons.close_circle_outline,
                color: ColorUtils.colorPrimary,
              ).onTap(() {
                finish(context);
              }),
            ],
          ),
          16.height,
          Text(language.reason, style: primaryTextStyle()),
          8.height,
          DropdownButtonFormField<String>(
            value: reason,
            isExpanded: true,
            isDense: true,
            decoration: commonInputDecoration(),
            items: (getStringAsync(USER_TYPE) == CLIENT ? userCancelOrderReasonList : deliveryBoyCancelOrderReasonList)
                .map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: (String? val) {
              reason = val;
              setState(() {});
            },
            validator: (value) {
              if (value == null) return language.fieldRequiredMsg;
              return null;
            },
          ),
          16.height,
          AppTextField(
            controller: reasonController,
            textFieldType: TextFieldType.OTHER,
            decoration: commonInputDecoration(hintText: language.writeReasonHere),
            maxLines: 3,
            minLines: 3,
            validator: (value) {
              if (value!.isEmpty) return language.fieldRequiredMsg;
              return null;
            },
          ).visible(reason.validate().trim() == language.other.trim()),
          16.height,
          commonButton(language.submit, () {
            if (formKey.currentState!.validate()) {
              updateOrderApiCall();
            }
          }, width: context.width())
        ],
      ),
    );
  }
}

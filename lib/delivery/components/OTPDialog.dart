import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/services/AuthServices.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../../extensions/common.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/dynamic_theme.dart';

class OTPDialog extends StatefulWidget {
  final String? phoneNumber;
  final Function()? onUpdate;
  final String? verificationId;

  OTPDialog({this.phoneNumber, this.onUpdate, this.verificationId});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  OtpFieldController otpController = OtpFieldController();
  String verId = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    verId = widget.verificationId.validate();
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.message, color: ColorUtils.colorPrimary, size: 50),
            16.height,
            Text(language.otpVerification, style: boldTextStyle(size: 18)),
            16.height,
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(language.enterTheCodeSendTo, style: secondaryTextStyle(size: 16)),
                4.width,
                Text(widget.phoneNumber.validate(), style: boldTextStyle()),
              ],
            ),
            30.height,
            Directionality(
              textDirection: TextDirection.ltr,
              child: OTPTextField(
                controller: otpController,
                length: 6,
                width: MediaQuery.of(context).size.width,
                fieldWidth: 35,
                style: primaryTextStyle(),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.box,
                onChanged: (s) {
                  //
                },
                onCompleted: (pin) async {
                  appStore.setLoading(true);
                  AuthCredential credential = PhoneAuthProvider.credential(verificationId: verId, smsCode: pin);
                  await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
                    appStore.setLoading(false);
                    finish(context);
                    widget.onUpdate!.call();
                  }).catchError((error) {
                    appStore.setLoading(false);
                    toast(language.invalidVerificationCode);
                    finish(context);
                  });
                },
              ),
            ),
            30.height,
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(language.didNotReceiveTheCode, style: secondaryTextStyle(size: 16)),
                4.width,
                Text(language.resend, style: boldTextStyle(color: ColorUtils.colorPrimary)).onTap(() {
                  sendOtp(context, phoneNumber: widget.phoneNumber.validate(), onUpdate: (verificationId) {
                    verId = verificationId;
                    setState(() {});
                  });
                }),
              ],
            ),
          ],
        ),
        Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
      ],
    );
  }
}

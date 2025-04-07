import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/bool_extensions.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/system_utils.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/utils/Widgets.dart';
import '../../user/screens/DashboardScreen.dart';
import 'package:otp_text_field/otp_field.dart' as otp;
import 'package:otp_text_field/otp_field_style.dart' as o;
import 'package:otp_text_field/style.dart';

import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  final bool? isSignIn;
  final bool? isSignUp;

  EmailVerificationScreen({this.isSignIn = false, this.isSignUp = false});

  @override
  EmailVerificationScreenState createState() => EmailVerificationScreenState();
}

class EmailVerificationScreenState extends State<EmailVerificationScreen> {
  otp.OtpFieldController otpController = otp.OtpFieldController();

  bool? isEmailSend = false;
  String verId = '';
  String? otpPin = '';

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  userDetailGet() async {
    await getUserDetail(getIntAsync(USER_ID)).then((value) async {
      appStore.setLoading(false);
      setValue(OTP_VERIFIED, value.otpVerifyAt != null);
      setState(() {});
      if (getBoolAsync(OTP_VERIFIED).validate()) {
        DashboardScreen().launch(context, isNewTask: true);
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  verifyOtpEmailApiCall(pin) async {
    hideKeyboard(context);
    appStore.setLoading(true);
    await verifyOtpEmail({"code": pin}).then((value) async {
      setValue(EMAIL_VERIFIED, true);
      toast(value.message.toString());
      finish(context);
      appStore.setLoading(false);
    }).catchError((e) {
      otpController.clear();
      hideKeyboard(context);
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  resendOtpEmailApiCall() async {
    appStore.setLoading(true);
    await resendOtpEmail().then((value) {
      hideKeyboard(context);
      appStore.setLoading(false);
      toast(value.message.toString());
    }).catchError((e) {
      hideKeyboard(context);
      appStore.setLoading(false);
      toast(e['message']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(Duration(seconds: 3), () {
          userDetailGet();
        });
      },
      child: CommonScaffoldComponent(
        body: Stack(
          children: [
            widget.isSignIn == true && isEmailSend == false
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        16.height,
                        Text(language.emailVerification, style: boldTextStyle(size: 18)),
                        16.height,
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: secondaryTextStyle(),
                            children: [
                              TextSpan(text: '${language.weSend} '),
                              TextSpan(text: language.oneTimePassword, style: boldTextStyle()),
                              TextSpan(
                                  text: " ${language.on} " +
                                      getStringAsync(USER_EMAIL).replaceAll(RegExp(r'(?<=.{3}).(?=.*@)'), '*'))
                            ],
                          ),
                        ),
                        16.height,
                        commonButton(language.getEmail, () {
                          resendOtpEmailApiCall();
                          isEmailSend = true;
                          setState(() {});
                        }, width: context.width())
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        16.height,
                        Text(language.confirmationCode, style: boldTextStyle(size: 18)),
                        16.height,
                        Text(
                            "${language.confirmationCodeSent} " +
                                getStringAsync(USER_EMAIL).replaceAll(RegExp(r'(?<=.{3}).(?=.*@)'), '*'),
                            style: secondaryTextStyle(size: 16),
                            textAlign: TextAlign.center),
                        30.height,
                        otp.OTPTextField(
                          controller: otpController,
                          length: 5,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 35,
                          otpFieldStyle: o.OtpFieldStyle(
                              borderColor: context.dividerColor, focusBorderColor: ColorUtils.colorPrimary),
                          style: primaryTextStyle(),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.box,
                          onChanged: (s) {
                            //
                          },
                          onCompleted: (pin) async {
                            otpPin = pin;

                            setState(() {});
                          },
                        ),
                        30.height,
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(language.didNotReceiveTheCode, style: secondaryTextStyle(size: 16)),
                            4.width,
                            Text(language.resend, style: boldTextStyle(color: ColorUtils.colorPrimary)).onTap(() {
                              resendOtpEmailApiCall();
                            }),
                          ],
                        ),
                        16.height,
                        commonButton(language.submit, () async {
                          verifyOtpEmailApiCall(otpPin);
                        }, width: context.width())
                      ],
                    ),
                  ),
            Observer(
                builder: (context) =>
                    Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
          ],
        ),
      ),
    );
  }
}

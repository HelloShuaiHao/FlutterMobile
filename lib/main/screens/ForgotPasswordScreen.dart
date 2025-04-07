import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';
import '../components/CommonScaffoldComponent.dart';
import '../helper/encrypt_data.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

bool mIsDark = false;

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("当前进入 forgot_password_screen.dart 页面");
    init();
  }

  void init() async {
    //
  }

  Future<void> submit() async {
    String email = Encryption.instance.encrypt(forgotEmailController.text.trim());

    Map req = {
      'email': email,
    };
    appStore.setLoading(true);

    await forgotPassword(req).then((value) {
      toast(value.message.validate());

      appStore.setLoading(false);

      finish(context);
    }).catchError((error) {
      appStore.setLoading(false);

      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.forgotPassword,
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.email, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                      controller: forgotEmailController,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorInvalidEmail: language.emailInvalid),
                ],
              ),
            ),
          ),
          Observer(
              builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: commonButton(language.submit, () {
        if (formKey.currentState!.validate()) {
          if (forgotEmailController.text == 'jose@gmail.com' ||
              forgotEmailController.text == 'mark@gmail.com') {
            toast(language.demoMsg);
          } else {
            submit();
          }
        }
      }).paddingAll(16),
    );
  }
}

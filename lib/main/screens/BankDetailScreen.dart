import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';
import '../models/LoginResponse.dart';
import '../network/NetworkUtils.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class BankDetailScreen extends StatefulWidget {
  final bool? isWallet;

  BankDetailScreen({this.isWallet = false});

  @override
  _BankDetailScreenState createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameCon = TextEditingController();
  TextEditingController accNumberCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  TextEditingController ifscCCon = TextEditingController();
  TextEditingController bankAddressCon = TextEditingController();
  TextEditingController routingNumberCon = TextEditingController();
  TextEditingController bankSwiftCon = TextEditingController();
  TextEditingController bankIbanCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("当前进入 BankDetailScreen");
    init();
  }

  void init() async {
    getBankDetail();
  }

  getBankDetail() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      appStore.setLoading(false);
      if (value.userBankAccount != null) {
        bankNameCon.text = value.userBankAccount!.bankName.validate();
        accNumberCon.text = value.userBankAccount!.accountNumber.validate();
        nameCon.text = value.userBankAccount!.accountHolderName.validate();
        ifscCCon.text = value.userBankAccount!.bankCode.validate();
        bankAddressCon.text = value.userBankAccount!.bankAddress.validate();
        routingNumberCon.text = value.userBankAccount!.routingNumber.validate();
        bankSwiftCon.text = value.userBankAccount!.bankSwift.validate();
        bankIbanCon.text = value.userBankAccount!.bankIban.validate();
        setState(() {});
      }
    }).then((value) {
      appStore.setLoading(false);
    });
  }

  saveBankDetail() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
      multiPartRequest.fields['username'] = getStringAsync(USER_NAME);
      multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
      multiPartRequest.fields['contact_number'] = getStringAsync(USER_CONTACT_NUMBER).validate();
      multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL);
      multiPartRequest.fields['user_bank_account[bank_name]'] = bankNameCon.text.trim();
      multiPartRequest.fields['user_bank_account[account_number]'] = accNumberCon.text.trim();
      multiPartRequest.fields['user_bank_account[account_holder_name]'] = nameCon.text.trim();
      multiPartRequest.fields['user_bank_account[bank_code]'] = ifscCCon.text.trim();
      multiPartRequest.fields['user_bank_account[bank_address]'] = bankAddressCon.text.trim();
      multiPartRequest.fields['user_bank_account[routing_number]'] = routingNumberCon.text.trim();
      multiPartRequest.fields['user_bank_account[bank_iban]'] = bankIbanCon.text.trim();
      multiPartRequest.fields['user_bank_account[bank_swift]'] = bankSwiftCon.text.trim();
      multiPartRequest.headers.addAll(buildHeaderTokens());
      sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          if (data != null) {
            LoginResponse res = LoginResponse.fromJson(data);
            toast(res.message.toString());
            appStore.setLoading(false);
            finish(context);
          }
        },
        onError: (error) {
          log(multiPartRequest.toString());
          toast(error.toString(), print: true);
          appStore.setLoading(false);
        },
      ).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return CommonScaffoldComponent(
        appBarTitle: language.bankDetails,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.height,
                    Text(language.bankName, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: bankNameCon,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.bankName),
                    ),
                    16.height,
                    Text(language.accountNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: accNumberCon,
                      textFieldType: TextFieldType.PHONE,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.accountNumber),
                    ),
                    16.height,
                    Text(language.nameAsPerBank, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: nameCon,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.nameAsPerBank),
                    ),
                    16.height,
                    Text(language.bankAddress, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: bankAddressCon,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.bankAddress),
                    ),
                    16.height,
                    Text(language.ifscCode, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: false,
                      controller: ifscCCon,
                      textFieldType: TextFieldType.NAME,
                      decoration: commonInputDecoration(hintText: language.ifscCode),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                    ),
                    16.height,
                    Text(language.routingNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: false,
                      controller: routingNumberCon,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.routingNumber),
                    ),
                    16.height,
                    Text(language.bankIban, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: false,
                      controller: bankIbanCon,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.bankIban),
                    ),
                    16.height,
                    Text(language.bankSwift, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: false,
                      controller: bankSwiftCon,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.bankSwift),
                    ),
                    30.height,
                  ],
                ),
              ),
            ),
            loaderWidget().visible(appStore.isLoading)
          ],
        ),
        bottomNavigationBar: AppButton(
            color: ColorUtils.colorPrimary,
            textColor: Colors.white,
            text: language.save,
            onTap: () {
              saveBankDetail();
            }).paddingAll(16),
      );
    });
  }
}

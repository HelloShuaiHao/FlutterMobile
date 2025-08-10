import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../../extensions/extension_util/bool_extensions.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../components/CommonScaffoldComponent.dart';
import '../models/LoginResponse.dart';
import '../utils/Images.dart';
import '../utils/dynamic_theme.dart';
import 'UserCitySelectScreen.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';
  final bool? isGoogle;

  EditProfileScreen({this.isGoogle = false});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;

  TextEditingController emailController = TextEditingController();
  // TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  FocusNode emailFocus = FocusNode();
//  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  XFile? imageProfile;

  @override
  void initState() {
    super.initState();
    print("当前进入 edit_profile_screen.dart 页面");
    init();
  }

  Future<void> init() async {
    String phoneNum = getStringAsync(USER_CONTACT_NUMBER);
    emailController.text = getStringAsync(USER_EMAIL);
    // usernameController.text = getStringAsync(USER_NAME);
    nameController.text = getStringAsync(NAME);
    if (phoneNum.split(" ").length == 1) {
      contactNumberController.text = phoneNum.split(" ").last;
    } else {
      countryCode = phoneNum.split(" ").first;
      contactNumberController.text = phoneNum.split(" ").last;
    }
    addressController.text = getStringAsync(USER_ADDRESS).validate();
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Image.file(File(imageProfile!.path),
              height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center)
          .cornerRadiusWithClipRRect(100)
          .center();
    } else {
      if (appStore.userProfile.isNotEmpty) {
        return commonCachedNetworkImage(appStore.userProfile.validate(), fit: BoxFit.cover, height: 100, width: 100)
            .cornerRadiusWithClipRRect(100)
            .center();
      } else {
        return commonCachedNetworkImage(ic_profile, height: 90, width: 90)
            .cornerRadiusWithClipRRect(50)
            .paddingOnly(right: 4, bottom: 4)
            .center();
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future<void> save() async {
    appStore.setLoading(true);
    await updateProfile(
      file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
      name: nameController.text.validate(),
      userName: emailController.text.validate(),
      userEmail: emailController.text.validate(),
      address: addressController.text.validate(),
      contactNumber: '$countryCode ${contactNumberController.text.trim()}',
    ).then((value) {
      // finish(context);
    }).catchError((error) {
      log(error);
      appStore.setLoading(false);
    });
  }

  Future updateProfile(
      {String? userName, String? name, String? userEmail, String? address, String? contactNumber, File? file}) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
    multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
    multiPartRequest.fields['username'] = userName.validate();
    multiPartRequest.fields['email'] = userEmail ?? appStore.userEmail;
    multiPartRequest.fields['name'] = name.validate();
    multiPartRequest.fields['contact_number'] = contactNumber.validate();
    multiPartRequest.fields['address'] = address.validate();

    if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', file.path));

    await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
      if (data != null) {
        LoginResponse res = LoginResponse.fromJson(data);
        if (res.data != null) {
          appStore.setLoading(false);
          if (widget.isGoogle == true) {
            UserCitySelectScreen().launch(context, isNewTask: true);
          } else {
            Navigator.pop(context);
          }
          await setValue(NAME, res.data!.name.validate());
          await setValue(USER_NAME, res.data!.username.validate());
          await setValue(USER_ADDRESS, res.data!.address.validate());
          await setValue(USER_CONTACT_NUMBER, res.data!.contactNumber.validate());
          await appStore.setUserEmail(res.data!.email.validate());
          appStore.setUserProfile(res.data!.profileImage.validate());
        }
        toast(res.message.toString());
      }
    }, onError: (error) {
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
      showBack: !widget.isGoogle.validate(),
      appBarTitle: language.editProfile,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      profileImage(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.only(top: 60, left: 80),
                          padding: EdgeInsets.all(6),
                          decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: ColorUtils.colorPrimary,
                              border: Border.all(width: 1, color: Colors.white),
                              boxShape: BoxShape.circle),
                          child: Icon(
                            Icons.edit,
                            color: white,
                            size: 16,
                          ),
                        ),
                      )
                    ],
                  ).onTap(() {
                    getImage();
                  }, highlightColor: Colors.transparent, splashColor: Colors.transparent),
                  16.height,
                  Text(language.email, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    readOnly: true,
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    focus: emailFocus,
                    nextFocus: nameFocus,
                    decoration: commonInputDecoration(),
                    onTap: () {
                      toast(language.notChangeEmail);
                    },
                  ),
                  16.height,
                  Text(language.name, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: nameController,
                    textFieldType: TextFieldType.NAME,
                    focus: nameFocus,
                    nextFocus: addressFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.fieldRequiredMsg,
                  ),
                  16.height,
                  Text(language.contactNumber, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: contactNumberController,
                    textFieldType: TextFieldType.PHONE,
                    readOnly: !widget.isGoogle.validate(),
                    focus: contactFocus,
                    nextFocus: addressFocus,
                    decoration: commonInputDecoration(
                      prefixIcon: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountryCodePicker(
                              initialSelection: countryCode,
                              showCountryOnly: false,
                              dialogSize: Size(context.width() - 60, context.height() * 0.6),
                              showFlag: true,
                              enabled: widget.isGoogle.validate(),
                              showFlagDialog: true,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: primaryTextStyle(),
                              dialogBackgroundColor: Theme.of(context).cardColor,
                              barrierColor: Colors.black12,
                              dialogTextStyle: primaryTextStyle(),
                              searchDecoration: InputDecoration(
                                iconColor: Theme.of(context).dividerColor,
                                enabledBorder:
                                    UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                                focusedBorder:
                                    UnderlineInputBorder(borderSide: BorderSide(color: ColorUtils.colorPrimary)),
                              ),
                              searchStyle: primaryTextStyle(),
                              onInit: (c) {
                                countryCode = c!.dialCode!;
                              },
                              onChanged: (c) {
                                countryCode = c.dialCode!;
                              },
                            ),
                            VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.trim().isEmpty) return language.fieldRequiredMsg;
                      //  if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLength;
                      if (value.trim().length < minContactLength || value.trim().length > maxContactLength)
                        return language.phoneNumberInvalid;
                      return null;
                    },
                    onTap: () {
                      if (!widget.isGoogle.validate()) toast(language.notChangeMobileNo);
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  16.height,
                  if (!widget.isGoogle.validate()) ...[
                    Text(language.address, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: addressController,
                      textFieldType: TextFieldType.MULTILINE,
                      focus: addressFocus,
                      textInputAction: TextInputAction.done,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                    ),
                    16.height,
                  ],
                ],
              ),
            ),
          ),
          Observer(builder: (_) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.saveChanges, () {
          if (_formKey.currentState!.validate()) {
            if (getStringAsync(USER_EMAIL) == 'jose@gmail.com' || getStringAsync(USER_EMAIL) == 'mark@gmail.com') {
              toast(language.demoMsg);
            } else {
              save();
            }
          }
        }),
      ),
    );
  }
}

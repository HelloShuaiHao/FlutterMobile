import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import 'package:video_player/video_player.dart';
import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class AddSupportTicketScreen extends StatefulWidget {
  const AddSupportTicketScreen({super.key});

  @override
  State<AddSupportTicketScreen> createState() => _AddSupportTicketScreenState();
}

class _AddSupportTicketScreenState extends State<AddSupportTicketScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController messageCon = TextEditingController();
  TextEditingController supportTypeCon = TextEditingController();
  TextEditingController resolutionDetailcon = TextEditingController();
  String? selectedSupportType;
  String? selectedUploadValue;
  XFile? image;
  XFile? video;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  List<String> supportType = [
    language.supportType1,
    language.supportType2,
    language.supportType3,
    language.supportType4,
  ];

  @override
  void initState() {
    super.initState();
    print("当前进入 AddSupportTicketScreen");
    init();
  }

  void init() async {
    selectedSupportType = supportType[0];
  }

  @override
  void dispose() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }

    super.dispose();
  }

  Future saveCustomerSupportApi() async {
    appStore.setLoading(true);
    MultipartRequest multiPartRequest = await getMultiPartRequest('customersupport-save');
    multiPartRequest.fields['message'] = messageCon.text;
    multiPartRequest.fields['support_type'] = selectedSupportType!;
    multiPartRequest.fields['user_id'] = getIntAsync(USER_ID).toString();
    multiPartRequest.fields['status'] = "pending";
    if (image != null) multiPartRequest.files.add(await MultipartFile.fromPath('support_image', image!.path));
    if (video != null) multiPartRequest.files.add(await MultipartFile.fromPath('support_videos', image!.path));

    await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
      appStore.setLoading(false);
      toast(data['message']);
      finish(context);
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
      appBarTitle: language.addSupportTicket,
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
                  Text(language.message, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    isValidationRequired: true,
                    controller: messageCon,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.fieldRequiredMsg,
                    decoration: commonInputDecoration(hintText: language.message),
                  ),
                  16.height,
                  Text(language.supportType, style: primaryTextStyle()),
                  8.height,
                  Container(
                    width: context.width(),
                    height: 50,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.transparent),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: commonInputDecoration(),
                      hint: Text(language.selectDocument, style: primaryTextStyle()),
                      value: supportType[0],
                      dropdownColor: context.cardColor,
                      items: supportType.map((String e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: primaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) async {
                        selectedSupportType = value;
                        setState(() {});
                      },
                    ),
                  ),
                  16.height,
                  Text(language.uploadDetails, style: primaryTextStyle()),
                  8.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          height: 38,
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: Colors.transparent,
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Text(language.image, style: boldTextStyle(size: 12))
                              .paddingAll(6)
                              .center()
                              .onTap(() async {
                            image = null;
                            image = await ImagePicker().pickImage(source: ImageSource.gallery);
                            setState(() {});
                          })).expand(),
                      20.width,
                      Container(
                              height: 38,
                              decoration: boxDecorationWithRoundedCorners(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  backgroundColor: Colors.transparent),
                              child: Text(language.video, style: boldTextStyle(size: 12)).paddingAll(6).center())
                          .onTap(() async {
                        video = null;
                        video = await ImagePicker().pickVideo(source: ImageSource.gallery);
                        _controller = VideoPlayerController.file(File(video!.path.toString()));
                        _initializeVideoPlayerFuture = _controller!.initialize();
                        // Loop the video
                        _controller!.setLooping(true);
                        setState(() {});
                      }).expand()
                    ],
                  ),
                  16.height,
                  Text(language.image, style: primaryTextStyle()).visible(image != null && !image!.path.isEmptyOrNull),
                  8.height.visible(image != null && !image!.path.isEmptyOrNull),
                  if (image != null && !image!.path.isEmptyOrNull)
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                          border: Border.all(color: ColorUtils.colorPrimary), backgroundColor: Colors.transparent),
                      child: Image.file(File(image!.path),
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              alignment: Alignment.center)
                          .cornerRadiusWithClipRRect(10)
                          .center(),
                    ),
                  16.height.visible(video != null && !video!.path.isEmptyOrNull),
                  Text(language.video, style: primaryTextStyle()).visible(video != null && !video!.path.isEmptyOrNull),
                  8.height.visible(video != null && !video!.path.isEmptyOrNull),
                  if (_controller != null)
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                          border: Border.all(color: ColorUtils.colorPrimary), backgroundColor: Colors.transparent),
                      child: FutureBuilder(
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return AspectRatio(
                              aspectRatio: 6 / 3,
                              child: VideoPlayer(_controller!),
                            ).cornerRadiusWithClipRRect(10);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ).center(),
                    )
                ],
              ),
            ),
          ),
          Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
        ],
      ),
      bottomNavigationBar: AppButton(
          color: ColorUtils.colorPrimary,
          textColor: Colors.white,
          text: language.save,
          onTap: () {
            if (formKey.currentState!.validate()) {
              saveCustomerSupportApi();
            }
          }).paddingAll(16),
    );
  }
}

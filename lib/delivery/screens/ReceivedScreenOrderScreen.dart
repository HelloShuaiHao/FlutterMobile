import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Images.dart';
import '../../extensions/decorations.dart';
import '../../extensions/extension_util/bool_extensions.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/network/NetworkUtils.dart';
import '../../main/utils/Widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/services/AuthServices.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/components/CancelOrderDialog.dart';
import '../components/OTPDialog.dart';
import 'package:video_player/video_player.dart';

class ReceivedScreenOrderScreen extends StatefulWidget {
  final OrderData? orderData;
  final bool isShowPayment;

  ReceivedScreenOrderScreen({this.orderData, this.isShowPayment = false});

  @override
  ReceivedScreenOrderScreenState createState() =>
      ReceivedScreenOrderScreenState();
}

class ReceivedScreenOrderScreenState extends State<ReceivedScreenOrderScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  GlobalKey<SfSignaturePadState> signaturePicUPPadKey = GlobalKey();
  GlobalKey<SfSignaturePadState> signatureDeliveryPadKey = GlobalKey();

  ScreenshotController pickupScreenshotController = ScreenshotController();
  ScreenshotController deliveryScreenshotController = ScreenshotController();

  TextEditingController picUpController = TextEditingController();
  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  XFile? imageProfile;
  int val = 0;

  File? imageSignature;
  File? deliverySignature;
  bool mIsUpdate = false;
  int groupVal = 0;
  String? reason;
  bool mIsCheck = false;

  String? _pickupDatetime;
  String? _deliveryDatetime;

  List<File>? _image = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      _image!.add(File(pickedFile.path));
      setState(() {});
    }
  }

  void _removeImage(int index) {
    setState(() {
      _image!.removeAt(index);
    });
  }

  Future<void> init() async {
    mIsUpdate = widget.orderData != null;
    if (mIsUpdate) {
      if (widget.orderData!.pickupDatetime.validate().isEmpty) {
        _pickupDatetime =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
      } else {
        _pickupDatetime = widget.orderData!.pickupDatetime.validate();
      }
      picUpController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(
          DateTime.parse(widget.orderData!.pickupDatetime.validate().isEmpty
              ? DateTime.now().toString()
              : DateTime.parse(
                      "${widget.orderData!.pickupDatetime.validate()}Z")
                  .toLocal()
                  .toString()));
      reasonController.text = widget.orderData!.reason.validate();
      reason = widget.orderData!.reason.validate();
      log(picUpController);
    }

    if (widget.orderData!.status == ORDER_DEPARTED) {
      deliveryDateController.text =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      _deliveryDatetime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    }
  }

  Future<File> saveSignature(ScreenshotController screenshotController) async {
    final image =
        await screenshotController.capture(delay: Duration(milliseconds: 10));
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    if (image != null) {
      file.writeAsBytesSync(image);
    }
    return file;
  }

  saveDelivery() async {
    appStore.setLoading(true);
    // ----这里还需要修改，因为把id的int改成了string----
    // await updateOrder(
    //         orderId: widget.orderData!.id,
    //         pickupDatetime: _pickupDatetime,
    //         deliveryDatetime: _deliveryDatetime,
    //         clientName: (deliverySignature != null || imageSignature != null)
    //             ? '1'
    //             : '0',
    //         deliveryman: deliverySignature != null ? '1' : '0',
    //         picUpSignature: imageSignature,
    //         reason: reasonController.text,
    //         deliverySignature: deliverySignature,
    //         orderStatus: widget.orderData!.status == ORDER_DEPARTED
    //             ? ORDER_DELIVERED
    //             : ORDER_PICKED_UP,
    //         selectedFiles: _image)
    //     .then((value) {
    //   appStore.setLoading(false);
    //   toast(widget.orderData!.status == ORDER_DEPARTED
    //       ? language.orderDeliveredSuccessfully
    //       : language.orderPickupSuccessfully);
    //   finish(context, true);
    // }).catchError((error) {
    //   appStore.setLoading(false);
    //   log(error);
    // });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: commonAppBarWidget(
        widget.orderData!.status == ORDER_DEPARTED
            ? language.orderDeliver
            : language.orderPickup,
        backWidget: IconButton(
          onPressed: () {
            finish(context, false);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Observer(builder: (context) {
        return Form(
          key: formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isShowPayment.validate()) ...[
                      Text(
                          '${language.collectedAmount} : ${printAmount(widget.orderData!.totalAmount ?? 0)}',
                          style: boldTextStyle()),
                      8.height,
                    ],
                    if (widget.orderData!.paymentId == null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          color: Colors.red.withOpacity(0.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(defaultRadius),
                                    bottomLeft: Radius.circular(defaultRadius),
                                  ),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.info_outlined)),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.info, style: boldTextStyle()),
                                4.height,
                                widget.orderData!.paymentCollectFrom ==
                                        PAYMENT_ON_DELIVERY
                                    ? Text(language.paymentCollectFromDelivery,
                                        style: secondaryTextStyle(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2)
                                    : Text(language.paymentCollectFromPickup,
                                        style: secondaryTextStyle()),
                              ],
                            ).paddingAll(8).expand(),
                          ],
                        ),
                      ),
                    16.height,
                    Text(
                        '${language.order} ${language.pickupDatetime.toLowerCase()}',
                        style: boldTextStyle()),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      textFieldType: TextFieldType.OTHER,
                      controller: picUpController,
                      decoration: commonInputDecoration(),
                    ),
                    8.height,
                    if (widget.orderData!.status == ORDER_DEPARTED)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.deliveryDatetime,
                              style: boldTextStyle()),
                          8.height,
                          AppTextField(
                            readOnly: true,
                            textFieldType: TextFieldType.PHONE,
                            controller: deliveryDateController,
                            decoration: commonInputDecoration(),
                          ),
                        ],
                      ),
                    8.height,
                    Text(language.userSignature, style: boldTextStyle()),
                    8.height,
                    widget.orderData!.pickupConfirmByClient == 1 ||
                            widget.orderData!.status == ORDER_DEPARTED
                        ? commonCachedNetworkImage(
                            widget.orderData!.pickupTimeSignature,
                            fit: BoxFit.cover,
                            height: 150,
                            width: context.width())
                        : Container(
                            height: 150,
                            width: context.width(),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                color: Colors.grey.withOpacity(0.15)),
                            child: Screenshot(
                              controller: pickupScreenshotController,
                              child: SfSignaturePad(
                                key: signaturePicUPPadKey,
                                minimumStrokeWidth: 1,
                                maximumStrokeWidth: 3,
                                strokeColor: ColorUtils.colorPrimary,
                              ),
                            ),
                          ),
                    if (widget.orderData!.pickupConfirmByClient != 1)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            8.width,
                            TextButton(
                              child: Text(language.clear,
                                  style: boldTextStyle(
                                      color: ColorUtils.colorPrimary,
                                      decoration: TextDecoration.underline)),
                              onPressed: () async {
                                signaturePicUPPadKey.currentState!.clear();
                              },
                            ),
                          ],
                        ),
                      ),
                    Text(language.deliveryTimeSignature, style: boldTextStyle())
                        .visible(widget.orderData!.status == ORDER_DEPARTED ||
                            widget.orderData!.status == ORDER_DELIVERED),
                    8.height.visible(
                        widget.orderData!.status == ORDER_DEPARTED ||
                            widget.orderData!.status == ORDER_DELIVERED),
                    if (widget.orderData!.status == ORDER_DEPARTED)
                      Container(
                        height: 150,
                        width: context.width(),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            color: Colors.grey.withOpacity(0.15)),
                        child: Screenshot(
                          controller: deliveryScreenshotController,
                          child: SfSignaturePad(
                            key: signatureDeliveryPadKey,
                            minimumStrokeWidth: 1,
                            maximumStrokeWidth: 3,
                            strokeColor: ColorUtils.colorPrimary,
                          ),
                        ),
                      ).visible(widget.orderData!.status == ORDER_DEPARTED ||
                          widget.orderData!.status == ORDER_DELIVERED),
                    if (widget.orderData!.status == ORDER_DEPARTED)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            8.width,
                            TextButton(
                              child: Text(language.clear,
                                  style: boldTextStyle(
                                      color: ColorUtils.colorPrimary,
                                      decoration: TextDecoration.underline)),
                              onPressed: () async {
                                signatureDeliveryPadKey.currentState!.clear();
                              },
                            ),
                          ],
                        ),
                      ).visible(widget.orderData!.status == ORDER_DEPARTED ||
                          widget.orderData!.status == ORDER_DELIVERED),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: mIsCheck,
                      activeColor: ColorUtils.colorPrimary,
                      checkColor: Colors.white,
                      title: Text(
                          widget.orderData!.paymentCollectFrom ==
                                  PAYMENT_ON_DELIVERY
                              ? language.paymentCollectFrom
                              : language.isPaymentCollected,
                          style: primaryTextStyle()),
                      onChanged: (val) {
                        mIsCheck = val!;
                        setState(() {});
                      },
                    ).visible(widget.isShowPayment),
                    Text(language.proof, style: boldTextStyle()),
                    16.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        8.width,
                        Container(
                          decoration: boxDecorationDefault(
                              border:
                                  Border.all(color: ColorUtils.colorPrimary)),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.add,
                            color: ColorUtils.colorPrimary,
                            size: 24,
                          ),
                        ).onTap(() {
                          _pickImage(ImageSource.camera);
                        }),
                        if (_image != null && _image!.isNotEmpty)
                          Expanded(
                            child: Container(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _image!.length,
                                itemBuilder: (context, index) {
                                  return buildFileWidget(
                                    _image![index],
                                    index,
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        AppButton(
                          width: context.width(),
                          text: widget.orderData!.status == ORDER_DEPARTED
                              ? language.confirmDelivery
                              : language.confirmPickup,
                          textStyle: primaryTextStyle(color: white),
                          color: ColorUtils.colorPrimary,
                          onTap: () async {
                            if (!mIsCheck &&
                                widget.orderData!.paymentId == null &&
                                widget.isShowPayment) {
                              return toast(language.pleaseConfirmPayment);
                            } else {
                              if (appStore.isOtpVerifyOnPickupDelivery ==
                                  true) {
                                sendOtp(
                                  context,
                                  phoneNumber:
                                      widget.orderData!.status == ORDER_DEPARTED
                                          ? widget.orderData!.deliveryPoint!
                                              .contactNumber
                                              .validate()
                                          : widget.orderData!.pickupPoint!
                                              .contactNumber
                                              .validate(),
                                  onUpdate: (verificationId) async {
                                    await showInDialog(context,
                                        builder: (context) => OTPDialog(
                                            phoneNumber:
                                                widget.orderData!.status ==
                                                        ORDER_DEPARTED
                                                    ? widget
                                                        .orderData!
                                                        .deliveryPoint!
                                                        .contactNumber
                                                        .validate()
                                                    : widget
                                                        .orderData!
                                                        .pickupPoint!
                                                        .contactNumber
                                                        .validate(),
                                            onUpdate: () async {
                                              if (_image!.isNotEmpty &&
                                                  _image != null) {
                                                await saveProofData();
                                              }
                                              saveOrderData();
                                            },
                                            verificationId: verificationId),
                                        barrierDismissible: false);
                                  },
                                );
                              } else {
                                if (_image!.isNotEmpty && _image != null) {
                                  await saveProofData();
                                }
                                saveOrderData();
                              }
                            }
                          },
                        ).expand(),
                        if (widget.orderData!.status == ORDER_ACCEPTED &&
                            widget.orderData!.status == ORDER_ARRIVED)
                          16.width,
                        if (widget.orderData!.status == ORDER_ACCEPTED &&
                            widget.orderData!.status == ORDER_ARRIVED)
                          AppButton(
                            width: context.width(),
                            text: language.cancelOrder,
                            textStyle: primaryTextStyle(color: white),
                            elevation: 0,
                            color: Colors.red,
                            onTap: () async {
                              showInDialog(
                                context,
                                barrierDismissible: false,
                                contentPadding: EdgeInsets.all(16),
                                // ------这里还需要修改，因为把id的int改成了string------
                                // builder: (p0) {
                                //   return CancelOrderDialog(
                                //     orderId: widget.orderData!.id.validate(),
                                //     onUpdate: () {
                                //       finish(context);
                                //     },
                                //   );
                                // },
                              );
                            },
                          ).expand(),
                      ],
                    ),
                  ],
                ),
              ),
              Observer(
                builder: (_) => loaderWidget().visible(appStore.isLoading),
              )
            ],
          ),
        );
      }),
    );
  }

  saveProofData() async {
    MultipartRequest multiPartRequest =
        await getMultiPartRequest('profOfpicture-save');
    multiPartRequest.fields['order_id'] = widget.orderData!.id.toString();
    multiPartRequest.fields['type'] = widget.orderData!.status == ORDER_DEPARTED
        ? ORDER_DELIVERY_TIME
        : ORDER_PICK_UP_TIME;
    if (_image != null && _image!.length > 0) {
      for (var element in _image!) {
        multiPartRequest.files
            .add(await MultipartFile.fromPath("prof_file[]", element.path!));
      }
      ;
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());
    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        if (data != null) {
          appStore.setLoading(false);
          toast(data["message"]);
          finish(context);
          print(data.toString());
        }
      },
      onError: (error) {
        log("MULTIPART ERROR:::::::: ${error}");
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e, s) {
      log("MULTIPART ERROR:::::::: ${e}, STACKTRACE:::::: ${s}");
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> saveOrderData() async {
    if (widget.orderData!.status == ORDER_DEPARTED) {
      if (deliveryDateController.text.isEmpty) {
        return toast(language.selectDeliveryTimeMsg);
      }
    }

    if (widget.orderData!.status == ORDER_ACCEPTED ||
        widget.orderData!.status == ORDER_ARRIVED) {
      if (imageSignature == null) {
        imageSignature = await saveSignature(pickupScreenshotController);
        log(imageSignature!.path);
      }
    }
    if (widget.orderData!.status == ORDER_DEPARTED) {
      if (deliverySignature == null) {
        deliverySignature = await saveSignature(deliveryScreenshotController);
        log(deliverySignature!.path);
      }
    }

    if (widget.orderData!.paymentId == null &&
        widget.orderData!.paymentCollectFrom == PAYMENT_ON_PICKUP &&
        (widget.orderData!.status == ORDER_ACCEPTED ||
            widget.orderData!.status == ORDER_ARRIVED)) {
      appStore.setLoading(true);
      await paymentConfirmDialog(widget.orderData!);
      appStore.setLoading(false);
    } else if (widget.orderData!.paymentId == null &&
        widget.orderData!.paymentCollectFrom == PAYMENT_ON_DELIVERY &&
        widget.orderData!.status == ORDER_DEPARTED) {
      appStore.setLoading(true);
      await paymentConfirmDialog(widget.orderData!);
      appStore.setLoading(false);
    } else {
      showConfirmDialogCustom(
        context,
        primaryColor: ColorUtils.colorPrimary,
        dialogType: DialogType.CONFIRMATION,
        title: orderTitle(widget.orderData!.status!),
        positiveText: language.yes,
        negativeText: language.no,
        onAccept: (c) async {
          saveDelivery();
        },
      );
    }
  }

  Future<void> paymentConfirmDialog(OrderData orderData) {
    return showConfirmDialogCustom(context,
        primaryColor: ColorUtils.colorPrimary,
        dialogType: DialogType.CONFIRMATION,
        title: orderTitle(orderData.status!),
        positiveText: language.yes,
        negativeText: language.cancel, onAccept: (c) async {
      appStore.setLoading(true);
      Map req = {
        'order_id': orderData.id,
        'client_id': orderData.clientId,
        'datetime': picUpController.text,
        'total_amount': orderData.totalAmount,
        'payment_type': PAYMENT_TYPE_CASH,
        'payment_status': PAYMENT_PAID,
      };
      await savePayment(req).then((value) async {
        await saveDelivery().then((value) async {
          appStore.setLoading(false);
          // finish(context, true);
        }).catchError((error) {
          appStore.setLoading(false);
          log(error);
        });
      }).catchError((error) {
        appStore.setLoading(false);
        log(error);
      });
    }, onCancel: (v) {
      finish(context, false);
    });
  }

  Widget buildFileWidget(
    File file,
    int index,
  ) {
    return Stack(
      children: [
        Container(
                width: 100,
                height: 100,
                decoration: boxDecorationWithRoundedCorners(
                    border: Border.all(color: ColorUtils.colorPrimary),
                    backgroundColor: Color(0xff1A1A1A)),
                child: Image.file(
                  width: 100, height: 100,
                  File(file.path), // File object for local image display
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRect(10))
            .paddingOnly(left: 4),
        Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 20,
              height: 20,
              color: ColorUtils.borderColor,
              child: Icon(
                size: 16,
                Icons.delete_forever,
                color: Colors.red,
              ).center(),
            ).onTap(() {
              _removeImage(index);
              setState(() {});
            }).cornerRadiusWithClipRRect(40))
      ],
    );
  }
}

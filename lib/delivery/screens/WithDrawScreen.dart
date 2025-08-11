import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/WithDrawListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';

class WithDrawScreen extends StatefulWidget {
  final Function() onTap;

  WithDrawScreen({required this.onTap});

  @override
  WithDrawScreenState createState() => WithDrawScreenState();
}

class WithDrawScreenState extends State<WithDrawScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();
  TextEditingController addMoneyController = TextEditingController();

  int currentPage = 1;
  int totalPage = 1;

  List<WithDrawModel> withDrawData = [];

  num totalAmount = 0;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    await getWithDrawList(page: currentPage).then((value) {
      appStore.setLoading(false);
      print("value" + value.toJson().toString());
      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      totalAmount = value.walletBalance!.totalAmount!;
      if (currentPage == 1) {
        withDrawData.clear();
      }
      withDrawData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> withDrawRequest({int? userId, double? amount}) async {
    appStore.setLoading(true);
    Map req = {
      "user_id": appStore.uid,
      "currency": appStore.currencyCode.toLowerCase(),
      "amount": amount,
      "status": REQUESTED,
    };
    await saveWithDrawRequest(req).then((value) {
      toast(value.message);
      Navigator.pop(context);
      widget.onTap.call();
      appStore.setLoading(false);
      init();
    }).catchError((error) {
      Navigator.pop(context);
      toast(error.toString());
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  String printStatus(String status) {
    String text = "";
    if (status == DECLINE) {
      text = language.declined;
    } else if (status == REQUESTED) {
      text = language.requested;
    } else if (status == APPROVED) {
      text = language.approved;
    }
    return text;
  }

  Color withdrawStatusColor(String status) {
    Color color = ColorUtils.colorPrimary;
    if (status == DECLINE) {
      color = Colors.red;
    } else if (status == REQUESTED) {
      color = ColorUtils.colorPrimary;
    } else if (status == APPROVED) {
      color = Colors.green;
    }
    return color;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(language.withdraw, style: boldTextStyle(color: Colors.white)),
      // ),
      appBar: commonAppBarWidget(
        language.withdraw,
      ),

      body: Observer(builder: (context) {
        return Form(
          key: formKey,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: ColorUtils.colorPrimary, borderRadius: BorderRadius.circular(defaultRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(language.availableBalance, style: secondaryTextStyle(color: Colors.white)),
                          SizedBox(height: 8),
                          Text('${printAmount(totalAmount)}', style: boldTextStyle(size: 22, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(language.withdrawHistory, style: boldTextStyle(size: 18)),
                  SizedBox(height: 16),
                  ListView.builder(
                    physics: const ScrollPhysics(),
                    itemCount: withDrawData.length,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      WithDrawModel data = withDrawData[index];

                      return Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(printStatus(data.status!),
                                      style: boldTextStyle(color: withdrawStatusColor(data.status!))),
                                  SizedBox(height: 8),
                                  Text(printDate(data.createdAt!), style: secondaryTextStyle()),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text('${printAmount(data.amount!.toDouble())}', style: primaryTextStyle()),
                                4.height,
                                Container(
                                        decoration: boxDecorationDefault(
                                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                            color: Colors.transparent),
                                        child: Text(language.details, style: boldTextStyle(size: 12))
                                            .paddingAll(6)
                                            .center())
                                    .onTap(() {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        insetPadding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(language.withdrawDetails, style: boldTextStyle(size: 18)),
                                                Icon(Icons.close, size: 20).onTap(() {
                                                  finish(context);
                                                })
                                              ],
                                            ),
                                            Divider(color: context.dividerColor),
                                            8.height,
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(language.transactionId, style: secondaryTextStyle()),
                                                    Text(data.withdrawDetails!.transactionId.toString(),
                                                        style: primaryTextStyle()),
                                                  ],
                                                ).visible(!data.withdrawDetails!.transactionId.isEmptyOrNull),
                                              ],
                                            ),
                                            8.height,
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(language.via, style: secondaryTextStyle()),
                                                    Text(data.withdrawDetails!.via.toString(),
                                                        style: primaryTextStyle()),
                                                  ],
                                                ).visible(!data.withdrawDetails!.transactionId.isEmptyOrNull),
                                              ],
                                            ),
                                            8.height,
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(language.createdDate, style: secondaryTextStyle()),
                                                    Text(
                                                        DateFormat('yyyy-MM-dd').format(
                                                            DateTime.parse(data.withdrawDetails!.createdAt.toString())),
                                                        style: primaryTextStyle()),
                                                  ],
                                                ).visible(!data.withdrawDetails!.transactionId.isEmptyOrNull),
                                              ],
                                            ),
                                            8.height,
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(language.otherDetails, style: secondaryTextStyle()),
                                                    Text(data.withdrawDetails!.otherDetail.toString()),
                                                  ],
                                                ).visible(!data.withdrawDetails!.transactionId.isEmptyOrNull),
                                              ],
                                            ),
                                            8.height,
                                            if (!data.withdrawDetails!.withdrawDetailImage.isEmptyOrNull)
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(language.image, style: secondaryTextStyle()),
                                                      Container(
                                                          width: 100,
                                                          height: 100,
                                                          child: Image.network(
                                                              data.withdrawDetails!.withdrawDetailImage.validate(),
                                                              height: 60,
                                                              width: 60,
                                                              fit: BoxFit.cover,
                                                              alignment: Alignment.center))
                                                    ],
                                                  ).visible(!data.withdrawDetails!.transactionId.isEmptyOrNull),
                                                ],
                                              ),
                                          ],
                                        ).paddingAll(16),
                                      );
                                    },
                                  );
                                }).visible(data.withdrawDetails != null),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ).expand()
                ],
              ).paddingAll(16),
              Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              ),
              !appStore.isLoading && withDrawData.isEmpty ? emptyWidget() : SizedBox(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Visibility(
        visible: totalAmount > 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: commonButton(
            "${language.create} ${language.withdraw.toLowerCase()} ${language.request.toLowerCase()}",
            () {
              addMoneyController.clear();
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                      insetPadding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(language.withdrawMoney, style: boldTextStyle(size: 18)),
                          Divider(color: context.dividerColor),
                          16.height,
                          Text(language.amount, style: primaryTextStyle()),
                          8.height,
                          TextFormField(
                            controller: addMoneyController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            onChanged: (a) {
                              if (addMoneyController.text.toInt() >= totalAmount.toInt()) {
                                if (a.toInt() > totalAmount) {
                                  addMoneyController.text = double.parse(totalAmount.toString()).toStringAsFixed(2);
                                }
                              } else {
                                if (a.toInt() >= totalAmount) {
                                  addMoneyController.text = double.parse(totalAmount.toString()).toStringAsFixed(2);
                                }
                              }
                            },
                            decoration: commonInputDecoration(),
                          ),
                          16.height,
                          commonButton(
                            language.withdraw,
                            () async {
                              if (addMoneyController.text.isNotEmpty) {
                                await withDrawRequest(amount: double.parse(addMoneyController.text));
                              } else {
                                toast(language.addAmount);
                              }
                            },
                            width: context.width(),
                          ),
                          16.height,
                        ],
                      ).paddingAll(16));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

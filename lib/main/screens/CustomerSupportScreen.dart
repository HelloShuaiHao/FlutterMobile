import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/Chat/ChatWithAdminScreen.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/CustomerSupportModel.dart';
import '../../main/screens/AddSupportTicketScreen.dart';

import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';
import 'customer_support_detials_screen.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  List<CustomerSupport> supportList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();
    print("当前进入 customer_support_screen.dart 页面");
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          appStore.setLoading(true);
          init();
        }
      }
    });
  }

  void init() {
    getCustomerSupportListApi();
  }

  Future<void> getCustomerSupportListApi() async {
    appStore.setLoading(true);
    await getCustomerSupportList(page: page).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      if (page == 1) {
        supportList.clear();
      }
      supportList.addAll(value.customerSupport!);
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  getStatus(String status) {
    if (status == STATUS_PENDING) {
      return Text(status, style: boldTextStyle(color: pendingColor));
    } else if (status == STATUS_IN_REVIEW) {
      return Text(status, style: boldTextStyle(color: in_progressColor));
    } else {
      return Text(status, style: boldTextStyle(color: completedColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.customerSupport,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            supportList.isNotEmpty
                ? ListView.builder(
                    itemCount: supportList.length,
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemBuilder: (context, index) {
                      CustomerSupport item = supportList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(
                                color: appStore.isDarkMode
                                    ? Colors.grey.withOpacity(0.3)
                                    : ColorUtils.colorPrimary.withOpacity(0.4)),
                            backgroundColor: Colors.transparent),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("${language.supportId} :", style: boldTextStyle()),
                                        Text(item.supportId.validate().toString(), style: boldTextStyle()),
                                      ],
                                    ),
                                    getStatus(item.status.validate())
                                    //    Text(item.status.validate(), style: boldTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text('${language.supportType} : ', style: primaryTextStyle()),
                                    Text(item.supportType.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text('${language.message} : ', style: primaryTextStyle()),
                                    Text(item.message.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                                8.height,
                                if (item.video != null || item.image != null)
                                  Row(
                                    children: [
                                      Text('${language.attachment} : ', style: primaryTextStyle()),
                                      10.width,
                                      Text((item.video.isEmptyOrNull) ? language.viewPhoto : language.viewVideo)
                                          .onTap(() {
                                        CustomerSupportDetailsScreen(item.video.toString(), item.image.toString())
                                            .launch(context);
                                      }),
                                    ],
                                  ),
                                if (item.resolutionDetail != null) 8.height,
                                if (item.resolutionDetail != null)
                                  Row(
                                    children: [
                                      Text('${language.resolutionDetails} :', style: primaryTextStyle()),
                                      10.width,
                                      Text(item.resolutionDetail.validate(), style: primaryTextStyle()),
                                    ],
                                  ),
                              ],
                            ).expand(),
                          ],
                        ),
                      ).onTap(() {
                        ChatWithAdminScreen(item.supportChatHistory, item.supportId).launch(context);
                      });
                    },
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorUtils.colorPrimary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          AddSupportTicketScreen().launch(context).then((value) {
            init();
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Widgets.dart';

import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/UserProfileDetailModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';

class EarningHistoryScreen extends StatefulWidget {
  @override
  EarningHistoryScreenState createState() => EarningHistoryScreenState();
}

class EarningHistoryScreenState extends State<EarningHistoryScreen> {
  ScrollController scrollController = ScrollController();
  List<EarningData> earningList = [];
  EarningDetail earningDetail = EarningDetail();

  int currentPage = 1;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  getUserDetailApiCall() async {
    appStore.setLoading(true);
    await getUserProfile().then((value) {
      appStore.setLoading(false);
      earningList = value.earningList!.data ?? [];
      earningDetail = value.earningDetail ?? EarningDetail();
      setState(() {});
    }).catchError((e) {
      log(e.toString());
      appStore.setLoading(false);
    });
  }

  void init() async {
    getUserDetailApiCall();
    getPaymentListApi();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          getPaymentListApi();
        }
      }
    });
  }

  getPaymentListApi() async {
    appStore.setLoading(true);
    await getPaymentList(page: currentPage).then((value) {
      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        earningList.clear();
      }
      earningList.addAll(value.data!);
      setState(() {});
    }).catchError((e) {
      log(e);
    }).whenComplete(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: PreferredSize(
        preferredSize: Size(context.width(), 130),
        child: commonAppBarWidget(
          language.earningHistory,
          bottom: PreferredSize(
            preferredSize: Size(context.width(), 80),
            child: Container(
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(defaultRadius),
                  backgroundColor: Colors.transparent,
                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(appStore.isDarkMode ? 0.6 : 0.08))),
              padding: EdgeInsets.all(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(language.earning,
                            style: primaryTextStyle(size: 16, color: Colors.white), textAlign: TextAlign.center),
                        6.height,
                        Text('${printAmount(earningDetail.deliveryManCommission ?? 0)}',
                            style: boldTextStyle(size: 20, color: Colors.white), textAlign: TextAlign.center),
                      ],
                    ).expand(),
                    VerticalDivider(color: Colors.white),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(language.adminCommission,
                            style: primaryTextStyle(size: 16, color: Colors.white), textAlign: TextAlign.center),
                        6.height,
                        Text('${printAmount(earningDetail.adminCommission ?? 0)}',
                            style: boldTextStyle(size: 20, color: Colors.white), textAlign: TextAlign.center),
                      ],
                    ).expand(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          AnimatedListView(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: earningList.length,
            shrinkWrap: true,
            emptyWidget: Stack(
              children: [
                loaderWidget().visible(appStore.isLoading),
                emptyWidget().visible(!appStore.isLoading),
              ],
            ),
            onPageScrollChange: () {
              // appStore.setLoading(true);
            },
            onNextPage: () {
              if (currentPage < totalPage) {
                appStore.setLoading(true);
                currentPage++;
                getPaymentListApi();
              }
            },
            itemBuilder: (_, index) {
              EarningData data = earningList[index];
              return earningCardWidget(data);
            },
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  Widget earningCardWidget(EarningData data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(8),
      decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(defaultRadius),
          backgroundColor: Colors.transparent,
          border: Border.all(color: ColorUtils.colorPrimary.withOpacity(appStore.isDarkMode ? 0.6 : 0.08))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${language.orderId}: #${data.orderId}', style: boldTextStyle()),
              Spacer(),
              Text('${data.paymentType}', style: primaryTextStyle())
            ],
          ),
          SizedBox(height: 4),
          Text(printDate(data.createdAt.validate()), style: secondaryTextStyle()),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.earning, textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
              Text('${printAmount(data.deliveryManCommission ?? 0)}', style: boldTextStyle(size: 16)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.adminCommission, textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
              Text('${printAmount(data.adminCommission ?? 0)}', style: boldTextStyle(size: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/NotificationModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../user/screens/OrderDetailScreen.dart';
import '../components/CommonScaffoldComponent.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class NotificationScreen extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  bool mIsLastPage = false;
  List<NotificationData> notificationData = [];

  @override
  void initState() {
    super.initState();
    print("当前进入 notification_screen.dart 页面");
    init();
    appStore.setLoading(true);
  }

  void init({Map? request}) async {
    getNotification(page: currentPage, request: request).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());
      mIsLastPage = value.notificationData!.length < currentPage;
      if (currentPage == 1) {
        notificationData.clear();
      }
      notificationData.addAll(value.notificationData!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.notifications,
      action: [
        TextButton(
          onPressed: () {
            Map req = {
              "type": "markas_read",
            };
            appStore.setLoading(true);
            init(request: req);
          },
          child: Text(language.markAllRead, style: secondaryTextStyle(color: Colors.white)),
        ).visible(appStore.allUnreadCount > 0).paddingRight(8)
      ],
      body: Observer(builder: (context) {
        return Stack(
          children: [
            AnimatedListView(
              padding: EdgeInsets.all(16),
              emptyWidget: Stack(
                children: [
                  loaderWidget().visible(appStore.isLoading),
                  emptyWidget().visible(!appStore.isLoading),
                ],
              ),
              onPageScrollChange: () {
                //  appStore.setLoading(true);
              },
              onNextPage: () {
                if (!mIsLastPage) {
                  appStore.setLoading(true);
                  currentPage++;
                  setState(() {});
                  init();
                }
              },
              itemCount: notificationData.length,
              itemBuilder: (_, index) {
                NotificationData data = notificationData[index];
                return notificationCard(data);
              },
            ),
            loaderWidget().center().visible(appStore.isLoading)
          ],
        );
      }),
    );
  }

  Widget notificationCard(NotificationData data) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: boxDecorationWithRoundedCorners(
          borderRadius: BorderRadius.circular(defaultRadius),
          backgroundColor: ColorUtils.colorPrimary.withOpacity(0.08)),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorUtils.colorPrimary.withOpacity(0.15),
            ),
            child: Image.asset(statusTypeIcon(type: data.data!.type),
                fit: BoxFit.fill, color: ColorUtils.colorPrimary, width: 18, height: 18),
          ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.data!.subject}', style: secondaryTextStyle()).expand(),
                  8.width,
                  Text(timeAgo(data.createdAt.validate()), style: secondaryTextStyle()),
                ],
              ),
              6.height,
              Row(
                children: [
                  Text('${data.data!.message}', style: primaryTextStyle(size: 14)).expand(),
                  if (data.readAt.isEmptyOrNull) Icon(Entypo.dot_single, color: ColorUtils.colorPrimary),
                ],
              ),
            ],
          ).expand(),
        ],
      ).onTap(() async {
        bool? res = await OrderDetailScreen(orderId: data.data!.id.validate()).launch(context);
        if (res!) {
          currentPage = 1;
          init();
        }
      }),
    );
  }
}

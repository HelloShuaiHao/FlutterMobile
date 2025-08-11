import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';

import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/screens/CreateOrderScreen.dart';

class DraftOrderListScreen extends StatefulWidget {
  static String tag = '/DraftOrderListScreen';

  @override
  DraftOrderListScreenState createState() => DraftOrderListScreenState();
}

class DraftOrderListScreenState extends State<DraftOrderListScreen> {
  List<OrderData> orderList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    getOrderListApiCall();
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    await getOrderList(page: page, orderStatus: ORDER_DRAFT).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      isLastPage = false;
      if (page == 1) {
        orderList.clear();
      }
      orderList.addAll(value.data!);
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  deleteOrderApiCall(int id) async {
    appStore.setLoading(true);
    await deleteOrder(id).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      getOrderListApiCall();
      setState(() {});
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
      appBarTitle: language.draftOrder,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            orderList.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    children: orderList.map((item) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                            backgroundColor: Colors.transparent),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            item.date != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('dd MMM yyyy').format(DateTime.parse("${item.date!}Z").toLocal()),
                                          style: secondaryTextStyle()),
                                      Text(DateFormat('hh:mm a').format(DateTime.parse("${item.date!}Z").toLocal()),
                                          style: secondaryTextStyle()),
                                    ],
                                  )
                                : SizedBox(),
                            8.height,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                item.parcelType != null
                                    ? Row(
                                        children: [
                                          Container(
                                            decoration: boxDecorationWithRoundedCorners(
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: ColorUtils.borderColor,
                                                    width: appStore.isDarkMode ? 0.2 : 1),
                                                backgroundColor: context.cardColor),
                                            padding: EdgeInsets.all(8),
                                            child: Image.asset(parcelTypeIcon(item.parcelType.validate()),
                                                height: 24, width: 24, color: ColorUtils.colorPrimary),
                                          ),
                                          8.width,
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(item.parcelType.validate(), style: boldTextStyle()).expand(),
                                                  Text('${printAmount(item.totalAmount ?? 0)}',
                                                      style: primaryTextStyle()),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text('# ${item.id.validate()}', style: boldTextStyle()).expand(),
                                                  Icon(Ionicons.md_trash_outline, color: Colors.red).onTap(() {
                                                    showConfirmDialogCustom(
                                                      context,
                                                      dialogType: DialogType.DELETE,
                                                      positiveText: language.delete,
                                                      negativeText: language.cancel,
                                                      title: language.deleteDraft,
                                                      subTitle: language.sureWantToDeleteDraft,
                                                      onAccept: (p0) {
                                                        deleteOrderApiCall(item.id!.toInt());
                                                      },
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ).expand(),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          // item.date != null ? Text(printDate(item.date!), style: secondaryTextStyle()).expand() : SizedBox(),
                                          Text('${printAmount(item.totalAmount ?? 0)}', style: boldTextStyle()),
                                        ],
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ).onTap(() {
                        CreateOrderScreen(orderData: item).launch(context);
                      });
                    }).toList(),
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../user/components/OrderCardComponent.dart';
import '../models/OrderListModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Images.dart';
import '../utils/dynamic_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderData> orderList = [];
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    print("当前进入 order_history_screen.dart 页面");
    getOrdersHistoryListApi();
  }

  getOrdersHistoryListApi() async {
    await getUserOrderHistoryList(page: page).then((value) {
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      isLastPage = false;
      if (page == 1) orderList.clear();
      orderList.addAll(value.data!);
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      toast(e.toString(), print: true);
    }).whenComplete(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.completedOrders,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            appStore.isLoading
                ? loaderWidget()
                : orderList.length > 0
                    ? ListView.builder(
                        itemCount: orderList.length,
                        itemBuilder: (context, index) {
                          return OrderHistoryItem(orderData: orderList[index]).paddingAll(10);
                        })
                    : emptyWidget()
          ],
        );
      }),
    );
  }
}

class OrderHistoryItem extends StatelessWidget {
  OrderData orderData;
  OrderHistoryItem({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.width(),
        margin: EdgeInsets.only(bottom: 16),
        decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
            backgroundColor: Colors.transparent),
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (orderData.date != null)
            Row(
              children: [
                Text(
                        DateFormat('dd MMM yyyy').format(DateTime.parse("${orderData.date!}")) +
                            " ${language.at.toLowerCase()} " +
                            DateFormat('hh:mm a').format(DateTime.parse("${orderData.date!}")),
                        style: primaryTextStyle(size: 14))
                    .expand(),
                if (orderData.status != ORDER_CANCELLED)
                  Text(printAmount(orderData.totalAmount ?? 0), style: boldTextStyle()),
              ],
            ),
          8.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorUtils.borderColor, width: appStore.isDarkMode ? 0.2 : 1),
                    backgroundColor: context.cardColor),
                padding: EdgeInsets.all(8),
                child: Image.asset(parcelTypeIcon(orderData.parcelType.validate()),
                    height: 24, width: 24, color: ColorUtils.colorPrimary),
              ),
              8.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderData.parcelType.validate(),
                      style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                  4.height,
                  Row(
                    children: [
                      Text('# ${orderData.id}', style: boldTextStyle(size: 14)).expand(),
                    ],
                  ),
                ],
              ).expand(),
            ],
          ),
          8.height,
          if (orderData.pickupDatetime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.picked, style: secondaryTextStyle(size: 12)),
                4.height,
                Text('${language.at} ${printDateWithoutAt("${orderData.pickupDatetime!}Z")}',
                    style: secondaryTextStyle(size: 12)),
              ],
            ),
          Row(
            children: [
              ImageIcon(AssetImage(ic_from), size: 24, color: ColorUtils.colorPrimary),
              12.width,
              Text('${orderData.pickupPoint!.address}', style: primaryTextStyle()).expand(),
            ],
          ),
          8.height,
          if (orderData.deliveryDatetime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.delivered, style: secondaryTextStyle(size: 12)),
                4.height,
                Text('${language.at} ${printDateWithoutAt("${orderData.deliveryDatetime!}Z")}',
                    style: secondaryTextStyle(size: 12)),
              ],
            ),
          Row(
            children: [
              ImageIcon(AssetImage(ic_to), size: 24, color: ColorUtils.colorPrimary),
              12.width,
              Text('${orderData.deliveryPoint!.address}', style: primaryTextStyle(), textAlign: TextAlign.start)
                  .expand(),
            ],
          ),
          8.height,
          if (orderData.status == ORDER_DELIVERED)
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: boxDecorationWithRoundedCorners(backgroundColor: ColorUtils.colorPrimary),
                  child: Row(
                    children: [
                      Text(language.invoice, style: secondaryTextStyle(color: Colors.white)),
                      4.width,
                      Icon(Ionicons.md_download_outline, color: Colors.white, size: 18).paddingBottom(4),
                    ],
                  ).onTap(() {
                    // generateInvoiceCall(widget.item);
                    print("invice ${orderData.invoice}");
                    PDFViewer(
                      invoice: "${orderData.invoice.validate()}",
                      filename: "${orderData.id.validate()}",
                    ).launch(context);
                  }),
                ),
              ],
            ),
        ]));
  }
}

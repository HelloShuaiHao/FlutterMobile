import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:internet_file/internet_file.dart';
import 'package:intl/intl.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/OrderListModel.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pdfx/pdfx.dart' as pdf;

import '../../extensions/app_button.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';
import '../screens/OrderDetailScreen.dart';
import '../screens/OrderTrackingScreen.dart';
import 'package:http/http.dart' as http;

class OrderCardComponent extends StatefulWidget {
  final OrderData item;

  OrderCardComponent({required this.item});

  @override
  _OrderCardComponentState createState() => _OrderCardComponentState();
}

class _OrderCardComponentState extends State<OrderCardComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // -----这里还需要修改，因为把id的int改成了string-----
        // OrderDetailScreen(orderId: widget.item.id.validate())
        //     .launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
            backgroundColor: Colors.transparent),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.item.date != null
                    ? Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse("${widget.item.date!}")) +
                                " ${language.at.toLowerCase()} " +
                                DateFormat('hh:mm a').format(DateTime.parse("${widget.item.date!}")),
                            style: primaryTextStyle(size: 14))
                        .expand()
                    : SizedBox(),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor(widget.item.status.validate()).withOpacity(0.08))),
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  child: Icon(Icons.navigation_outlined, color: ColorUtils.colorPrimary).center(),
                ).paddingRight(10).onTap(() {
                  openMap(
                      double.parse(widget.item.pickupPoint!.latitude.validate()),
                      double.parse(widget.item.pickupPoint!.longitude.validate()),
                      double.parse(widget.item.deliveryPoint!.latitude.validate()),
                      double.parse(widget.item.deliveryPoint!.longitude.validate()));
                }).visible(widget.item.status != ORDER_DELIVERED),
                Container(
                  decoration: BoxDecoration(
                      color: statusColor(widget.item.status.validate()).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6)),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Text(orderStatus(widget.item.status!),
                          style: primaryTextStyle(size: 14, color: statusColor(widget.item.status.validate()))),
                    ],
                  ),
                ),
              ],
            ),
            Text('${widget.item.orderTrackingId}', style: boldTextStyle(size: 12, color: ColorUtils.colorPrimary)),
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
                  child: Image.asset(parcelTypeIcon(widget.item.parcelType.validate()),
                      height: 24, width: 24, color: ColorUtils.colorPrimary),
                ),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.parcelType.validate(),
                        style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    4.height,
                    Row(
                      children: [
                        Text('# ${widget.item.id}', style: boldTextStyle(size: 14)).expand(),
                        if (widget.item.status != ORDER_CANCELLED)
                          Text(printAmount(widget.item.totalAmount ?? 0), style: boldTextStyle()),
                      ],
                    ),
                  ],
                ).expand(),
              ],
            ),
            8.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.item.pickupDatetime != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.picked, style: secondaryTextStyle(size: 12)),
                              4.height,
                              Text('${language.at} ${printDateWithoutAt("${widget.item.pickupDatetime!}Z")}',
                                  style: secondaryTextStyle(size: 12)),
                            ],
                          ),
                        4.height,
                        GestureDetector(
                          onTap: () {
                            // --------这里还需要修改，因为把id的int改成了string--------
                            // OrderDetailScreen(orderId: widget.item.id.validate()).launch(context,
                            //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
                          
                          },
                          child: Row(
                            children: [
                              ImageIcon(AssetImage(ic_from), size: 24, color: ColorUtils.colorPrimary),
                              12.width,
                              Text('${widget.item.pickupPoint!.address}', style: primaryTextStyle()).expand(),
                            ],
                          ),
                        ),
                        if (widget.item.pickupDatetime == null &&
                            widget.item.pickupPoint!.endTime != null &&
                            widget.item.pickupPoint!.startTime != null)
                          Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.item.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.pickupPoint!.endTime!).toLocal())}',
                                  style: secondaryTextStyle(size: 12, color: Colors.red))
                              .paddingOnly(top: 4)
                              .paddingOnly(top: 4),
                      ],
                    ).expand(),
                    12.width,
                    if (widget.item.pickupPoint!.contactNumber != null)
                      Icon(Ionicons.ios_call_outline, size: 20, color: ColorUtils.colorPrimary).onTap(() {
                        commonLaunchUrl('tel:${widget.item.pickupPoint!.contactNumber}');
                      }),
                  ],
                ),
              ],
            ),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.item.deliveryDatetime != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.delivered, style: secondaryTextStyle(size: 12)),
                                  4.height,
                                  Text('${language.at} ${printDateWithoutAt("${widget.item.deliveryDatetime!}Z")}',
                                      style: secondaryTextStyle(size: 12)),
                                ],
                              ),
                            4.height,
                            GestureDetector(
                              onTap: () {
                                // -------这里还需要修改，因为把id的int改成了string
                                // OrderDetailScreen(orderId: widget.item.id.validate()).launch(context,
                                //     pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 400.milliseconds);
                              },
                              child: Row(
                                children: [
                                  ImageIcon(AssetImage(ic_to), size: 24, color: ColorUtils.colorPrimary),
                                  12.width,
                                  Text('${widget.item.deliveryPoint!.address}',
                                          style: primaryTextStyle(), textAlign: TextAlign.start)
                                      .expand(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (widget.item.deliveryDatetime == null &&
                            widget.item.deliveryPoint!.endTime != null &&
                            widget.item.deliveryPoint!.startTime != null)
                          Text('${language.note} ${language.courierWillDeliverAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.item.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(widget.item.deliveryPoint!.endTime!).toLocal())}',
                                  style: secondaryTextStyle(color: Colors.red, size: 12))
                              .paddingOnly(top: 4)
                      ],
                    ).expand(),
                    12.width,
                    if (widget.item.deliveryPoint!.contactNumber != null)
                      Icon(Ionicons.ios_call_outline, size: 20, color: ColorUtils.colorPrimary).onTap(() {
                        commonLaunchUrl('tel:${widget.item.deliveryPoint!.contactNumber}');
                      }),
                  ],
                ),
                //TODO KRUTI
                if (widget.item.reScheduleDateTime != null)
                  Text('${language.note} ${language.rescheduleMsg} ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(widget.item.reScheduleDateTime!))} ',
                          style: secondaryTextStyle(color: Colors.red, size: 12))
                      .paddingOnly(top: 4)
              ],
            ),
            if (widget.item.status != ORDER_CANCELLED ||
                (widget.item.status == ORDER_DEPARTED || widget.item.status == ORDER_ACCEPTED))
              16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.item.status == ORDER_DELIVERED)
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
                      print("invice ${widget.item.invoice}");
                      PDFViewer(
                        invoice: "${widget.item.invoice.validate()}",
                        filename: "${widget.item.id.validate()}",
                      ).launch(context);
                    }),
                  ),
                AppButton(
                  elevation: 0,
                  height: 35,
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    side: BorderSide(color: ColorUtils.colorPrimary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(language.trackOrder, style: primaryTextStyle(color: ColorUtils.colorPrimary)),
                      Icon(Icons.arrow_right, color: ColorUtils.colorPrimary),
                    ],
                  ),
                  onTap: () {
                    OrderTrackingScreen(orderData: widget.item).launch(context);
                  },
                ).visible((widget.item.status == ORDER_DEPARTED) && appStore.userType != DELIVERY_MAN),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewer extends StatefulWidget {
  final String invoice;
  final String? filename;

  PDFViewer({required this.invoice, this.filename = ""});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  PdfController? pdfController;

  @override
  void initState() {
    super.initState();
    viewPDF();
  }

  Future<void> viewPDF() async {
    try {
      setState(() {
        appStore.setLoading(true);
        print("invoice ==> ${widget.invoice}");
        pdfController = PdfController(document: pdf.PdfDocument.openData(InternetFile.get("${widget.invoice}")));
        appStore.setLoading(false);
      });
    } catch (e) {
      print('Error viewing PDF: $e');
    }
  }

  Future<void> downloadPDF() async {
    appStore.setLoading(true);
    final response = await http.get(Uri.parse(widget.invoice));
    if (response.statusCode == 200) {
      print("success ${response.bodyBytes}");
      final bytes = response.bodyBytes;
      // final directory = await getApplicationDocumentsDirectory();
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      String fileName = widget.filename.validate().isEmpty ? "invoice" : widget.filename.validate();
      File file = File('${path}/${fileName}.pdf');
      print("file ${file.path}");
      await file.writeAsBytes(bytes, flush: true);
      appStore.setLoading(false);
      toast("invoice downloaded at ${file.path}");
      final url = 'content://${file.path}';
      final filef = File(file.path);
      if (await filef.exists()) {
        OpenFile.open(file.path);
      } else {
        throw 'File does not exist';
      }
      /* if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }*/
    } else {
      appStore.setLoading(false);
      toast("Failed to download pdf");
      throw Exception('Failed to download PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
        appBar: commonAppBarWidget(language.invoice, actions: [
          Icon(Icons.download, color: Colors.white).withWidth(60).onTap(() {
            downloadPDF();
          }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent),
        ]),
        body: Stack(
          children: [
            PdfView(
              controller: pdfController!,
            ),
            PdfPageNumber(
              controller: pdfController!,
              builder: (_, loadingState, page, pagesCount) {
                if (page == 0) return loaderWidget();
                return SizedBox();
              },
            ),
            Observer(builder: (context) {
              return loaderWidget().visible(appStore.isLoading);
            }),
          ],
        ));
  }
}

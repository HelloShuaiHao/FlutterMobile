import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:internet_file/internet_file.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdf;
import 'package:http/http.dart' as hh;
import 'package:pdfx/pdfx.dart';
import '../../extensions/common.dart';
import '../../main.dart';
import '../utils/Common.dart';
import '../utils/Widgets.dart';

class DisplayAttachmentViewScreen extends StatefulWidget {
  bool? isPhoto;
  String? value;
  int? id;
  DisplayAttachmentViewScreen({this.isPhoto, this.value, this.id});

  @override
  State<DisplayAttachmentViewScreen> createState() => _DisplayAttachmentViewScreenState();
}

class _DisplayAttachmentViewScreenState extends State<DisplayAttachmentViewScreen> {
  Future<void> downloadPDF() async {
    appStore.setLoading(true);
    final response = await hh.get(Uri.parse(widget.value.validate()));
    if (response.statusCode == 200) {
      print("success ${response.bodyBytes}");
      final bytes = response.bodyBytes;
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      String fileName = widget.id.validate().toString().isNotEmpty ? widget.id.validate().toString() : "Attachment";
      File file = File('${path}/${fileName}.pdf');
      print("file ${file.path}");
      await file.writeAsBytes(bytes, flush: true);
      appStore.setLoading(false);
      toast("attachment downloaded at ${file.path}");
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: commonAppBarWidget(language.attachment, showBack: true, actions: [
        (!widget.isPhoto!)
            ? Icon(Icons.download, color: Colors.white).withWidth(60).onTap(() {
                downloadPDF();
              }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent)
            : SizedBox(),
      ]),
      body: (widget.isPhoto!)
          ? CachedNetworkImage(
              width: context.width(),
              height: context.height(),
              imageUrl: widget.value!,
              fit: BoxFit.cover,
            ).center().paddingAll(10).center()
          : PDFViewer(
              invoice: widget.value!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

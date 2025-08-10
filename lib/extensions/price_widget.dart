import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extensions/extension_util/int_extensions.dart';
import '../extensions/shared_pref.dart';
import '../extensions/text_styles.dart';
import '../main.dart';
import '../main/utils/Constants.dart';

class PriceWidget extends StatefulWidget {
  var price;
  final double? size;
  final Color? color;
  final TextStyle? textStyle;

  PriceWidget({this.price, this.color, this.size = 22.0, this.textStyle});

  @override
  PriceWidgetState createState() => PriceWidgetState();
}

class PriceWidgetState extends State<PriceWidget> {
  var currency = '₹';

  @override
  void initState() {
    super.initState();
    get();
  }

  get() async {
    setState(() {
      currency = getStringAsync(currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (appStore.currencyPosition == "left") {
      return Row(
        children: [
          currencyWidget(),
          2.width,
          Text(widget.price.toString(),
              style: widget.textStyle ??
                  primaryTextStyle(
                      color: widget.color ?? textPrimaryColorGlobal,
                      size: widget.size!.toInt())),
        ],
      );
    } else {
      return Row(
        children: [
          Text(widget.price.toString(),
              style: widget.textStyle ??
                  primaryTextStyle(
                      color: widget.color ?? textPrimaryColorGlobal,
                      size: widget.size!.toInt())),
          2.width,
          currencyWidget(),
        ],
      );
    }
  }

  Widget currencyWidget() {
    return Text(currency,
        style: GoogleFonts.roboto(
            color: widget.textStyle!.color ?? textPrimaryColorGlobal,
            fontWeight: widget.textStyle!.fontWeight,
            fontSize: widget.textStyle!.fontSize ?? 18));
  }
}

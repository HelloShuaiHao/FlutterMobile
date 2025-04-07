import 'package:flutter/material.dart';
import '../../extensions/decorations.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/text_styles.dart';
import '../../main/utils/Widgets.dart';
import '../../main.dart';
import '../../main/utils/DataProviders.dart';
import '../../main/utils/dynamic_theme.dart';

class PackagingSymbolsInfo extends StatefulWidget {
  PackagingSymbolsInfo({super.key});

  @override
  State<PackagingSymbolsInfo> createState() => _PackagingSymbolsInfoState();
}

class _PackagingSymbolsInfoState extends State<PackagingSymbolsInfo> {
  List<Map<String, String>> list = getPackagingSymbols();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBarWidget(language.labels),
      body: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: boxDecorationWithRoundedCorners(border: Border.all(color: ColorUtils.borderColor)),
                child: Row(
                  children: [
                    Image.asset(
                      list[index]['image']!,
                      width: 24,
                      height: 24,
                      color: appStore.isDarkMode ? Colors.white.withOpacity(0.7) : ColorUtils.colorPrimary,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list[index]['title'].toString(),
                          style: boldTextStyle(),
                        ),
                        4.height,
                        Text(
                          list[index]['description'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: secondaryTextStyle(),
                        ),
                      ],
                    ).paddingOnly(left: 8).expand(),
                  ],
                ));
          }).paddingAll(8),
    );
  }
}

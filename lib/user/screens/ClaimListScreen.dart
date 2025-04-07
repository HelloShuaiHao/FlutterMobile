import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/ClaimListResponseModel.dart';
import '../../user/screens/ClaimDetailsScreen.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';

class ClaimListScreen extends StatefulWidget {
  const ClaimListScreen({super.key});

  @override
  State<ClaimListScreen> createState() => _ClaimListScreenState();
}

class _ClaimListScreenState extends State<ClaimListScreen> {
  List<ClaimItem> claimList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;

  @override
  void initState() {
    super.initState();
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
    getClaimListApiCall();
  }

  Future<void> getClaimListApiCall() async {
    appStore.setLoading(true);
    await getClaimList(page).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!.validate(value: 1);
      page = value.pagination!.currentPage!.validate(value: 1);
      if (page == 1) {
        claimList.clear();
      }
      value.data!.forEach((element) {
        claimList.add(element);
      });

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      print("error ===> ${error.toString()}");
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.claimHistory,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            claimList.isNotEmpty
                ? ListView.builder(
                    itemCount: claimList.length,
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemBuilder: (context, index) {
                      ClaimItem item = claimList[index];
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
                                        Text("${language.id} :", style: boldTextStyle()),
                                        Text(item.id.validate().toString(), style: boldTextStyle()),
                                      ],
                                    ),
                                    getClaimStatus(item.status.validate())
                                  ],
                                ),
                                8.height,
                                Row(
                                  children: [
                                    Text('${language.trackinNo} :', style: primaryTextStyle()),
                                    Text(item.trakingNo.validate(), style: primaryTextStyle()),
                                  ],
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                      ).onTap(() {
                        ClaimDetailstDetailsScreen(item).launch(context);
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
    );
  }
}

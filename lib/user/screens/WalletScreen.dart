import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/LoginResponse.dart';
import '../../delivery/screens/WithDrawScreen.dart';
import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/WalletListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/BankDetailScreen.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../main/utils/dynamic_theme.dart';
import 'PaymentScreen.dart';

class WalletScreen extends StatefulWidget {
  static String tag = '/WalletScreen';

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  TextEditingController amountCont = TextEditingController();

  UserBankAccount? userBankAccount;

  List<WalletModel> walletData = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  int currentIndex = -1;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getBankDetail();
    getWalletData();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});
          getWalletData();
        }
      }
    });
  }

  getBankDetail() async {
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      userBankAccount = value.userBankAccount;
    }).then((value) {
      log(value);
    });
  }

  getWalletData() async {
    appStore.setLoading(true);
    await getWalletList(page: currentPage).then((value) {
      appStore.setLoading(false);

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (value.walletBalance != null) totalAmount = value.walletBalance!.totalAmount ?? 0;
      if (currentPage == 1) {
        walletData.clear();
      }
      walletData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        appStore.availableBal = totalAmount;
        finish(context, true);
        return Future.value(false);
      },
      child: CommonScaffoldComponent(
        appBar: PreferredSize(
          preferredSize: Size(context.width(), 130),
          child: commonAppBarWidget(
            language.walletHistory,
            bottom: PreferredSize(
              preferredSize: Size(context.width(), 80),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.availableBalance, style: secondaryTextStyle(size: 16, color: Colors.white)),
                        6.height,
                        Text('${printAmount(totalAmount)}', style: boldTextStyle(size: 24, color: Colors.white)),
                      ],
                    ),
                    commonButton(language.addMoney, () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            insetPadding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(language.addMoney, style: boldTextStyle(size: 18)),
                                Divider(color: context.dividerColor),
                                16.height,
                                Text(language.amount, style: primaryTextStyle()),
                                8.height,
                                AppTextField(
                                  controller: amountCont,
                                  textFieldType: TextFieldType.PHONE,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: commonInputDecoration(),
                                ),
                                16.height,
                                commonButton(
                                  language.add,
                                  () async {
                                    if (amountCont.text.isNotEmpty) {
                                      Navigator.pop(context);
                                      bool? res = await PaymentScreen(
                                        totalAmount: amountCont.text.toDouble(),
                                        isWallet: true,
                                      ).launch(context);
                                      if (res == true) {
                                        getWalletData();
                                      }
                                    } else {
                                      toast(language.addAmount);
                                    }
                                  },
                                  width: context.width(),
                                ),
                                16.height,
                              ],
                            ).paddingAll(16),
                          );
                        },
                      );
                    }, color: Colors.white38, textColor: Colors.white)
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            AnimatedListView(
              padding: EdgeInsets.all(16),
              itemCount: walletData.length,
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
                  getWalletData();
                }
              },
              shrinkWrap: true,
              itemBuilder: (_, index) {
                WalletModel data = walletData[index];
                return walletCard(data);
              },
            ),
            Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
        bottomNavigationBar: totalAmount != 0
            ? commonButton(
                language.withdrawHistory,
                () {
                  if (userBankAccount != null)
                    WithDrawScreen(
                      onTap: () {
                        init();
                      },
                    ).launch(context);
                  else {
                    toast(language.bankNotFound);
                    BankDetailScreen(isWallet: true).launch(context).then((value) {
                      init();
                    });
                  }
                },
              ).paddingSymmetric(horizontal: 16, vertical: 8)
            : SizedBox(),
      ),
    );
  }

  Widget walletCard(WalletModel data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(8),
      decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(defaultRadius),
          backgroundColor: Colors.transparent,
          border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.08))),
      child: Row(
        children: [
          Container(
            decoration: boxDecorationWithRoundedCorners(backgroundColor: ColorUtils.colorPrimary.withOpacity(0.08)),
            padding: EdgeInsets.all(6),
            child: Icon(data.type == CREDIT ? Icons.add : Icons.remove, color: ColorUtils.colorPrimary),
          ),
          10.width,
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transactionType(data.transactionType!), style: secondaryTextStyle(color: textPrimaryColorGlobal)),
                SizedBox(height: 8),
                Text(printDate(data.createdAt.validate()), style: secondaryTextStyle(size: 12)),
                SizedBox(height: 8),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Text('${data.type == CREDIT ? '+' : '-'} ${printAmount(data.amount)}',
                    style: boldTextStyle(color: data.type == CREDIT ? Colors.green : Colors.red)),
                6.height,
                Container(
                        decoration: boxDecorationDefault(
                            border: Border.all(color: Colors.grey.withOpacity(0.2)), color: Colors.transparent),
                        child: Text(language.copy, style: boldTextStyle(color: ColorUtils.colorPrimary, size: 14))
                            .paddingAll(6)
                            .center())
                    .onTap(() {
                  Clipboard.setData(ClipboardData(text: data.transactionType!.split(":")[1])).then((_) {
                    snackBar(context,
                        content: Text("${data.transactionType!.split(":")[1]}  ${language.copiedToClipboard}"));
                  });
                }).visible(data.transactionType!.contains("Transaction Id")),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/list_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/screens/CustomerSupportScreen.dart';
import '../../main/screens/RefferalHistoryScreen.dart';
import '../../main/screens/RewardListScreen.dart';
import '../../user/screens/ClaimListScreen.dart';
import '../../user/screens/PageDetailScreen.dart';
import '../../user/screens/refer_earn_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../extensions/animatedList/animated_configurations.dart';
import '../../extensions/animatedList/animated_scroll_view.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../extensions/widgets.dart';
import '../../main.dart';
import '../../main/components/theme_selection_dialog.dart';
import '../../main/models/PageListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/AboutUsScreen.dart';
import '../../main/screens/BankDetailScreen.dart';
import '../../main/screens/ChangePasswordScreen.dart';
import '../../main/screens/EditProfileScreen.dart';
import '../../main/screens/LanguageScreen.dart';
import '../../main/screens/order_history_list.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Images.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/screens/DraftOrderListScreen.dart';
import '../../user/screens/WalletScreen.dart';
import '../screens/DeleteAccountScreen.dart';
import '../screens/MyAddressListScreen.dart';

class AccountFragment extends StatefulWidget {
  static String tag = '/AccountFragment';

  @override
  AccountFragmentState createState() => AccountFragmentState();
}

class AccountFragmentState extends State<AccountFragment> {
  List<PageData> pageList = [];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget accountSettingItemWidget(String? img, String title, Function() onTap,
      {bool isLast = false, IconData? suffixIcon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            minLeadingWidth: 14,
            dense: true,
            leading:
                Image.asset(img.validate(), height: 18, fit: BoxFit.fill, width: 18, color: textPrimaryColorGlobal),
            title: Text(title, style: primaryTextStyle()),
            trailing: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.green)
                : Icon(Icons.navigate_next, color: appStore.isDarkMode ? Colors.white : Colors.grey),
            onTap: onTap),
        if (isLast) Divider(height: 0, color: context.dividerColor)
      ],
    );
  }

  Widget mTitle(String value) {
    return Text(value.toUpperCase(),
            style: boldTextStyle(size: 12, letterSpacing: 0.7, color: textSecondaryColorGlobal))
        .paddingOnly(left: 16, right: 16, top: 24, bottom: 4);
  }

  @override
  void initState() {
    super.initState();
    getPageListApi();
  }

  Future<void> getPageListApi() async {
    appStore.setLoading(true);
    await getPagesList().then((value) {
      appStore.setLoading(false);
      if (value.data.validate().isNotEmpty) {
        pageList.addAll(value.data!);
      }
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Stack(
        children: [
          AnimatedScrollView(
            fadeInConfiguration: FadeInConfiguration(duration: Duration(seconds: 1)),
            padding: EdgeInsets.only(bottom: context.height() * 0.1, top: 16),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  boxShape: BoxShape.circle,
                                  border: Border.all(width: 2, color: ColorUtils.colorPrimary)),
                              child: commonCachedNetworkImage(appStore.userProfile.validate(),
                                      height: 65, width: 65, fit: BoxFit.cover, alignment: Alignment.center)
                                  .cornerRadiusWithClipRRect(50)),
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                                boxShape: BoxShape.circle,
                                border: Border.all(width: 1, color: white),
                                backgroundColor: ColorUtils.colorPrimary),
                            padding: EdgeInsets.all(4),
                            child: Image.asset(ic_edit, color: white, height: 14, width: 14),
                          )
                        ],
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getStringAsync(NAME).validate(), style: boldTextStyle(size: 20)),
                          6.height,
                          Text(appStore.userEmail.validate(), style: secondaryTextStyle(size: 16)),
                        ],
                      )
                    ],
                  ).paddingSymmetric(horizontal: 16).onTap(() {
                    EditProfileScreen().launch(context);
                  }),
                  mTitle(language.ordersWalletMore),
                  accountSettingItemWidget(ic_draft, language.drafts, () {
                    DraftOrderListScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_wallet, language.wallet, () {
                    WalletScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_order, language.orderHistory, () {
                    OrderHistoryScreen().launch(context);
                  }).visible(appStore.userType == CLIENT),
                  accountSettingItemWidget(
                    ic_address,
                    language.lblMyAddresses,
                    () {
                      MyAddressListScreen().launch(context);
                    },
                    isLast: true,
                  ),
                  /*accountSettingItemWidget(ic_bank_detail, language.favouriteStore, () {
                    FavouriteStoreScreen().launch(context);
                  }, isLast: true),*/
                  mTitle(language.account),
                  accountSettingItemWidget(ic_change_password, language.changePassword, () {
                    ChangePasswordScreen().launch(context);
                  }).visible(getStringAsync(LOGIN_TYPE) != LoginTypeGoogle),
                  accountSettingItemWidget(ic_languages, language.language, () {
                    LanguageScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_dark_mode, language.theme, () async {
                    await showInDialog(context,
                        shape: RoundedRectangleBorder(borderRadius: radius()),
                        builder: (_) => ThemeSelectionDialog(),
                        contentPadding: EdgeInsets.zero);
                  }),
                  accountSettingItemWidget(
                    ic_bank_detail,
                    language.bankDetails,
                    () {
                      BankDetailScreen().launch(context);
                    },
                  ),
                  accountSettingItemWidget(ic_delete_account, language.deleteAccount, () async {
                    DeleteAccountScreen().launch(context);
                  }, isLast: true),
                  mTitle(language.other),
                  accountSettingItemWidget(ic_change_password, language.customerSupport, () {
                    CustomerSupportScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_earn, language.referAndEarn, () {
                    ReferEarnScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_refer_history, language.referralHistory, () {
                    ReferralHistoryScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_claim, language.claimHistory, () {
                    ClaimListScreen().launch(context);
                  }),
                  accountSettingItemWidget(ic_change_password, language.earnedRewards, () {
                    RewardListScreen().launch(context);
                  }, isLast: true),
                  mTitle(language.general),
                  accountSettingItemWidget(ic_document, language.privacyPolicy, () {
                    commonLaunchUrl(mPrivacyPolicy);
                  }),
                  accountSettingItemWidget(ic_information, language.helpAndSupport, () {
                    commonLaunchUrl('mailto:${appStore.siteEmail}');
                  }),
                  accountSettingItemWidget(ic_document, language.termAndCondition, () {
                    commonLaunchUrl(mTermAndCondition);
                  }),
                  accountSettingItemWidget(ic_information, language.aboutUs, () {
                    AboutUsScreen().launch(context);
                  }, isLast: pageList.isNotEmpty),
                  if (pageList.isNotEmpty) ...[
                    mTitle(language.pages),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        PageData item = pageList[index];
                        return accountSettingItemWidget(ic_pages, item.title.validate(), () {
                          PageDetailScreen(
                            title: item.title.validate(),
                            description: item.description.validate(),
                          ).launch(context);
                        });
                      },
                      itemCount: pageList.length,
                    )
                  ],
                  Container(
                    decoration: boxDecorationWithRoundedCorners(
                        border: Border.all(color: ColorUtils.colorPrimary, width: 1),
                        backgroundColor: Colors.transparent),
                    padding: EdgeInsets.all(16),
                    width: context.width(),
                    child: Text(language.logout,
                        style: boldTextStyle(size: 18, color: ColorUtils.colorPrimary), textAlign: TextAlign.center),
                  ).onTap(() async {
                    await showConfirmDialogCustom(
                      context,
                      primaryColor: ColorUtils.colorPrimary,
                      title: language.logoutConfirmationMsg,
                      positiveText: language.yes,
                      negativeText: language.no,
                      onAccept: (c) {
                        logout(context);
                      },
                    );
                  }).paddingAll(16),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (_, snap) {
                      if (snap.hasData) {
                        return Text('${language.version} ${snap.data!.version.validate()}', style: secondaryTextStyle())
                            .center();
                      }
                      return SizedBox();
                    },
                  ),
                  30.height,
                ],
              ),
            ],
          ),
          Positioned.fill(
            child: loaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/LoginResponse.dart';

import '../../extensions/animatedList/animated_scroll_view.dart';
import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/UserProfileDetailModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';

class UserDetailsScreen extends StatefulWidget {
  UserData? userData;

  UserDetailsScreen({super.key, this.userData});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String? bankNameCon;
  String? accNumberCon;
  String? nameCon;
  String? ifscCCon;
  String? onlineReceived;
  String? totalAmount;
  String? totalWithdrawn;
  String? manualReceived;
  EarningDetail earningDetail = EarningDetail();
  String addressValue = "";

  @override
  void initState() {
    super.initState();
    getBankDetail();
    getWalletData();
    getAddress();
  }

  getBankDetail() async {
    appStore.setLoading(true);
    await getUserDetail(widget.userData!.id.validate()).then((value) {
      appStore.setLoading(false);
      if (value.userBankAccount != null) {
        bankNameCon = value.userBankAccount!.bankName.validate();
        accNumberCon = value.userBankAccount!.accountNumber.validate();
        nameCon = value.userBankAccount!.accountHolderName.validate();
        ifscCCon = value.userBankAccount!.bankCode.validate();
        setState(() {});
      }
    }).then((value) {
      appStore.setLoading(false);
    });
  }

  getWalletData() async {
    appStore.setLoading(true);
    await getWalletList(page: 1).then((value) {
      appStore.setLoading(false);
      onlineReceived = value.walletBalance!.onlineReceived.toString();
      totalAmount = value.walletBalance!.totalAmount.toString();
      totalWithdrawn = value.walletBalance!.totalWithdrawn.toString();
      manualReceived = value.walletBalance!.manualReceived.toString();
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  getAddress() async {
    final currentAddress = await GeoCode().reverseGeocoding(
        latitude: widget.userData!.latitude.toDouble(), longitude: widget.userData!.longitude.toDouble());
    addressValue =
        "${currentAddress.streetNumber},${currentAddress.region},${currentAddress.postal},${currentAddress.countryName}";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
        appBarTitle: '${widget.userData != null ? widget.userData!.name!.capitalizeFirstLetter() : ''}',
        body: Stack(children: [
          widget.userData != null
              ? Stack(children: [
                  AnimatedScrollView(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                    children: [
                      if (widget.userData != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            Text(language.profile, style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            UserDetailsScreen(userData: widget.userData).launch(context);
                                          },
                                          child: Image.network(widget.userData!.profileImage.validate(),
                                                  height: 60, width: 60, fit: BoxFit.cover, alignment: Alignment.center)
                                              .cornerRadiusWithClipRRect(60)),
                                      8.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(widget.userData!.name.validate(), style: secondaryTextStyle(size: 14)),
                                          4.height,
                                          Text(widget.userData!.email.validate(), style: secondaryTextStyle(size: 14)),
                                          4.height,
                                          Text(widget.userData!.contactNumber.validate(),
                                              style: secondaryTextStyle(size: 14)),
                                        ],
                                      ).expand(),

                                      //  .visible(orderData!.status != ORDER_DELIVERED && orderData!.status != ORDER_CANCELLED && userData!.userType!=ADMIN && userData!.userType!=DEMO_ADMIN)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            16.height,
                            Text(language.bankDetails, style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.bankName, style: secondaryTextStyle()),
                                      Text(bankNameCon.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.accountNumber, style: secondaryTextStyle()),
                                      Text(accNumberCon.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.nameAsPerBank, style: secondaryTextStyle()),
                                      Text(nameCon.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.ifscCode, style: secondaryTextStyle()),
                                      Text(ifscCCon.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            12.height,
                            Text(language.earningHistory, style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.availableBalance, style: secondaryTextStyle()),
                                      Text(totalAmount.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.manualRecieved, style: secondaryTextStyle()),
                                      Text(manualReceived.toString().validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.totalWithdrawn, style: secondaryTextStyle()),
                                      Text(totalWithdrawn.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.totalWithdrawn, style: secondaryTextStyle()),
                                      Text(totalWithdrawn.validate(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            12.height,
                            Text(language.lastLocation, style: boldTextStyle(size: 16)),
                            12.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                                  backgroundColor: Colors.transparent),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.latitude, style: secondaryTextStyle()),
                                      Text(widget.userData!.latitude.toString(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.longitude, style: secondaryTextStyle()),
                                      Text(widget.userData!.longitude.toString(), style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  8.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(language.address, style: secondaryTextStyle()),
                                      Container(
                                        width: context.width() * 0.5,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            addressValue,
                                            textAlign: TextAlign.start,
                                            style: secondaryTextStyle(),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                ])
              : SizedBox(),
        ]));
  }
}

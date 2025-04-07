import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/AddressListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';
import '../components/DeleteConfirmationDialog.dart';
import 'AddAddressScreen.dart';

class MyAddressListScreen extends StatefulWidget {
  @override
  MyAddressListScreenState createState() => MyAddressListScreenState();
}

class MyAddressListScreenState extends State<MyAddressListScreen> {
  TextEditingController searchController = TextEditingController();

  List<AddressData> addressList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    appStore.setLoading(true);
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

  void init() async {
    await getAddressList(page: page).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      isLastPage = false;
      if (page == 1) {
        addressList.clear();
      }
      addressList.addAll(value.data!);

      List<AddressData> list = [];
      addressList.forEach((e) {
        list.add(e);
      });
      setValue(RECENT_ADDRESS_LIST, list.map((element) => jsonEncode(element)).toList());

      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  deleteUserAddressApiCall(int id) async {
    appStore.setLoading(true);
    await deleteUserAddress(id).then((value) {
      toast(value.message.toString());
      page = 1;
      init();
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
      appBarTitle: language.address,
      body: Observer(builder: (context) {
        return Stack(
          children: [
            addressList.isNotEmpty
                ? ListView.builder(
                    itemCount: addressList.length,
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemBuilder: (context, index) {
                      AddressData item = addressList[index];
                      return InkWell(
                        onTap: () async {
                          bool? res = await AddAddressScreen(addressData: item).launch(context);
                          if (res != null) {
                            page = 1;
                            init();
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(8),
                          decoration: boxDecorationWithRoundedCorners(
                              borderRadius: BorderRadius.circular(defaultRadius),
                              border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.4)),
                              backgroundColor: Colors.transparent),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.address.validate(), style: primaryTextStyle()),
                                  if (!item.addressType.isEmptyOrNull) 8.height,
                                  if (!item.addressType.isEmptyOrNull)
                                    Row(
                                      children: [
                                        Text("${language.addressType}:", style: secondaryTextStyle()),
                                        8.width,
                                        Text(item.addressType.toString(), style: boldTextStyle(size: 14)),
                                      ],
                                    ),
                                  8.height,
                                  Text(item.contactNumber.validate(), style: secondaryTextStyle()),
                                ],
                              ).expand(),
                              8.width,
                              Icon(Ionicons.md_trash_outline, color: Colors.red).onTap(() {
                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext dialogContext) {
                                    return DeleteConfirmationDialog(
                                      title: language.deleteLocation,
                                      subtitle: language.sureWantToDeleteAddress,
                                      onDelete: () {
                                        deleteUserAddressApiCall(item.id.validate());
                                      },
                                    );
                                  },
                                );
                              })
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorUtils.colorPrimary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          bool? res = await AddAddressScreen().launch(context);
          if (res != null) {
            page = 1;
            init();
          }
        },
      ),
    );
  }
}

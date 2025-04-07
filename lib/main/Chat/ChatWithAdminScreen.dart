import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/shared_pref.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Constants.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';
import '../models/CustomerSupportModel.dart';
import '../utils/Common.dart';
import '../utils/Widgets.dart';
import '../utils/dynamic_theme.dart';

class ChatWithAdminScreen extends StatefulWidget {
  List<SupportChatHistory>? supportChatHistory;
  int? supportId;
  ChatWithAdminScreen(this.supportChatHistory, this.supportId);
  @override
  State<ChatWithAdminScreen> createState() => _ChatWithAdminScreenState();
}

class _ChatWithAdminScreenState extends State<ChatWithAdminScreen> {
  var messageCont = TextEditingController();
  var messageFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  Future<void> getCustomerSupportListApi() async {
    await getCustomerSupportList(support_id: widget.supportId).then((value) {
      appStore.setLoading(false);
      widget.supportChatHistory!.clear();
      value.customerSupport!.first.supportChatHistory!.forEach((element) {
        widget.supportChatHistory!.add(element);
      });

      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  Future<void> sendMessage() async {
    messageFocus.unfocus();
    Map req = {"support_id": widget.supportId, "message": messageCont.text, "user_id": getIntAsync(USER_ID)};
    appStore.setLoading(true);
    await saveChat(req).then((value) {
      messageCont.clear();

      getCustomerSupportListApi();
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      showBack: false,
      appBar: commonAppBarWidget(
        language.chatWithAdmin,
      ),
      body: Container(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            Container(
                height: context.height(),
                width: context.width(),
                child: ListView.builder(
                  itemCount: widget.supportChatHistory!.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    SupportChatHistory item = widget.supportChatHistory![index];
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: item.sendBy != ADMIN ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: item.sendBy != ADMIN ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: item.sendBy != ADMIN ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8) : EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8, right: isRTL ? 0 : context.width() * 0.25),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
                              color: item.sendBy != ADMIN ? ColorUtils.colorPrimary : context.cardColor,
                              borderRadius: item.sendBy != ADMIN ? radiusOnly(bottomLeft: 12, topLeft: 12, bottomRight: 0, topRight: 12) : radiusOnly(bottomLeft: 0, topLeft: 12, bottomRight: 12, topRight: 12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: item.sendBy != ADMIN ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(item.message!, style: primaryTextStyle(color: item.sendBy != ADMIN ? Colors.white : textPrimaryColorGlobal), maxLines: null),
                                1.height,
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse("${item.datetime.toString()}").toLocal()),
                                      style: primaryTextStyle(color: item.sendBy == ADMIN ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6), size: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(top: 2, bottom: 2),
                    );
                  },
                )).paddingBottom(76),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: boxDecorationWithShadow(
                  borderRadius: BorderRadius.circular(30),
                  spreadRadius: 1,
                  blurRadius: 1,
                  backgroundColor: context.cardColor,
                ),
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    TextField(
                      controller: messageCont,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: language.writeAMessage,
                        hintStyle: secondaryTextStyle(),
                        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                      ),
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                      focusNode: messageFocus,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      style: primaryTextStyle(),
                      textInputAction: mIsEnterKey ? TextInputAction.send : TextInputAction.newline,
                      onSubmitted: (s) {},
                      cursorHeight: 20,
                      maxLines: 5,
                    ).expand(),
                    IconButton(
                      icon: Icon(Icons.send, color: ColorUtils.colorPrimary),
                      onPressed: () {
                        if (messageCont.text.isNotEmpty) sendMessage();
                      },
                    )
                  ],
                ),
                width: context.width(),
              ),
            ),
            Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
          ],
        ),
      ),
    );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Widgets.dart';
import '../../extensions/colors.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';
import '../models/ChatMessageModel.dart';
import '../models/LoginResponse.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';
import 'ChatItemWidget.dart';

class ChatScreen extends StatefulWidget {
  final UserData? userData;
  String? orderId;

  ChatScreen({this.userData, this.orderId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String id = '';
  var messageCont = TextEditingController();
  var messageFocus = FocusNode();
  bool isMe = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  UserData sender = UserData(
    name: getStringAsync(USER_NAME),
    profileImage: appStore.userProfile,
    uid: getStringAsync(UID),
    playerId: getStringAsync(PLAYER_ID),
  );

  init() async {
    log(widget.userData!.toJson());
    id = getStringAsync(UID);
    mIsEnterKey = getBoolAsync(IS_ENTER_KEY, defaultValue: false);
    mSelectedImage = getStringAsync(SELECTED_WALLPAPER, defaultValue: "assets/default_wallpaper.png");

    //   chatMessageService = ChatMessageService();
    ordersMessageService.setUnReadStatusToTrue(orderId: widget.orderId);
    print(widget.userData!.uid!);
    setState(() {});
  }

  sendMessage({FilePickerResult? result}) async {
    if (result == null) {
      if (messageCont.text.trim().isEmpty) {
        messageFocus.requestFocus();
        return;
      }
    }
    ChatMessageModel data = ChatMessageModel();
    data.receiverId = widget.userData!.uid;
    data.senderId = sender.uid;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;

    if (widget.userData!.uid == getStringAsync(UID)) {
      //
    }
    if (result != null) {
      if (result.files.single.path.isImage) {
        data.messageType = MessageType.IMAGE.name;
      } else {
        data.messageType = MessageType.TEXT.name;
      }
    } else {
      data.messageType = MessageType.TEXT.name;
    }

    notificationService
        .sendPushNotifications(getStringAsync(USER_NAME), messageCont.text, receiverPlayerId: widget.userData!.playerId)
        .catchError(log);
    messageCont.clear();
    setState(() {});
    return await ordersMessageService.addOrderMessage(data, widget.orderId).then((value) async {});
  }

  @override
  Widget build(BuildContext context) {
    log(widget.userData!.uid);
    return CommonScaffoldComponent(
      showBack: false,
      appBar: commonAppBarWidget(
        '',
        titleWidget: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                backgroundColor: context.cardColor,
                backgroundImage: NetworkImage(widget.userData!.profileImage.validate()),
                minRadius: 20),
            10.width,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userData!.name.validate(), style: secondaryTextStyle(size: 16, color: whiteColor)),
                4.height,
                Text(' # ${widget.orderId.validate()}', style: secondaryTextStyle(size: 14, color: Colors.white60)),
              ],
            ).expand(),
          ],
        ),
      ),
      body: Container(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            Container(
              height: context.height(),
              width: context.width(),
              child: PaginateFirestore(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: ordersMessageService.chatMessagesWithPagination(
                    currentUserId: getStringAsync(UID),
                    receiverUserId: widget.userData!.uid.validate(),
                    orderId: widget.orderId),
                itemsPerPage: PER_PAGE_CHAT_COUNT,
                shrinkWrap: true,
                onEmpty: Offstage(),
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, snap, index) {
                  ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);
                  data.isMe = data.senderId == sender.uid;
                  if (widget.orderId == data.orderId) {}
                  return ChatItemWidget(data: data);
                },
              ).paddingBottom(76),
            ),
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
                      onSubmitted: (s) {
                        try {
                          sendMessage();
                        } catch (e) {
                          print("error : ${e.toString()}");
                        }
                      },
                      cursorHeight: 20,
                      maxLines: 5,
                    ).expand(),
                    IconButton(
                      icon: Icon(Icons.send, color: ColorUtils.colorPrimary),
                      onPressed: () {
                        try {
                          sendMessage();
                        } catch (e) {
                          print("error :${e.toString()}");
                        }
                      },
                    )
                  ],
                ),
                width: context.width(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

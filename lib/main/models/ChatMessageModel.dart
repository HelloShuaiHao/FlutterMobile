class ChatMessageModel {
  String? id;
  String? senderId;
  String? receiverId;
  String? photoUrl;
  String? messageType;
  bool? isMe;
  bool? isMessageRead;
  String? message;
  int? createdAt;
  String? orderId;

  ChatMessageModel(
      {this.id,
      this.senderId,
      this.receiverId,
      this.createdAt,
      this.message,
      this.isMessageRead,
      this.photoUrl,
      this.messageType,
      this.orderId});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      isMessageRead: json['isMessageRead'],
      photoUrl: json['photoUrl'],
      messageType: json['messageType'],
      createdAt: json['createdAt'],
      orderId: json['orderId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['message'] = this.message;
    data['senderId'] = this.senderId;
    data['isMessageRead'] = this.isMessageRead;
    data['receiverId'] = this.receiverId;
    data['photoUrl'] = this.photoUrl;
    data['messageType'] = this.messageType;
    data['orderId'] = this.orderId;
    return data;
  }
}

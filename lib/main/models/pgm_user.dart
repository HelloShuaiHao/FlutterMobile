//I/flutter (16657): │ 💡 pgmInfoRes:{data: {pgm_id: switchers-581356350e50a978, foldback_media_type: switcher, foldback_video: , foldback_audio: built-in-audio, monitor_info: {app_id: 1600034102, user_id: camera-58135635db917f25pgm, token: eJwszs1OhDAUBeB3uVsVbv-4aeJGgrLQuBCDW6SX2iim0ymTCZN590mA7XdOTs4F2tePhM7eBQKdoSwQ71dzhv6jGx0F0DD0E4X*QRVMqEwo812yfOTK2wm29tH89t47A5pliCgkQ74nzoIGf-hsqpgO5bMIXWy-aKYq-izqfRmbv7mr3*5SXzeFfXqxj-tkdBOBZrmQQgqes01P6x*eIFxvAQAA--*sDjbV, room_id: 58135635}}, msg: 成功, req_id: 000, status: 0, trace: }

class MonitorUser {
  String? userId;
  String? appId;
  String? token;
  String? roomId;

  MonitorUser({this.userId, this.appId, this.token, this.roomId});
}

class PgmUser {
  String? userId;
  bool available = false;
  MonitorUser? monitorUser;
}

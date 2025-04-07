import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:signalr_netcore/signalr_client.dart';

Future<void> testSignalR() async {
  final hubUrl = MY_SIGNALR_BASE_URL;
  final connection = HubConnectionBuilder()
      .withUrl(
        hubUrl,
        options: HttpConnectionOptions(
          accessTokenFactory: () async {
            // 在代码中定义了 token 默认值，但后面的 .val("token") 扩展方法会尝试从 GetStorage 或其它存储中读取 "token" 的值。
            final token = SpUtil.token.defaultValue;
            // return 'Bearer $token';
            return token;
          },
        ),
      )
      .build();
  
  // Register the callback function for the backend to invoke
  connection.on("ReceiveMessage", (arguments) {
    print("Received message: $arguments");
  });

  try {
    await connection.start();
    print("SignalR is connected");
    await connection.invoke("SendMessage", args: ["Admin", "Hello from Flutter"]);
    print("Message sent");
  }catch (e) {
    print("Connection error: $e");
  }
}
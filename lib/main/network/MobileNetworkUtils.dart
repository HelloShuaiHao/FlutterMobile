// import 'package:http/http.dart';
// import 'package:mighty_delivery/extensions/common.dart';
// import 'package:mighty_delivery/main.dart';
// import 'package:mighty_delivery/main/network/NetworkUtils.dart';
// import 'package:mighty_delivery/main/utils/Constants.dart';


// Uri buildMyBaseUrl(String endPoint) {
//   Uri url = Uri.parse(endPoint);
//   if (!endPoint.startsWith('http')) url = Uri.parse('$mBaseUrl$endPoint');

//   log('URL: ${url.toString()}');

//   return url;
// }

// Future<Response> buildMyHttpResponse(String endPoint, {HttpMethod method = HttpMethod.Get, Map? request}) async {
//   if (await isNetworkAvailable()) {
//     var headers = buildHeaderTokens();
//     Uri url = buildMyBaseUrl(endPoint);
//     try {

//     } catch(e) {
//       print("---------------------------${e.toString()}");
//       throw language.errorSomethingWentWrong;
//     }
//   } else {
//     throw language.errorInternetNotAvailable;
//   }
// }
import '../../../main/network/NetworkUtils.dart';
import '../models/ApplyBidModel.dart';
import '../models/BidListResponseModel.dart';
import '../models/BidResponseModel.dart';

Future<BidResponse> getBiddingDetails(int id) async {
  return BidResponse.fromJson(await handleResponse(await buildHttpResponse(
      'get-bidding-order?id=$id',
      method: HttpMethod.GET)));
}

Future<Applybidmodel> createBid(Map request) async {
  return Applybidmodel.fromJson(await handleResponse(await buildHttpResponse(
      'apply-bid',
      request: request,
      method: HttpMethod.POST)));
}

Future<Applybidmodel> acceptOrRejectBid(Map request) async {
  return Applybidmodel.fromJson(await handleResponse(await buildHttpResponse(
      'order-bid-respond',
      request: request,
      method: HttpMethod.POST)));
}

Future<BidListResponseModel> getBidList() async {
  return BidListResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('orderbid-list', method: HttpMethod.GET)));
}

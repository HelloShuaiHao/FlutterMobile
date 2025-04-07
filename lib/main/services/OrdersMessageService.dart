import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../extensions/shared_pref.dart';
import '../../main.dart';
import '../models/ChatMessageModel.dart';
import '../utils/Constants.dart';
import 'BaseServices.dart';

class OrdersMessageService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  late CollectionReference ordersRef;
  //FirebaseStorage _storage = FirebaseStorage.instance;

  OrdersMessageService() {
    ordersRef = fireStore.collection(ORDERS_COLLECTION);
  }

  Query chatMessagesWithPagination({String? currentUserId, required String receiverUserId, String? orderId}) {
    return ordersRef.doc(orderId).collection(ORDERS_MESSAGES_COLLECTION).orderBy("createdAt", descending: true);
  }

  Future<DocumentReference> addOrderMessage(ChatMessageModel data, String? orderId) async {
    var doc = await ordersRef.doc(orderId).collection(ORDERS_MESSAGES_COLLECTION).add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Future<void> deleteSingleMessage({required String docId, String? orderId}) async {
    try {
      ordersRef.doc(orderId).collection(ORDERS_MESSAGES_COLLECTION).doc(docId).delete();
    } on Exception catch (e) {
      log(e.toString());
      throw language.errorSomethingWentWrong;
    }
  }

  Future<void> setUnReadStatusToTrue({String? orderId}) async {
    ordersRef
        .doc(orderId)
        .collection(ORDERS_MESSAGES_COLLECTION)
        .where('receiverId', isEqualTo: getStringAsync(UID))
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update({
          'isMessageRead': true,
        });
      });
    });
  }

  Stream<int> getUnReadCount({required String receiverId, String? orderId}) {
    return ordersRef
        .doc(orderId)
        .collection(ORDERS_MESSAGES_COLLECTION)
        .where('isMessageRead', isEqualTo: false)
        .where('receiverId', isEqualTo: getStringAsync(UID))
        .snapshots()
        .map(
          (event) => event.docs.length,
        )
        .handleError((e) {
      return e;
    });
  }
}

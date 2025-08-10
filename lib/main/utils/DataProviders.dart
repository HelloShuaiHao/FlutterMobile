import '../../main.dart';
import '../../main/models/models.dart';
import 'Images.dart';

List<String> getUserCancelReasonList() {
  List<String> list = [];
  list.add(language.placeOrderByMistake);
  list.add(language.deliveryTimeIsTooLong);
  list.add(language.duplicateOrder);
  list.add(language.changeOfMind);
  list.add(language.changeOrder);
  list.add(language.incorrectIncompleteAddress);
  list.add(language.other);
  return list;
}

List<String> getDeliveryCancelReasonList() {
  List<String> list = [];
  list.add(language.incorrectIncompleteAddress);
  list.add(language.wrongContactInformation);
  list.add(language.damageCourier);
  list.add(language.paymentIssue);
  list.add(language.personNotAvailableOnLocation);
  list.add(language.invalidCourierPackage);
  list.add(language.courierPackageIsNotAsPerOrder);
  list.add(language.other);
  return list;
}

List<String> getDeliveryBoyBeforePickupCancelReasonList() {
  List<String> list = [];
  list.add(language.invalidPickupAddress);
  list.add(language.refusedBySender);
  list.add(language.notAsOrder);
  list.add(language.damageCourier);
  list.add(language.invalidCourierPackage);
  list.add(language.other);
  return list;
}

List<String> getDeliveryBoyAfterPickupCancelReasonList() {
  List<String> list = [];
  list.add(language.invalidDeliveryAddress);
  list.add(language.exception);
  list.add(language.refusedByRecipient);
  list.add(language.other);
  return list;
}

List<String> getReturnReasonList() {
  List<String> list = [];
  list.add(language.invalidOrder);
  list.add(language.damageCourier);
  list.add(language.sentWrongCourier);
  list.add(language.notAsOrder);
  list.add(language.other);
  return list;
}

// List<LanguageDataModel> languageList() {
//   return [
//     LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
//     LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
//     LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
//     LanguageDataModel(id: 1, name: 'Spanish', subTitle: 'Española', languageCode: 'es', fullLanguageCode: 'es-ES', flag: 'assets/flag/ic_spain.png'),
//     LanguageDataModel(id: 2, name: 'Afrikaans', subTitle: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'af-AF', flag: 'assets/flag/ic_south_africa.png'),
//     LanguageDataModel(id: 3, name: 'French', subTitle: 'Français', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_france.png'),
//     LanguageDataModel(id: 1, name: 'German', subTitle: 'Deutsch', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_germany.png'),
//     LanguageDataModel(id: 2, name: 'Indonesian', subTitle: 'bahasa Indonesia', languageCode: 'id', fullLanguageCode: 'id-ID', flag: 'assets/flag/ic_indonesia.png'),
//     LanguageDataModel(id: 3, name: 'Portuguese', subTitle: 'Português', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'assets/flag/ic_portugal.png'),
//     LanguageDataModel(id: 1, name: 'Turkish', subTitle: 'Türkçe', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'assets/flag/ic_turkey.png'),
//     LanguageDataModel(id: 2, name: 'vietnamese', subTitle: 'Tiếng Việt', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'assets/flag/ic_vitnam.png'),
//     LanguageDataModel(id: 3, name: 'Dutch', subTitle: 'Nederlands', languageCode: 'nl', fullLanguageCode: 'nl-NL', flag: 'assets/flag/ic_dutch.png'),
//   ];
// }

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(
      image: 'assets/walk_through1.png', title: language.walkThrough1Title, subTitle: language.walkThrough1Subtitle));
  list.add(WalkThroughItemModel(
      image: 'assets/walk_through2.png', title: language.walkThrough2Title, subTitle: language.walkThrough2Subtitle));
  list.add(WalkThroughItemModel(
      image: 'assets/walk_through3.png', title: language.walkThrough3Title, subTitle: language.walkThrough3Subtitle));
  return list;
}

List<Map<String, String>> getPackagingSymbols() {
  return [
    {
      'title': language.thisWayUup,
      'image': ic_this_way_up,
      'description': language.thisWayUpDesc,
      'key': 'this_way_up',
    },
    {
      'title': language.doNotStack,
      'image': ic_do_not_stack,
      'description': language.doNotStackDesc,
      'key': 'do_not_stack',
    },
    {
      'title': language.temperatureSensitive,
      'image': ic_temperature_sensitive,
      'description': language.temperatureSensitiveDesc,
      'key': 'temperature_sensitive',
    },
    {
      'title': language.doNotHook,
      'image': ic_do_not_hook,
      'description': language.doNotStackDesc,
      'key': 'do_not_use_hooks',
    },
    {
      'title': language.explosiveMaterial,
      'image': ic_explosive_material,
      'description': language.explosiveMaterialDesc,
      'key': 'explosive_material',
    },
    {
      'title': language.hazard,
      'image': ic_hazard,
      'description': language.hazardDesc,
      'key': 'hazardous_material',
    },
    {
      'title': language.bikeDelivery,
      'image': ic_bike_delivery,
      'description': language.bikeDeliveryDesc,
      'key': 'bike_delivery',
    },
    {
      'title': language.keepDry,
      'image': ic_keep_dry,
      'description': language.keepDryDesc,
      'key': 'keep_dry',
    },
    {
      'title': language.perishable,
      'image': ic_perishable,
      'description': language.perishableDesc,
      'key': 'perishable',
    },
    {
      'title': language.recycle,
      'image': ic_recycle,
      'description': language.recycleDesc,
      'key': 'recycle',
    },
    {
      'title': language.doNotOpenWithSharpObject,
      'image': ic_do_not_open_with_sharp_object,
      'description': language.doNotOpenWithSharpObjectDesc,
      'key': 'do_not_open_with_sharp_objects',
    },
    {
      'title': language.fragile,
      'image': ic_fragile,
      'description': language.fragileDesc,
      'key': 'fragile',
    },
  ];
}

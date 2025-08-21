import 'package:flutter/material.dart';

import 'LanguageDataConstant.dart';

class BaseLanguage {
  static BaseLanguage? of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get skip => getContentValueFromKey(1);

  String get getStarted => getContentValueFromKey(2);

  String get walkThrough1Title => getContentValueFromKey(3);

  String get walkThrough2Title => getContentValueFromKey(4);

  String get walkThrough3Title => getContentValueFromKey(5);

  String get walkThrough1Subtitle => getContentValueFromKey(6);

  String get walkThrough2Subtitle => getContentValueFromKey(7);

  String get walkThrough3Subtitle => getContentValueFromKey(8);

  String get appName => getContentValueFromKey(9);

  String get userNotApproveMsg => getContentValueFromKey(10);

  String get acceptTermService => getContentValueFromKey(11);

  String get signIn => getContentValueFromKey(12);

  String get email => getContentValueFromKey(13);
  String get id => getContentValueFromKey(13);

  String get password => getContentValueFromKey(14);

  String get rememberMe => getContentValueFromKey(15);

  String get forgotPasswordQue => getContentValueFromKey(16);

  String get iAgreeToThe => getContentValueFromKey(17);

  String get termOfService => getContentValueFromKey(18);

  String get privacyPolicy => getContentValueFromKey(19);

  String get demoUser => getContentValueFromKey(20);

  String get demoDeliveryMan => getContentValueFromKey(21);

  String get doNotHaveAccount => getContentValueFromKey(22);

  String get signWith => getContentValueFromKey(23);

  String get becomeADeliveryBoy => getContentValueFromKey(24);

  String get signUp => getContentValueFromKey(25);

  String get lblUser => getContentValueFromKey(26);

  String get selectUserType => getContentValueFromKey(27);

  String get lblDeliveryBoy => getContentValueFromKey(28);

  String get cancel => getContentValueFromKey(29);

  String get lblContinue => getContentValueFromKey(30);

  String get fieldRequiredMsg => getContentValueFromKey(31);

  String get emailInvalid => getContentValueFromKey(32);

  String get passwordInvalid => getContentValueFromKey(33);

  String get errorInternetNotAvailable => getContentValueFromKey(74);

  String get errorSomethingWentWrong => getContentValueFromKey(57);

  String get credentialNotMatch => getContentValueFromKey(60);

  String get verificationCompleted => getContentValueFromKey(279);

  String get phoneNumberInvalid => getContentValueFromKey(280);

  String get codeSent => getContentValueFromKey(281);

  String get internetIsConnected => getContentValueFromKey(282);

  String get userNotFound => getContentValueFromKey(283);

  String get allowLocationPermission => getContentValueFromKey(310);

  String get invalidUrl => getContentValueFromKey(352);

  String get signInFailed => getContentValueFromKey(355);

  String get appleSignInNotAvailableError => getContentValueFromKey(356);

  String get mapLoadingError => getContentValueFromKey(263);

  String get name => getContentValueFromKey(34);

  String get contactNumber => getContentValueFromKey(35);

  String get alreadyHaveAnAccount => getContentValueFromKey(36);

  String get username => getContentValueFromKey(258);

  String get forgotPassword => getContentValueFromKey(37);

  String get submit => getContentValueFromKey(38);

  String get demoMsg => getContentValueFromKey(39);

  String get mAppDescription => getContentValueFromKey(40);

  String get contactUs => getContentValueFromKey(41);

  String get aboutUs => getContentValueFromKey(42);

  String get copyRight => getContentValueFromKey(354);

  String get bankDetails => getContentValueFromKey(43);

  String get bankName => getContentValueFromKey(44);

  String get accountNumber => getContentValueFromKey(45);

  String get nameAsPerBank => getContentValueFromKey(46);

  String get ifscCode => getContentValueFromKey(47);

  String get save => getContentValueFromKey(48);

  String get changePassword => getContentValueFromKey(49);

  String get oldPassword => getContentValueFromKey(50);

  String get newPassword => getContentValueFromKey(51);

  String get confirmPassword => getContentValueFromKey(52);

  String get passwordNotMatch => getContentValueFromKey(53);

  String get saveChanges => getContentValueFromKey(54);

  String get editProfile => getContentValueFromKey(55);

  String get notChangeEmail => getContentValueFromKey(56);

  String get notChangeMobileNo => getContentValueFromKey(58);

  String get address => getContentValueFromKey(59);

  String get logoutConfirmationMsg => getContentValueFromKey(61);

  String get yes => getContentValueFromKey(62);

  String get no => getContentValueFromKey(63);

  String get emailVerification => getContentValueFromKey(64);

  String get weSend => getContentValueFromKey(65);

  String get oneTimePassword => getContentValueFromKey(66);

  String get on => getContentValueFromKey(67);

  String get getEmail => getContentValueFromKey(68);

  String get confirmationCode => getContentValueFromKey(69);

  String get confirmationCodeSent => getContentValueFromKey(70);

  String get didNotReceiveTheCode => getContentValueFromKey(71);

  String get resend => getContentValueFromKey(72);

  String get language => getContentValueFromKey(73);

  String get notifications => getContentValueFromKey(75);

  String get markAllRead => getContentValueFromKey(76);

  String get light => getContentValueFromKey(77);

  String get dark => getContentValueFromKey(78);

  String get systemDefault => getContentValueFromKey(79);

  String get theme => getContentValueFromKey(80);

  String get pleaseSelectCity => getContentValueFromKey(81);

  String get selectRegion => getContentValueFromKey(82);

  String get country => getContentValueFromKey(83);

  String get city => getContentValueFromKey(84);

  String get selectCity => getContentValueFromKey(85);

  String get verification => getContentValueFromKey(86);

  String get phoneNumberVerification => getContentValueFromKey(87);

  String get getOTP => getContentValueFromKey(88);

  String get invalidVerificationCode => getContentValueFromKey(89);

  String get deleteMessage => getContentValueFromKey(90);

  String get writeAMessage => getContentValueFromKey(91);

  String get addNewAddress => getContentValueFromKey(92);

  String get pleaseSelectValidAddress => getContentValueFromKey(93);

  String get balanceInsufficient => getContentValueFromKey(94);

  String get deliveryNow => getContentValueFromKey(95);

  String get schedule => getContentValueFromKey(96);

  String get pickTime => getContentValueFromKey(97);

  String get date => getContentValueFromKey(98);

  String get from => getContentValueFromKey(99);

  String get endTimeValidationMsg => getContentValueFromKey(100);

  String get to => getContentValueFromKey(101);

  String get deliverTime => getContentValueFromKey(102);

  String get weight => getContentValueFromKey(103);

  String get numberOfParcels => getContentValueFromKey(104);

  String get selectVehicle => getContentValueFromKey(105);

  String get parcelType => getContentValueFromKey(106);

  String get pickupInformation => getContentValueFromKey(107);

  String get selectAddressSave => getContentValueFromKey(108);

  String get selectAddress => getContentValueFromKey(109);

  String get location => getContentValueFromKey(110);

  String get description => getContentValueFromKey(111);

  String get deliveryInformation => getContentValueFromKey(112);

  String get deliveryLocation => getContentValueFromKey(113);

  String get deliveryContactNumber => getContentValueFromKey(114);

  String get deliveryDescription => getContentValueFromKey(115);

  String get packageInformation => getContentValueFromKey(116);

  String get pickupLocation => getContentValueFromKey(118);

  String get payment => getContentValueFromKey(120);

  String get paymentCollectFrom => getContentValueFromKey(121);

  String get saveDraftConfirmationMsg => getContentValueFromKey(122);

  String get saveDraft => getContentValueFromKey(123);

  String get createOrder => getContentValueFromKey(124);

  String get previous => getContentValueFromKey(125);

  String get next => getContentValueFromKey(126);

  String get sourceLocation => getContentValueFromKey(127);

  String get destinationLocation => getContentValueFromKey(128);

  String get pickupCurrentValidationMsg => getContentValueFromKey(129);

  String get pickupDeliverValidationMsg => getContentValueFromKey(130);

  String get createOrderConfirmationMsg => getContentValueFromKey(131);

  String get deliveryCharge => getContentValueFromKey(132);

  String get distanceCharge => getContentValueFromKey(133);

  String get weightCharge => getContentValueFromKey(134);

  String get extraCharges => getContentValueFromKey(135);

  String get total => getContentValueFromKey(136);

  String get choosePickupAddress => getContentValueFromKey(137);

  String get chooseDeliveryAddress => getContentValueFromKey(138);

  String get showingAllAddress => getContentValueFromKey(139);

  String get confirmation => getContentValueFromKey(284);

  String get create => getContentValueFromKey(285);

  String get cash => getContentValueFromKey(302);

  String get online => getContentValueFromKey(303);

  String get balanceInsufficientCashPayment => getContentValueFromKey(340);

  String get ok => getContentValueFromKey(341);

  String get myOrders => getContentValueFromKey(140);

  String get account => getContentValueFromKey(141);

  String get hey => getContentValueFromKey(142);

  String get filter => getContentValueFromKey(286);

  String get reset => getContentValueFromKey(287);

  String get status => getContentValueFromKey(288);

  String get mustSelectStartDate => getContentValueFromKey(289);

  String get toDateValidationMsg => getContentValueFromKey(290);

  String get applyFilter => getContentValueFromKey(291);

  String get ordersWalletMore => getContentValueFromKey(143);

  String get drafts => getContentValueFromKey(144);

  String get wallet => getContentValueFromKey(145);

  String get lblMyAddresses => getContentValueFromKey(146);

  String get deleteAccount => getContentValueFromKey(147);

  String get general => getContentValueFromKey(148);

  String get termAndCondition => getContentValueFromKey(149);

  String get helpAndSupport => getContentValueFromKey(150);

  String get logout => getContentValueFromKey(151);

  String get version => getContentValueFromKey(152);

  String get verifyDocument => getContentValueFromKey(119);

  String get confirmAccountDeletion => getContentValueFromKey(153);

  String get deleteAccountMsg2 => getContentValueFromKey(154);

  String get deleteAccountConfirmMsg => getContentValueFromKey(155);

  String get draftOrder => getContentValueFromKey(156);

  String get delete => getContentValueFromKey(157);

  String get deleteDraft => getContentValueFromKey(158);

  String get sureWantToDeleteDraft => getContentValueFromKey(159);

  String get selectLocation => getContentValueFromKey(160);

  String get selectPickupLocation => getContentValueFromKey(161);

  String get selectDeliveryLocation => getContentValueFromKey(162);

  String get searchAddress => getContentValueFromKey(163);

  String get pleaseWait => getContentValueFromKey(164);

  String get confirmPickupLocation => getContentValueFromKey(165);

  String get confirmDeliveryLocation => getContentValueFromKey(166);

  String get addressNotInArea => getContentValueFromKey(167);

  String get deleteLocation => getContentValueFromKey(168);

  String get sureWantToDeleteAddress => getContentValueFromKey(169);

  String get at => getContentValueFromKey(170);

  String get distance => getContentValueFromKey(171);

  String get duration => getContentValueFromKey(172);

  String get picked => getContentValueFromKey(173);

  String get note => getContentValueFromKey(174);

  String get courierWillPickupAt => getContentValueFromKey(175);

  String get delivered => getContentValueFromKey(176);

  String get courierWillDeliverAt => getContentValueFromKey(177);

  String get viewHistory => getContentValueFromKey(178);

  String get parcelDetails => getContentValueFromKey(179);

  String get paymentDetails => getContentValueFromKey(180);

  String get paymentType => getContentValueFromKey(181);

  String get paymentStatus => getContentValueFromKey(182);

  String get vehicle => getContentValueFromKey(183);

  String get vehicleName => getContentValueFromKey(184);

  String get aboutDeliveryMan => getContentValueFromKey(185);

  String get aboutUser => getContentValueFromKey(186);

  String get returnReason => getContentValueFromKey(187);

  String get cancelledReason => getContentValueFromKey(188);

  String get cancelBeforePickMsg => getContentValueFromKey(189);

  String get cancelAfterPickMsg => getContentValueFromKey(190);

  String get cancelOrder => getContentValueFromKey(191);

  String get cancelNote => getContentValueFromKey(192);

  String get returnOrder => getContentValueFromKey(193);

  String get onPickup => getContentValueFromKey(317);

  String get onDelivery => getContentValueFromKey(318);

  String get stripe => getContentValueFromKey(319);

  String get razorpay => getContentValueFromKey(320);

  String get payStack => getContentValueFromKey(321);

  String get flutterWave => getContentValueFromKey(322);

  String get paypal => getContentValueFromKey(323);

  String get payTabs => getContentValueFromKey(324);

  String get mercadoPago => getContentValueFromKey(325);

  String get paytm => getContentValueFromKey(326);

  String get myFatoorah => getContentValueFromKey(327);

  String get orderHistory => getContentValueFromKey(194);

  String get yourOrder => getContentValueFromKey(195);

  String get hasBeenAssignedTo => getContentValueFromKey(196);

  String get hasBeenTransferedTo => getContentValueFromKey(197);

  String get newOrderHasBeenCreated => getContentValueFromKey(198);

  String get deliveryPersonArrivedMsg => getContentValueFromKey(199);

  String get deliveryPersonPickedUpCourierMsg => getContentValueFromKey(200);

  String get hasBeenOutForDelivery => getContentValueFromKey(201);

  String get paymentStatusPaisMsg => getContentValueFromKey(202);

  String get deliveredMsg => getContentValueFromKey(203);

  String get lastUpdatedAt => getContentValueFromKey(204);

  String get trackOrder => getContentValueFromKey(205);

  String get track => getContentValueFromKey(304);

  String get transactionFailed => getContentValueFromKey(206);

  String get success => getContentValueFromKey(207);

  String get failed => getContentValueFromKey(208);

  String get paymentMethod => getContentValueFromKey(209);

  String get payNow => getContentValueFromKey(210);

  String get other => getContentValueFromKey(211);

  String get reason => getContentValueFromKey(212);

  String get writeReasonHere => getContentValueFromKey(213);

  String get lblReturn => getContentValueFromKey(214);

  String get profile => getContentValueFromKey(215);

  String get earningHistory => getContentValueFromKey(216);

  String get availableBalance => getContentValueFromKey(217);

  String get manualRecieved => getContentValueFromKey(218);

  String get totalWithdrawn => getContentValueFromKey(219);

  String get lastLocation => getContentValueFromKey(220);

  String get latitude => getContentValueFromKey(221);

  String get longitude => getContentValueFromKey(222);

  String get walletHistory => getContentValueFromKey(223);

  String get addMoney => getContentValueFromKey(224);

  String get amount => getContentValueFromKey(225);

  String get add => getContentValueFromKey(226);

  String get addAmount => getContentValueFromKey(227);

  String get withdraw => getContentValueFromKey(228);

  String get bankNotFound => getContentValueFromKey(229);

  String get orderFee => getContentValueFromKey(342);

  String get topup => getContentValueFromKey(343);

  String get orderCancelCharge => getContentValueFromKey(344);

  String get orderCancelRefund => getContentValueFromKey(345);

  String get correction => getContentValueFromKey(346);

  String get commission => getContentValueFromKey(347);

  String get order => getContentValueFromKey(230);

  String get orderCancelConfirmation => getContentValueFromKey(231);

  String get notifyUser => getContentValueFromKey(232);

  String get areYouSureWantToArrive => getContentValueFromKey(233);

  String get orderArrived => getContentValueFromKey(234);

  String get orderActiveSuccessfully => getContentValueFromKey(235);

  String get orderDepartedSuccessfully => getContentValueFromKey(236);

  String get accept => getContentValueFromKey(237);

  String get pickUp => getContentValueFromKey(238);

  String get departed => getContentValueFromKey(239);

  String get confirmDelivery => getContentValueFromKey(240);

  String get orderPickupConfirmation => getContentValueFromKey(311);

  String get orderDepartedConfirmation => getContentValueFromKey(312);

  String get orderCreateConfirmation => getContentValueFromKey(313);

  String get orderCompleteConfirmation => getContentValueFromKey(314);

  String get assigned => getContentValueFromKey(348);

  String get draft => getContentValueFromKey(349);

  String get created => getContentValueFromKey(350);

  String get accepted => getContentValueFromKey(351);

  String get orderAssignConfirmation => getContentValueFromKey(353);

  String get earning => getContentValueFromKey(241);

  String get adminCommission => getContentValueFromKey(242);

  String get orderId => getContentValueFromKey(243);

  String get pickedUp => getContentValueFromKey(306);

  String get arrived => getContentValueFromKey(307);

  String get completed => getContentValueFromKey(308);

  String get cancelled => getContentValueFromKey(309);

  String get orderDeliveredSuccessfully => getContentValueFromKey(244);

  String get orderPickupSuccessfully => getContentValueFromKey(245);

  String get imagePickToCamera => getContentValueFromKey(246);

  String get imagePicToGallery => getContentValueFromKey(247);

  String get orderDeliver => getContentValueFromKey(248);

  String get orderPickup => getContentValueFromKey(249);

  String get info => getContentValueFromKey(250);

  String get paymentCollectFromDelivery => getContentValueFromKey(251);

  String get paymentCollectFromPickup => getContentValueFromKey(252);

  String get pickupDatetime => getContentValueFromKey(253);

  String get deliveryDatetime => getContentValueFromKey(254);

  String get userSignature => getContentValueFromKey(255);

  String get clear => getContentValueFromKey(256);

  String get deliveryTimeSignature => getContentValueFromKey(257);

  String get confirmPickup => getContentValueFromKey(259);

  String get pleaseConfirmPayment => getContentValueFromKey(260);

  String get selectDeliveryTimeMsg => getContentValueFromKey(261);

  String get otpVerification => getContentValueFromKey(262);

  String get enterTheCodeSendTo => getContentValueFromKey(264);

  String get orderCancelledSuccessfully => getContentValueFromKey(305);

  String get placeOrderByMistake => getContentValueFromKey(328);

  String get deliveryTimeIsTooLong => getContentValueFromKey(329);

  String get duplicateOrder => getContentValueFromKey(330);

  String get changeOfMind => getContentValueFromKey(331);

  String get changeOrder => getContentValueFromKey(332);

  String get incorrectIncompleteAddress => getContentValueFromKey(333);

  String get wrongContactInformation => getContentValueFromKey(334);

  String get paymentIssue => getContentValueFromKey(335);

  String get personNotAvailableOnLocation => getContentValueFromKey(336);

  String get invalidCourierPackage => getContentValueFromKey(337);

  String get courierPackageIsNotAsPerOrder => getContentValueFromKey(338);

  String get invalidOrder => getContentValueFromKey(339);

  String get damageCourier => getContentValueFromKey(117);

  String get sentWrongCourier => getContentValueFromKey(315);

  String get notAsOrder => getContentValueFromKey(276);

  String get yourLocation => getContentValueFromKey(265);

  String get lastUpdateAt => getContentValueFromKey(266);

  String get trackingOrder => getContentValueFromKey(267);

  String get uploadFileConfirmationMsg => getContentValueFromKey(268);

  String get pending => getContentValueFromKey(269);

  String get approved => getContentValueFromKey(270);

  String get rejected => getContentValueFromKey(271);

  String get selectDocument => getContentValueFromKey(272);

  String get addDocument => getContentValueFromKey(273);

  String get declined => getContentValueFromKey(274);

  String get requested => getContentValueFromKey(275);

  String get withdrawHistory => getContentValueFromKey(277);

  String get withdrawMoney => getContentValueFromKey(278);

  String get invoice => getContentValueFromKey(292);

  String get customerName => getContentValueFromKey(293);

  String get deliveredTo => getContentValueFromKey(294);

  String get invoiceNo => getContentValueFromKey(295);

  String get invoiceDate => getContentValueFromKey(296);

  String get orderedDate => getContentValueFromKey(297);

  String get invoiceCapital => getContentValueFromKey(298);

  String get product => getContentValueFromKey(299);

  String get price => getContentValueFromKey(300);

  String get subTotal => getContentValueFromKey(301);

  String get paid => getContentValueFromKey(316);

  String get searchStores => getContentValueFromKey(357);

  String get nearest => getContentValueFromKey(358);

  String get rightNowStoreNotAvailable => getContentValueFromKey(359);

  String get products => getContentValueFromKey(360);

  String get itemsAdded => getContentValueFromKey(361);

  String get items => getContentValueFromKey(362);

  String get item => getContentValueFromKey(363);

  String get added => getContentValueFromKey(364);

  String get categoryFilter => getContentValueFromKey(365);

  String get apply => getContentValueFromKey(366);

  String get orderItems => getContentValueFromKey(367);

  String get productAmount => getContentValueFromKey(368);

  String get stores => getContentValueFromKey(369);

  String get closed => getContentValueFromKey(370);

  String get favouriteStore => getContentValueFromKey(371);

  String get rateStore => getContentValueFromKey(372);

  String get rateToStore => getContentValueFromKey(373);

  String get yourRatingToStore => getContentValueFromKey(374);

  String get pleaseAvoidSendingProhibitedItems => getContentValueFromKey(375);

  String get whatCanWeGetYou => getContentValueFromKey(376);

  String get openIn => getContentValueFromKey(377);

  String get min => getContentValueFromKey(378);

  String get goToStore => getContentValueFromKey(379);

  String get verify => getContentValueFromKey(380);

  String get verified => getContentValueFromKey(381);

  String get youMustVerifyAboveAll => getContentValueFromKey(382);

  String get verificationYouMustDo => getContentValueFromKey(383);

  String get documentVerification => getContentValueFromKey(384);

  String get uploadYourDocument => getContentValueFromKey(385);

  String get mobileOtp => getContentValueFromKey(386);

  String get verifyYourMobileNumber => getContentValueFromKey(387);

  String get emailOtp => getContentValueFromKey(388);

  String get veirfyYourEmailAddress => getContentValueFromKey(389);

  String get bankAddress => getContentValueFromKey(390);

  String get routingNumber => getContentValueFromKey(391);

  String get bankIban => getContentValueFromKey(392);

  String get bankSwift => getContentValueFromKey(393);

  String get mustSelectDate => getContentValueFromKey(394);

  String get filterBelowCount => getContentValueFromKey(395);

  String get viewAllOrders => getContentValueFromKey(396);

  String get todayOrder => getContentValueFromKey(397);

  String get remainingOrder => getContentValueFromKey(398);
  String get pickedUpOrder => getContentValueFromKey(10399);

  String get completedOrder => getContentValueFromKey(399);

  String get inProgressOrder => getContentValueFromKey(400);

  String get walletBalance => getContentValueFromKey(401);

  String get pendingWithdReq => getContentValueFromKey(402);

  String get completedWithReq => getContentValueFromKey(403);

  String get isPaymentCollected => getContentValueFromKey(404);

  String get request => getContentValueFromKey(405);

  String get addReview => getContentValueFromKey(406);

  String get yourExperience => getContentValueFromKey(407);

  String get pages => getContentValueFromKey(408);

  String get collectedAmount => getContentValueFromKey(409);

  String get reject => getContentValueFromKey(410);

  String get forKey => getContentValueFromKey(411);

  String get earnedRewards => getContentValueFromKey(412);

  String get referAndEarn => getContentValueFromKey(413);

  String get referralHistory => getContentValueFromKey(414);

  String get customerSupport => getContentValueFromKey(415);

  String get today => getContentValueFromKey(416);

  String get yesterday => getContentValueFromKey(417);

  String get thisWeek => getContentValueFromKey(418);

  String get thisMonth => getContentValueFromKey(419);

  String get thisYear => getContentValueFromKey(420);

  String get custom => getContentValueFromKey(421);

  String get orderFilter => getContentValueFromKey(422);

  String get pendingPickup => getContentValueFromKey(423);

  String get pendingDelivery => getContentValueFromKey(424);

  String get view => getContentValueFromKey(425);

  String get details => getContentValueFromKey(426);

  String get withdrawDetails => getContentValueFromKey(427);

  String get transactionId => getContentValueFromKey(428);

  String get via => getContentValueFromKey(429);

  String get createdDate => getContentValueFromKey(430);

  String get otherDetails => getContentValueFromKey(431);

  String get image => getContentValueFromKey(432);

  String get chatWithAdmin => getContentValueFromKey(433);

  String get insuranceCharge => getContentValueFromKey(434);

  String get addSupportTicket => getContentValueFromKey(435);

  String get message => getContentValueFromKey(436);

  String get supportType => getContentValueFromKey(437);

  String get uploadDetails => getContentValueFromKey(438);

  String get video => getContentValueFromKey(439);

  String get select => getContentValueFromKey(440);

  String get supportId => getContentValueFromKey(441);

  String get attachment => getContentValueFromKey(442);

  String get viewPhoto => getContentValueFromKey(443);

  String get viewVideo => getContentValueFromKey(444);

  String get resolutionDetails => getContentValueFromKey(445);

  String get completedOrders => getContentValueFromKey(446);

  String get userType => getContentValueFromKey(447);

  String get invalidPickupAddress => getContentValueFromKey(448);

  String get refusedBySender => getContentValueFromKey(449);

  String get invalidDeliveryAddress => getContentValueFromKey(450);

  String get exception => getContentValueFromKey(451);

  String get refusedByRecipient => getContentValueFromKey(452);

  String get home => getContentValueFromKey(453);

  String get work => getContentValueFromKey(454);

  String get selectAddressType => getContentValueFromKey(455);

  String get labels => getContentValueFromKey(456);

  String get pickupPersonName => getContentValueFromKey(457);

  String get pickupInstructions => getContentValueFromKey(458);

  String get deliveryPersonName => getContentValueFromKey(459);

  String get deliveryInstructions => getContentValueFromKey(460);

  String get insurance => getContentValueFromKey(461);

  String get addCourierInsurance => getContentValueFromKey(462);

  String get noThanksRisk => getContentValueFromKey(463);

  String get addressType => getContentValueFromKey(464);

  String get shippedVia => getContentValueFromKey(465);

  String get pleaseSelectReason => getContentValueFromKey(466);

  String get cancelAndReturn => getContentValueFromKey(467);

  String get rateUs => getContentValueFromKey(468);

  String get excellent => getContentValueFromKey(469);

  String get referDes1 => getContentValueFromKey(470);

  String get referDes2 => getContentValueFromKey(471);

  String get referShareTitle => getContentValueFromKey(472);

  String get shareDes1 => getContentValueFromKey(473);

  String get shareDes2 => getContentValueFromKey(474);

  String get shareDes3 => getContentValueFromKey(475);

  String get process => getContentValueFromKey(476);

  String get copy => getContentValueFromKey(477);

  String get copiedToClipboard => getContentValueFromKey(478);

  String get thisWayUup => getContentValueFromKey(479);

  String get thisWayUpDesc => getContentValueFromKey(480);

  String get doNotStack => getContentValueFromKey(481);

  String get doNotStackDesc => getContentValueFromKey(482);

  String get temperatureSensitive => getContentValueFromKey(483);

  String get temperatureSensitiveDesc => getContentValueFromKey(484);

  String get doNotHook => getContentValueFromKey(485);

  String get doNotHookDesc => getContentValueFromKey(486);

  String get explosiveMaterial => getContentValueFromKey(487);

  String get explosiveMaterialDesc => getContentValueFromKey(488);

  String get hazard => getContentValueFromKey(489);

  String get hazardDesc => getContentValueFromKey(490);

  String get bikeDelivery => getContentValueFromKey(491);

  String get bikeDeliveryDesc => getContentValueFromKey(492);

  String get keepDry => getContentValueFromKey(493);

  String get keepDryDesc => getContentValueFromKey(494);

  String get perishable => getContentValueFromKey(495);

  String get perishableDesc => getContentValueFromKey(496);

  String get recycle => getContentValueFromKey(497);

  String get recycleDesc => getContentValueFromKey(498);

  String get doNotOpenWithSharpObject => getContentValueFromKey(499);

  String get doNotOpenWithSharpObjectDesc => getContentValueFromKey(500);

  String get fragile => getContentValueFromKey(501);

  String get fragileDesc => getContentValueFromKey(502);

  String get parnerCode => getContentValueFromKey(503);

  String get shipped => getContentValueFromKey(504);

  String get approxParcelValue => getContentValueFromKey(505);

  String get reviewRoute => getContentValueFromKey(506);

  String get pickupDescription => getContentValueFromKey(507);

  String get viewMore => getContentValueFromKey(508);

  String get contactPersonName => getContentValueFromKey(509);

  String get information => getContentValueFromKey(510);

  String get instruction => getContentValueFromKey(511);

  String get supportType1 => getContentValueFromKey(512);

  String get supportType2 => getContentValueFromKey(513);

  String get supportType3 => getContentValueFromKey(514);

  String get supportType4 => getContentValueFromKey(515);

  String get insuranceAmountValidation => getContentValueFromKey(516);

  String get vehicleHistory => getContentValueFromKey(517);

  String get update => getContentValueFromKey(518);

  String get copiedToClipBoard => getContentValueFromKey(519);

  String get yourVehicle => getContentValueFromKey(520);

  String get noVehicleAdded => getContentValueFromKey(521);

  String get updateVehicle => getContentValueFromKey(522);

  String get vehicleInfo => getContentValueFromKey(523);

  String get addVehicle => getContentValueFromKey(524);

  String get model => getContentValueFromKey(525);

  String get color => getContentValueFromKey(526);

  String get yearOfManufacturing => getContentValueFromKey(527);

  String get vehicleIdentificationNumber => getContentValueFromKey(528);

  String get licensePlateNumber => getContentValueFromKey(529);

  String get currentMileage => getContentValueFromKey(530);

  String get fuelType => getContentValueFromKey(531);

  String get transmissionType => getContentValueFromKey(532);

  String get ownerName => getContentValueFromKey(533);

  String get registrationDate => getContentValueFromKey(534);

  String get ownerNumber => getContentValueFromKey(535);

  String get userid => getContentValueFromKey(536);

  String get active => getContentValueFromKey(537);

  String get inActive => getContentValueFromKey(538);

  String get startDate => getContentValueFromKey(539);

  String get endDate => getContentValueFromKey(540);

  String get clickHere => getContentValueFromKey(541);

  String get timeValidation => getContentValueFromKey(542);

  String get claimHistory => getContentValueFromKey(544);

  String get proofValue => getContentValueFromKey(545);

  String get trackinNo => getContentValueFromKey(546);

  String get ofApproxParcelValue => getContentValueFromKey(548);

  String get claimInsurance => getContentValueFromKey(550);

  String get fillTheDetailsForClaim => getContentValueFromKey(551);

  String get addAttachmentMsg => getContentValueFromKey(552);

  String get title => getContentValueFromKey(553);

  String get enterProofValue => getContentValueFromKey(554);

  String get selectedFiles => getContentValueFromKey(555);

  String get addProofs => getContentValueFromKey(556);

  String get claim => getContentValueFromKey(543);

  String get scheduleOrderTimeMsg => getContentValueFromKey(547);

  String get canOrderWithinHour => getContentValueFromKey(549);

  String get proofDetails => getContentValueFromKey(557);

  String get capacity => getContentValueFromKey(558);

  String get perKmCharge => getContentValueFromKey(559);

  String get enterProofDetails => getContentValueFromKey(560);

  String get approvedAmount => getContentValueFromKey(561);

  String get earlyDeliveryMsg => getContentValueFromKey(562);

  String get earlyPickupMsg => getContentValueFromKey(563);

  String get reschedule => getContentValueFromKey(564);

  String get rescheduleTitle => getContentValueFromKey(565);

  String get rescheduleMsg => getContentValueFromKey(566);

  String get offersAndBenefits => getContentValueFromKey(598);

  String get onThisOrder => getContentValueFromKey(599);

  String get moreCoupons => getContentValueFromKey(600);

  String get proof => getContentValueFromKey(601);

  String get proofDataValidation => getContentValueFromKey(602);

  String get couponList => getContentValueFromKey(603);

  String get expiresIn => getContentValueFromKey(604);

  String get days => getContentValueFromKey(605);

  String get hrs => getContentValueFromKey(606);

  String get mins => getContentValueFromKey(607);

  String get secs => getContentValueFromKey(608);

  String get couponApplied => getContentValueFromKey(609);

  String get confirmBid => getContentValueFromKey(576);

  String get saySomething => getContentValueFromKey(577);

  String get placeYourBid => getContentValueFromKey(578);

  String get noNotesAvailable => getContentValueFromKey(581);

  String get bidAmount => getContentValueFromKey(582);

  String get confirm => getContentValueFromKey(575);

  String get deliveryBid => getContentValueFromKey(579);

  String get acceptBid => getContentValueFromKey(567);

  String get viewAll => getContentValueFromKey(568);

  String get estimateAmount => getContentValueFromKey(569);

  String get decline => getContentValueFromKey(570);

  String get declineBidConfirm => getContentValueFromKey(571);

  String get cancelBid => getContentValueFromKey(572);

  String get withdrawBid => getContentValueFromKey(573);

  String get withdrawBidConfirm => getContentValueFromKey(574);

  String get bidFetchFailedMsg => getContentValueFromKey(583);

  String get bids => getContentValueFromKey(584);

  String get noBidsFound => getContentValueFromKey(585);

  String get bidRequest => getContentValueFromKey(586);

  String get acceptBidConfirm => getContentValueFromKey(587);

  String get close => getContentValueFromKey(588);

  String get orderAvailableForBidding => getContentValueFromKey(589);

  String get bidAvailableForCancel => getContentValueFromKey(590);

  String get bidAccepted => getContentValueFromKey(591);

  String get bidPlaced => getContentValueFromKey(592);

  String get newOrder => getContentValueFromKey(593);

  String get bidRejected => getContentValueFromKey(594);

  String get placeBid => getContentValueFromKey(595);

  String get totalAmount => getContentValueFromKey(596);

  String get youPlaced => getContentValueFromKey(597);
}

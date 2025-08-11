import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../delivery/screens/VerifyDeliveryPersonScreen.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/network/RestApis.dart';
import '../../delivery/fragment/DHomeFragment.dart';
import '../../extensions/app_button.dart';
import '../../extensions/common.dart';
import '../../extensions/confirmation_dialog.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../models/CityListModel.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';
import 'EmailVerificationScreen.dart';
import 'UserCitySelectScreen.dart';
import 'VerificationScreen.dart';

class VerificationListScreen extends StatefulWidget {
  final bool? isSignIn;

  VerificationListScreen({this.isSignIn = false});

  @override
  State<VerificationListScreen> createState() => _VerificationListScreenState();
}

class _VerificationListScreenState extends State<VerificationListScreen> {
  UserData? data;
  List<VerificationStep> verificationSteps = [];

  @override
  void initState() {
    super.initState();
    print("当前进入 verification_list_screen.dart 页面");
    getUserData();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  Future<void> getUserData() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) async {
      data = value;
      verificationSteps.clear();
      if (data!.emailVerifiedAt.isEmptyOrNull) {
        VerificationStatus status =
            data!.emailVerifiedAt.isEmptyOrNull ? VerificationStatus.pending : VerificationStatus.completed;
        verificationSteps.add(
          VerificationStep(
              title: language.emailOtp,
              image: Icons.email,
              description: language.veirfyYourEmailAddress,
              status: data!.emailVerifiedAt.isEmptyOrNull ? VerificationStatus.pending : VerificationStatus.completed,
              fun: () {
                if (status == VerificationStatus.pending) {
                  EmailVerificationScreen(
                    isSignIn: widget.isSignIn,
                  ).launch(context, pageRouteAnimation: PageRouteAnimation.Slide).then((value) => getUserData());
                }
              }),
        );
        // setState(() {});
      }

      if (data!.otpVerifyAt.isEmptyOrNull) {
        VerificationStatus status =
            data!.otpVerifyAt.isEmptyOrNull ? VerificationStatus.pending : VerificationStatus.completed;
        verificationSteps.add(
          VerificationStep(
              title: language.mobileOtp,
              description: language.verifyYourMobileNumber,
              image: Icons.phone,
              status: data!.otpVerifyAt.isEmptyOrNull ? VerificationStatus.pending : VerificationStatus.completed,
              fun: () {
                if (status == VerificationStatus.pending) {
                  VerificationScreen()
                      .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                      .then((value) => getUserData());
                }
              }),
        );
        // setState(() {});
      }
      if (data!.documentVerifiedAt.isEmptyOrNull && data?.userType.validate() == DELIVERY_MAN) {
        VerificationStatus status =
            data!.documentVerifiedAt.isEmptyOrNull ? VerificationStatus.pending : VerificationStatus.completed;
        verificationSteps.add(
          VerificationStep(
              title: language.documentVerification,
              description: language.uploadYourDocument,
              image: Icons.newspaper_rounded,
              status:
                  data!.documentVerifiedAt.isEmptyOrNull ? VerificationStatus.pending : VerificationStatus.completed,
              fun: () {
                if (status == VerificationStatus.pending) {
                  VerifyDeliveryPersonScreen()
                      .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                      .then((value) => getUserData());
                }
              }),
        );
      }
      appStore.setLoading(false);
      setState(() {});
      if (!verificationSteps.any((element) => element.status == VerificationStatus.pending)) {
        goToDashboard();
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.verificationYouMustDo,
      showBack: false,
      action: [
        IconButton(
          onPressed: () async {
            await showConfirmDialogCustom(
              context,
              primaryColor: ColorUtils.colorPrimary,
              title: language.logoutConfirmationMsg,
              positiveText: language.yes,
              negativeText: language.no,
              onAccept: (c) async {
                appStore.setLoading(true);
                try {
                  await logout(context, isVerification: true).then((value) async {
                    appStore.setLoading(false);
                  });
                } catch (e) {
                  print(e.toString());
                }
              },
            );
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
      ],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                20.height,
                ListView.builder(
                  itemCount: verificationSteps.length,
                  itemBuilder: (context, index) {
                    final step = verificationSteps[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(step.image),
                        title: Text(
                          step.title,
                          style: boldTextStyle(),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(step.description), getActionButton(step.status, step.fun)],
                        ),
                        // trailing: getActionButton(step.status, step.fun),
                      ),
                    );
                  },
                ).expand(),
                // Spacer(),
              ],
            ),
          ),
          Observer(
              builder: (context) =>
                  Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
        ],
      ),
    );
  }

  double calculateProgress() {
    final completedSteps = verificationSteps.where((step) => step.status == VerificationStatus.completed).length;
    return completedSteps / verificationSteps.length;
  }

  Future<void> goToDashboard() async {
    if (data!.countryId != null && data!.cityId != null) {
      await getCountryDetailApiCall(data!.countryId.validate());
      getCityDetailApiCall(data!.cityId.validate(), context);
    } else {
      if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
        if (getStringAsync(USER_TYPE) == CLIENT) {
          DashboardScreen().launch(context, isNewTask: true);
        } else {
          DHomeFragment().launch(context, isNewTask: true);
        }
      } else {
        UserCitySelectScreen().launch(context, isNewTask: true);
      }
    }
  }

  Widget getActionButton(VerificationStatus status, Function fun) {
    switch (status) {
      case VerificationStatus.completed:
        return commonAppButton(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.verified,
                    style: primaryTextStyle(
                      color: Colors.green.shade600,
                    )),
                4.width,
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 17,
                ),
              ],
            ),
            () => fun,
            borderColor: Colors.green.shade600);

      case VerificationStatus.pending:
        return commonAppButton(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.verify, style: primaryTextStyle(color: Colors.red)),
                Icon(Icons.arrow_right, color: Colors.red),
              ],
            ),
            () => fun(),
            borderColor: Colors.red);
      default:
        return ElevatedButton(
          onPressed: () {},
          child: Text(language.verify),
        );
    }
  }
}

enum VerificationStatus { pending, completed }

class VerificationStep {
  String title;
  String description;
  IconData image;
  VerificationStatus status;
  Function fun;

  VerificationStep(
      {required this.title, required this.image, required this.description, required this.status, required this.fun});
}

Widget commonAppButton(Widget child, Function() fn, {Color? borderColor}) {
  return AppButton(
    elevation: 0,
    height: 30,
    color: Colors.transparent,
    padding: EdgeInsets.symmetric(horizontal: 8),
    shapeBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(defaultRadius),
      side: BorderSide(color: borderColor ?? ColorUtils.colorPrimary),
    ),
    child: child,
    onTap: fn,
  );
}

getCountryDetailApiCall(int countryId) async {
  appStore.setLoading(true);
  await getCountryDetail(countryId).then((value) {
    appStore.setLoading(false);
    setValue(COUNTRY_DATA, value.data!.toJson());
  }).catchError((error) {
    appStore.setLoading(false);
  });
}

getCityDetailApiCall(int cityId, BuildContext context) async {
  appStore.setLoading(true);
  await getCityDetail(cityId).then((value) async {
    appStore.setLoading(false);
    await setValue(CITY_DATA, value.data!.toJson());
    if (CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate().isNotEmpty) {
      if (getStringAsync(USER_TYPE) == CLIENT) {
        DashboardScreen().launch(context, isNewTask: true);
      } else {
        // DeliveryDashBoard().launch(context, isNewTask: true);
        DHomeFragment().launch(context, isNewTask: true);
      }
    } else {
      UserCitySelectScreen().launch(context, isNewTask: true);
    }
  }).catchError((error) {
    appStore.setLoading(false);
    if (error.toString() == CITY_NOT_FOUND_EXCEPTION) {
      UserCitySelectScreen().launch(getContext, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
    }
  });
}

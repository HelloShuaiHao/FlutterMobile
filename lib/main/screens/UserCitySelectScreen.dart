import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/screens/VerificationListScreen.dart';
import '../../delivery/fragment/DHomeFragment.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/animatedList/animated_list_view.dart';
import '../../extensions/animatedList/animated_scroll_view.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../components/CommonScaffoldComponent.dart';
import '../models/CityListModel.dart';
import '../models/CountryListModel.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Images.dart';
import '../utils/dynamic_theme.dart';

class UserCitySelectScreen extends StatefulWidget {
  static String tag = '/UserCitySelectScreen';
  final bool isBack;
  final Function()? onUpdate;

  UserCitySelectScreen({this.isBack = false, this.onUpdate});

  @override
  UserCitySelectScreenState createState() => UserCitySelectScreenState();
}

class UserCitySelectScreenState extends State<UserCitySelectScreen> {
  TextEditingController searchCityController = TextEditingController();

  int? selectedCountry;
  int? selectedCity;

  List<CountryModel> countryData = [];
  List<CityModel> cityData = [];

  @override
  void initState() {
    super.initState();
    print("当前进入 UserCitySelectScreen");
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    getCountryApiCall();
  }

  getCountryApiCall() async {
    appStore.setLoading(true);
    await getCountryList().then((value) {
      appStore.setLoading(false);
      countryData = value.data!;
      selectedCountry = countryData[0].id!;
      countryData.forEach((element) {
        if (element.id! == getIntAsync(COUNTRY_ID)) {
          selectedCountry = getIntAsync(COUNTRY_ID);
        }
      });
      setValue(COUNTRY_ID, selectedCountry);
      getCountryDetailApiCall();
      getCityApiCall();
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  getCityApiCall({String? name}) async {
    appStore.setLoading(true);
    await getCityList(countryId: selectedCountry!, name: name).then((value) {
      appStore.setLoading(false);
      cityData.clear();
      cityData.addAll(value.data!);
      cityData.forEach((element) {
        if (element.id! == getIntAsync(CITY_ID)) {
          selectedCity = getIntAsync(CITY_ID);
        }
      });
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  getCountryDetailApiCall() async {
    await getCountryDetail(selectedCountry!).then((value) {
      setValue(COUNTRY_DATA, value.data!.toJson());
    }).catchError((error) {});
  }

  Future<void> updateCountryCityApiCall() async {
    appStore.setLoading(true);
    await updateUserStatus({"id": getIntAsync(USER_ID), "country_id": selectedCountry, "city_id": selectedCity})
        .then((value) {
      appStore.setLoading(false);
      if (widget.isBack) {
        finish(context);
        LiveStream().emit('UpdateOrderData');
        widget.onUpdate!.call();
      } else {
        if (getBoolAsync(OTP_VERIFIED) &&
            getBoolAsync(EMAIL_VERIFIED) &&
            (getBoolAsync(IS_VERIFIED_DELIVERY_MAN) || getStringAsync(USER_TYPE) == CLIENT)) {
          if (getStringAsync(USER_TYPE) == CLIENT) {
            DashboardScreen().launch(context, isNewTask: true);
          } else {
            DHomeFragment().launch(context, isNewTask: true);
          }
        } else
          VerificationListScreen().launch(context, isNewTask: true);
      }
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (v) async {
        if (selectedCity != null) {
          return Future(() => true);
        } else {
          toast(language.pleaseSelectCity);
          return Future(() => false);
        }
      },
      child: CommonScaffoldComponent(
        appBarTitle: language.selectRegion,
        showBack: widget.isBack,
        body: Observer(builder: (context) {
          return appStore.isLoading && countryData.isEmpty
              ? loaderWidget()
              : AnimatedScrollView(
                  padding: EdgeInsets.all(16),
                  children: [
                    16.height,
                    Image.asset(ic_select_region, height: 180, fit: BoxFit.contain).center(),
                    30.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 1, child: Text(language.country, style: boldTextStyle())),
                        16.width,
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: selectedCountry,
                            decoration: commonInputDecoration(),
                            items: countryData.map<DropdownMenuItem<int>>((item) {
                              return DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedCountry = value!;
                              setValue(COUNTRY_ID, selectedCountry);
                              getCountryDetailApiCall();
                              selectedCity = null;
                              getCityApiCall();
                              setState(() {});
                            },
                            validator: (value) {
                              if (selectedCountry == null) return language.fieldRequiredMsg;
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        Expanded(flex: 1, child: Text(language.city, style: boldTextStyle())),
                        16.width,
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            controller: searchCityController,
                            textFieldType: TextFieldType.OTHER,
                            decoration: commonInputDecoration(hintText: language.selectCity, suffixIcon: Icons.search),
                            onChanged: (value) {
                              getCityApiCall(name: value);
                            },
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    appStore.isLoading && cityData.isEmpty
                        ? loaderWidget()
                        : AnimatedListView(
                            itemCount: cityData.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            emptyWidget: emptyWidget(),
                            itemBuilder: (context, index) {
                              CityModel mData = cityData[index];
                              return InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  selectedCity = mData.id!;
                                  setValue(CITY_ID, selectedCity);
                                  setValue(CITY_DATA, mData.toJson());
                                  updateCountryCityApiCall();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(mData.name!,
                                          style: selectedCity == mData.id
                                              ? boldTextStyle(color: ColorUtils.colorPrimary)
                                              : primaryTextStyle()),
                                      selectedCity == mData.id
                                          ? Icon(Icons.check_circle, color: ColorUtils.colorPrimary)
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                );
        }),
      ),
    );
  }
}

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/utils/Widgets.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/decorations.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/models.dart';
import '../../main/screens/NotificationScreen.dart';
import '../../main/screens/UserCitySelectScreen.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';
import '../../user/components/FilterOrderComponent.dart';
import '../../user/fragment/AccountFragment.dart';
import '../../user/fragment/OrderFragment.dart';
import '../../user/screens/CreateOrderScreen.dart';
import '../../user/screens/WalletScreen.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  List<BottomNavigationBarItemModel> bottomNavBarItems = [];

  int currentIndex = 0;
  List widgetList = [
    OrderFragment(),
    AccountFragment(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    bottomNavBarItems.add(BottomNavigationBarItemModel(icon: Icons.shopping_bag, title: language.myOrders));
    bottomNavBarItems.add(BottomNavigationBarItemModel(icon: Icons.person, title: language.account));
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String getTitle() {
    String title = language.myOrders;
    if (currentIndex == 0) {
      title = '${language.hey} ${getStringAsync(NAME)} 👋';
    } else if (currentIndex == 1) {
      title = language.account;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      extendedBody: true,
      appBar: PreferredSize(
        preferredSize: Size(context.width(), 60),
        child: commonAppBarWidget(getTitle(),
            actions: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(defaultRadius), backgroundColor: Colors.white24),
                child: Row(
                  children: [
                    Icon(Ionicons.ios_location_outline, color: Colors.white, size: 18),
                    8.width,
                    Text(CityModel.fromJson(getJSONAsync(CITY_DATA)).name.validate(),
                        style: primaryTextStyle(color: white)),
                  ],
                ).onTap(() {
                  UserCitySelectScreen(
                    isBack: true,
                    onUpdate: () {
                      setState(() {});
                    },
                  ).launch(context);
                }, highlightColor: Colors.transparent, hoverColor: Colors.transparent, splashColor: Colors.transparent),
              ),
              4.width,
              4.width,
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                      alignment: AlignmentDirectional.center,
                      child: Icon(Ionicons.md_notifications_outline, color: Colors.white)),
                  if (appStore.allUnreadCount != 0)
                    Observer(builder: (context) {
                      return Positioned(
                        right: -5,
                        top: 8,
                        child: Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: Text(appStore.allUnreadCount.toString(),
                              style: boldTextStyle(size: appStore.allUnreadCount > 99 ? 10 : 10)),
                        ),
                      );
                    }),
                ],
              ).onTap(() {
                NotificationScreen().launch(context);
              },
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent).visible(currentIndex == 0),
              8.width,
              Stack(
                children: [
                  Align(
                      alignment: AlignmentDirectional.center,
                      child: Icon(Ionicons.md_options_outline, color: Colors.white)),
                  Observer(builder: (context) {
                    return Positioned(
                      right: 8,
                      top: 16,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      ),
                    ).visible(appStore.isFiltering);
                  }),
                ],
              ).withWidth(40).onTap(() {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius))),
                  builder: (context) {
                    return FilterOrderComponent();
                  },
                );
              },
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent).visible(currentIndex == 0),
            ],
            showBack: false),
      ),
      body: widgetList[currentIndex],
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: radius(40)),
        backgroundColor: appStore.availableBal >= 0 ? ColorUtils.colorPrimary : textSecondaryColorGlobal,
        child: Icon(AntDesign.plus, color: Colors.white),
        onPressed: () {
          if (appStore.availableBal >= 0) {
            CreateOrderScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
          } else {
            toast(language.balanceInsufficient);
            WalletScreen().launch(context);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: ColorUtils.bottomNavigationColor,
        icons: [AntDesign.home, FontAwesome.user_o],
        activeIndex: currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        activeColor: ColorUtils.colorPrimary,
        inactiveColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}

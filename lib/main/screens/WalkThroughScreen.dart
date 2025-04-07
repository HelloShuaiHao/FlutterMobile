import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/utils/dynamic_theme.dart';

import '../../extensions/colors.dart';
import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/models.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/DataProviders.dart';
import '../../main/utils/Widgets.dart';
import '../utils/DotsIndicator.dart';
import 'LoginScreen.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  List<WalkThroughItemModel> pages = getWalkThroughItems();
  PageController pageController = PageController();
  int currentPage = 0;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return CommonScaffoldComponent(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Text(language.skip, style: boldTextStyle(color: grey)).onTap(
            () async {
              await setValue(IS_FIRST_TIME, false);
              LoginScreen().launch(context,
                  isNewTask: true,
                  duration: Duration(milliseconds: 1000),
                  pageRouteAnimation: PageRouteAnimation.Scale);
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ).paddingOnly(bottom: 8, right: 16),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      ),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            children: List.generate(
              pages.length,
              (index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Image.asset(pages[index].image!,
                            width: context.width(), height: context.height() * 0.4, fit: BoxFit.cover)),
                    Text(pages[currentPage].title!, style: boldTextStyle(size: 24), textAlign: TextAlign.center)
                        .paddingOnly(left: 30, right: 30),
                    16.height,
                    Text(pages[currentPage].subTitle!, textAlign: TextAlign.center, style: secondaryTextStyle(size: 16))
                        .paddingOnly(left: 30, right: 30),
                  ],
                );
              },
            ),
            onPageChanged: (value) {
              currentPage = value;
              setState(() {});
            },
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.navigate_before, color: ColorUtils.colorPrimary, size: 30).onTap(() {
                      pageController.animateToPage(--currentPage,
                          duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
                    }).visible(currentPage != 0),
                    DotIndicator(
                      pages: pages,
                      pageController: pageController,
                      indicatorColor: ColorUtils.colorPrimary,
                    ),
                    currentPage != 2
                        ? Icon(Icons.navigate_next, color: ColorUtils.colorPrimary, size: 30).onTap(() {
                            pageController.animateToPage(++currentPage,
                                duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
                          })
                        : commonButton(
                            language.getStarted,
                            () async {
                              await setValue(IS_FIRST_TIME, false);
                              LoginScreen().launch(context,
                                  isNewTask: true,
                                  duration: Duration(milliseconds: 1000),
                                  pageRouteAnimation: PageRouteAnimation.Scale);
                            },
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

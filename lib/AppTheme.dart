//
// lightTheme() {
//   return ThemeData(
//     primarySwatch: createMaterialColor(colorPrimary),
//     primaryColor: colorPrimary,
//     scaffoldBackgroundColor: Colors.white,
//     fontFamily: GoogleFonts.lato().fontFamily,
//     iconTheme: IconThemeData(color: Colors.black),
//     dialogBackgroundColor: Colors.white,
//     unselectedWidgetColor: Colors.grey,
//     dividerColor: dividerColor,
//     cardColor: Colors.white,
//     tabBarTheme: TabBarTheme(labelColor: Colors.black),
//     appBarTheme: AppBarTheme(
//       color: colorPrimary,
//       elevation: 0,
//       systemOverlayStyle:
//           SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent),
//     ),
//     dialogTheme: DialogTheme(shape: dialogShape()),
//     bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
//     colorScheme: ColorScheme.light(
//       primary: colorPrimary,
//     ),
//   ).copyWith(
//     pageTransitionsTheme: PageTransitionsTheme(
//       builders: <TargetPlatform, PageTransitionsBuilder>{
//         TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
//         TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
//         TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//       },
//     ),
//   );
// }
//
// darkTheme() {
//   return ThemeData(
//     primarySwatch: createMaterialColor(colorPrimary),
//     primaryColor: colorPrimary,
//     scaffoldBackgroundColor: scaffoldColorDark,
//     fontFamily: GoogleFonts.lato().fontFamily,
//     iconTheme: IconThemeData(color: Colors.white),
//     dialogBackgroundColor: scaffoldSecondaryDark,
//     unselectedWidgetColor: Colors.white60,
//     dividerColor: Colors.white12,
//     cardColor: scaffoldSecondaryDark,
//     tabBarTheme: TabBarTheme(labelColor: Colors.white),
//     appBarTheme: AppBarTheme(
//       color: scaffoldSecondaryDark,
//       elevation: 0,
//       systemOverlayStyle: SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.light,
//         statusBarColor: Colors.transparent,
//       ),
//     ),
//     dialogTheme: DialogTheme(shape: dialogShape()),
//     snackBarTheme: SnackBarThemeData(backgroundColor: appButtonColorDark),
//     bottomSheetTheme: BottomSheetThemeData(backgroundColor: appButtonColorDark),
//     colorScheme: ColorScheme.dark(
//       primary: colorPrimary,
//     ),
//   ).copyWith(
//     pageTransitionsTheme: PageTransitionsTheme(
//       builders: <TargetPlatform, PageTransitionsBuilder>{
//         TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
//         TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
//         TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//       },
//     ),
//   );
// }

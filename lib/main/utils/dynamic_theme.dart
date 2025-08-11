import 'package:flutter/material.dart';

class ColorUtils {
  static Color? themeColor;
  static Color? _colorPrimary;
  static Color? _colorPrimaryLight;
  static Color? _borderColor;
  static Color? _bottomNavigationColor;
  static Color? _scaffoldSecondaryDark;
  static Color? _scaffoldColorDark;
  static Color? _scaffoldColorLight;
  static Color? _appButtonColorDark;
  static Color? _dividerColor;
  static Color? _cardDarkColor;
  ColorUtils({String primaryHex = "FF573391"}) {
    themeColor = colorFromHex(primaryHex);
    _colorPrimary = colorFromHex(primaryHex);

    _initializeColors();
  }
  _initializeColors() async {
    _colorPrimaryLight = Color(0xFFF5F5F5);
    _borderColor = Color(0xFFEAEAEA);
    _scaffoldSecondaryDark = Color(0xFF1E1E1E);
    _scaffoldColorDark = Color(0xFF090909);
    _scaffoldColorLight = Colors.white;
    _appButtonColorDark = Color(0xFF282828);
    _dividerColor = Color(0xFFD3D3D3);
    _cardDarkColor = Color(0xFF2F2F2F);
    bottomNavigationBarColor("#6b7cff");
  }

  static void updateColors(String color) {
    themeColor = colorFromHex(color);
    _colorPrimary = colorFromHex(color);
    _colorPrimaryLight = Color(0xFFF5F5F5);
    _borderColor = Color(0xFFEAEAEA);
    _scaffoldSecondaryDark = Color(0xFF1E1E1E);
    _scaffoldColorDark = Color(0xFF090909);
    _scaffoldColorLight = Colors.white;
    _appButtonColorDark = Color(0xFF282828);
    _dividerColor = Color(0xFFD3D3D3);
    _cardDarkColor = Color(0xFF2F2F2F);
    _bottomNavigationColor = bottomNavigationBarColor(color);
  }

  static Color colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    _colorPrimary = Color(int.parse(hexColor, radix: 16));
    return Color(int.parse(hexColor, radix: 16));
  }

  static Color bottomNavigationBarColor(String color) {
    String convertedColor = color.substring(1);
    Color colore = Color(int.parse('0xff$convertedColor'));
    double lightenPercent = 90.0; // Lighten by 20%

    Color hoverColor = lightenColor(colore, lightenPercent);

    print('Original Color: $color');
    print('Lightened Color: $hoverColor');
    return hoverColor;
  }

  static Color lightenColor(Color color, double percent) {
    final p = percent / 100;
    final r = (color.red + ((255 - color.red) * p)).round();
    final g = (color.green + ((255 - color.green) * p)).round();
    final b = (color.blue + ((255 - color.blue) * p)).round();

    return Color.fromRGBO(r, g, b, 1.0);
  }

  static Color get colorPrimary => _colorPrimary ?? Color(0xFF573391);
  static Color get colorPrimaryLight => _colorPrimaryLight ?? Color(0xFFF5F5F5);
  static Color get borderColor => _borderColor ?? Color(0xFFEAEAEA);
  static Color get bottomNavigationColor => _bottomNavigationColor ?? Color(0xFFD6CDE4);
  static Color get scaffoldSecondaryDark => _scaffoldSecondaryDark ?? Color(0xFF1E1E1E);
  static Color get scaffoldColorDark => _scaffoldColorDark ?? Color(0xFF090909);
  static Color get scaffoldColorLight => _scaffoldColorLight ?? Colors.white;
  static Color get appButtonColorDark => _appButtonColorDark ?? Color(0xFF282828);
  static Color get dividerColor => _dividerColor ?? Color(0xFFD3D3D3);
  static Color get cardDarkColor => _cardDarkColor ?? Colors.black;
}

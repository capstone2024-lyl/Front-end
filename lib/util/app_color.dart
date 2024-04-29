import 'dart:ui';

enum AppColor {
  backgroundColor(Color(0xffFAFAFA));

  final Color color;

  const AppColor(this.color);

  Color getColor() {
    return color;
  }
}
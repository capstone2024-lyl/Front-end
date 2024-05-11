import "dart:ui";

enum AppColor {
  cardColor,
  buttonColor,
  notSelectedColor,
  backgroundColor,
  progressWidgetBackground,
  testProgressIndicatorBorder,
  eiIndicatorColor,
  snIndicatorColor,
  tfIndicatorColor,
  jpIndicatorColor;


  Color get colors {
    switch(this) {
      case cardColor:
        return const Color(0xffFBF5EA);
      case buttonColor:
        return const Color(0xffFFBB38);
      case notSelectedColor:
        return const Color(0xff979797);
      case backgroundColor:
        return const Color(0xffFAFAFA);
      case progressWidgetBackground:
        return const Color(0xffDBDBDB);
      case testProgressIndicatorBorder:
        return const Color(0xffC7C6C5);
      case eiIndicatorColor:
        return const Color(0xffFD4F18);
      case snIndicatorColor:
        return const Color(0xff9FFF01);
      case tfIndicatorColor:
        return const Color(0xff64ECFF);
      case jpIndicatorColor:
        return const Color(0xffFF8BD1);

    }
  }
}

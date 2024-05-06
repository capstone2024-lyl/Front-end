import "dart:ui";

enum AppColor {
  cardColor,
  buttonColor,
  notSelectedColor,
  backgroundColor;


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
    }
  }
}

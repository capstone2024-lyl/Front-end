import "dart:ui";

enum AppColor {
  cardColor(
    Color(0xffFBF5EA),
  ),
  buttonColor(
    Color(0xffFFBB38),
  ),
  notSelectedColor(
    Color(0xff979797),
  ),
  backgroundColor(
    Color(0xffFAFAFA),
  );

  final Color color;

  const AppColor(this.color);

  Color getColor() {
    return color;
  }
}

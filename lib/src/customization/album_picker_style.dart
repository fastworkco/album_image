import 'package:flutter/material.dart';

class AlbumPickerStyle {
  /// dropdown appbar color
  final Color appBarColor;

  /// album text color
  final TextStyle albumTextStyle;

  /// album header text color
  final TextStyle albumHeaderTextStyle;

  /// album sub text color
  final TextStyle albumSubTextStyle;

  /// album trailing action textStyle
  final TextStyle trailingTextStyle;

  /// album background color
  final Color albumBackGroundColor;

  /// album divider color
  final Color albumDividerColor;

  /// gridView background color
  final Color listBackgroundColor;

  /// grid image backGround color
  final Color itemBackgroundColor;

  /// grid selected image backGround color
  final Color selectedItemBackgroundColor;

  /// album text color
  final double appBarHeight;

  /// album picker dropdown
  final AlbumPickerDropdownStyle albumPickerDropdownStyle;

  const AlbumPickerStyle({
    this.appBarHeight = 45,
    this.albumPickerDropdownStyle = const AlbumPickerDropdownStyle(),
    this.appBarColor = Colors.redAccent,
    this.albumTextStyle = const TextStyle(color: Colors.white, fontSize: 18),
    this.albumHeaderTextStyle =
        const TextStyle(color: Colors.white, fontSize: 18),
    this.albumSubTextStyle = const TextStyle(color: Colors.white, fontSize: 14),
    this.trailingTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
    this.albumBackGroundColor = const Color(0xFF333333),
    this.albumDividerColor = const Color(0xFF484848),
    this.listBackgroundColor = Colors.white,
    this.itemBackgroundColor = Colors.grey,
    this.selectedItemBackgroundColor = Colors.grey,
  });
}

class AlbumPickerDropdownStyle {
  final Color color;
  final double size;

  const AlbumPickerDropdownStyle({this.color = Colors.white, this.size = 18});
}

import 'dart:core';

enum FormatRule {
  ID_FORMAT,
  PASSWORD_FORMAT;

  RegExp get regex {
    switch(this) {
      case FormatRule.ID_FORMAT:
          return RegExp(r'^[a-zA-Z0-9]{6,12}$');
      case FormatRule.PASSWORD_FORMAT:
          return RegExp(r'^(?=.*[a-zA-z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,15}$');
    }
  }

}
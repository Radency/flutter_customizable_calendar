import 'package:flutter/material.dart';

enum EventLabel {
  none,
  personal,
  work,
  family,
  friends,
  holiday,
  birthday,
  travel,
  home,
  other,
}

extension EventLabelExtension on EventLabel {
  String get name {
    switch (this) {
      case EventLabel.none:
        return "None";
      case EventLabel.personal:
        return "Personal";
      case EventLabel.work:
        return "Work";
      case EventLabel.family:
        return "Family";
      case EventLabel.friends:
        return "Friends";
      case EventLabel.holiday:
        return "Holiday";
      case EventLabel.birthday:
        return "Birthday";
      case EventLabel.travel:
        return "Travel";
      case EventLabel.home:
        return "Home";
      case EventLabel.other:
        return "Other";
    }
  }

  Color get color {
    switch (this) {
      case EventLabel.none:
        return Colors.transparent;
      case EventLabel.personal:
        return Colors.blue;
      case EventLabel.work:
        return Colors.green;
      case EventLabel.family:
        return Colors.purple;
      case EventLabel.friends:
        return Colors.orange;
      case EventLabel.holiday:
        return Colors.red;
      case EventLabel.birthday:
        return Colors.pink;
      case EventLabel.travel:
        return Colors.yellow;
      case EventLabel.home:
        return Colors.brown;
      case EventLabel.other:
        return Colors.grey;
    }
  }
}

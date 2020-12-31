import 'package:flutter/cupertino.dart';

class Navigation with ChangeNotifier {
  int _index = 0;

  void setIndex(int v) {
    _index = v;
    notifyListeners();
  }

  int get index {
    return _index;
  }
}

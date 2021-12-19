import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  exShow(child) =>
      showDialog(context: this, builder: (BuildContext context) => child);
}

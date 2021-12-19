import 'package:flutter/material.dart';

class PageActions {
  final String name;
  final Icon icon;
  final String? page;
  final String? url;
  final bool isWebViev;
  final Color color;
  final int id;

  PageActions(
      {required this.id,
      required this.name,
      required this.icon,
      required this.page,
      required this.url,
      required this.isWebViev,
      required this.color});

  factory PageActions.fromMap(Map<String, dynamic> map) {
    return PageActions(
        name: map['name'],
        icon:
            Icon(IconData(int.parse(map['icon']), fontFamily: 'MaterialIcons')),
        page: map['page'],
        url: map['url'],
        isWebViev: map['isWebView'],
        color: Color(int.parse(map['color'])),
        id: map['id']);
  }
}

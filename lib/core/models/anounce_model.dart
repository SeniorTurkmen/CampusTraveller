import 'dart:math';

class AnounceModel {
  final String detail;
  final int id;
  final String? image;
  final String title;
  final DateTime date;
  final String anounceLink;

  AnounceModel(
      {required this.detail,
      required this.id,
      required this.image,
      required this.title,
      required this.date,
      required this.anounceLink});

  factory AnounceModel.fromMap(Map<String, dynamic> map) => AnounceModel(
      detail: map['detail'],
      id: map['id'],
      image: map['image'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      anounceLink: map['anounce_link']);

  Map<String, dynamic> get toMap => {
        'detail': detail,
        'id': Random().nextInt(999999),
        'date': DateTime.now().toIso8601String(),
        'image': image ??
            'http://owen.tuzitio.com/assets/camaleon_cms/image-not-found-4a963b95bf081c3ea02923dceaeb3f8085e1a654fc54840aac61a57a60903fef.png',
        'title': title,
        'anounce_link': anounceLink
      };
}

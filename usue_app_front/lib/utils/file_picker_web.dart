// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<String?> pickPngDataUrl() {
  final completer = Completer<String?>();
  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/png'
    ..click();
  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files == null || files.isEmpty) {
      completer.complete(null);
      return;
    }
    final file = files.first;
    if (file.type != 'image/png') {
      completer.completeError('Выберите PNG изображение');
      return;
    }
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onError.listen((error) => completer.completeError('Ошибка чтения файла'));
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as String?);
    });
  });
  return completer.future;
}

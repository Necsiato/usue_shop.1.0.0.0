// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:usue_app_front/controllers/auth_controller.dart';
import 'package:usue_app_front/main.dart';
import 'package:usue_app_front/services/auth_service.dart';

const List<int> _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x60, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE2,
  0x21, 0xBC, 0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  messenger.setMockMessageHandler('flutter/assets', (message) async {
    final key = utf8.decode(message!.buffer.asUint8List());
    if (key.endsWith('.png')) {
      return ByteData.view(Uint8List.fromList(_transparentImage).buffer);
    }
    if (key == 'AssetManifest.json') {
      final bytes = utf8.encode('{}');
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    if (key == 'AssetManifest.bin') {
      final codec = const StandardMessageCodec();
      return codec.encodeMessage(<String, List<String>>{});
    }
    if (key == 'FontManifest.json') {
      final bytes = utf8.encode('[]');
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    if (key == 'NOTICES') {
      final bytes = utf8.encode('');
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    return null;
  });

  testWidgets('Главная страница отображается', (tester) async {
    final auth = AuthController(AuthService());
    await tester.pumpWidget(UsueApp(authController: auth));
    await tester.pumpAndSettle();
    expect(find.text('Категории'), findsOneWidget);
  });
}

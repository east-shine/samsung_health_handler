import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:samsung_health_handler/samsung_health_handler.dart';

void main() {
  const channel = MethodChannel('samsung_health_handler');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((methodCall) async => '42');
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await SamsungHealthHandler.platformVersion, '42');
  // });
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qiscus_meet/qiscus_meet.dart';

void main() {
  const MethodChannel channel = MethodChannel('qiscus_meet');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await QiscusMeet.platformVersion, '42');
  });
}

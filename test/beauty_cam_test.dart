import 'package:beauty_cam/beauty_cam_method_channel.dart';
import 'package:beauty_cam/beauty_cam_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// class MockBeautyCamPlatform
//     with MockPlatformInterfaceMixin
//     implements BeautyCamPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

void main() {
  final BeautyCamPlatform initialPlatform = BeautyCamPlatform.instance;

  test('$MethodChannelBeautyCam is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBeautyCam>());
  });

  test('getPlatformVersion', () async {
    // BeautyCam beautyCamPlugin = BeautyCam();
    // MockBeautyCamPlatform fakePlatform = MockBeautyCamPlatform();
    // BeautyCamPlatform.instance = fakePlatform;

    // expect(await beautyCamPlugin.getPlatformVersion(), '42');
  });
}

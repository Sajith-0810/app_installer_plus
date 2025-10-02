// import 'package:flutter_test/flutter_test.dart';
// import 'package:app_installer_plus/app_installer_plus.dart';
// import 'package:app_installer_plus/app_installer_plus_platform_interface.dart';
// import 'package:app_installer_plus/app_installer_plus_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockAppInstallerPlusPlatform
//     with MockPlatformInterfaceMixin
//     implements AppInstallerPlusPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final AppInstallerPlusPlatform initialPlatform = AppInstallerPlusPlatform.instance;
//
//   test('$MethodChannelAppInstallerPlus is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelAppInstallerPlus>());
//   });
//
//   test('getPlatformVersion', () async {
//     AppInstallerPlus appInstallerPlusPlugin = AppInstallerPlus();
//     MockAppInstallerPlusPlatform fakePlatform = MockAppInstallerPlusPlatform();
//     AppInstallerPlusPlatform.instance = fakePlatform;
//
//     expect(await appInstallerPlusPlugin.getPlatformVersion(), '42');
//   });
// }

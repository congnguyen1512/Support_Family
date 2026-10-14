import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:family_guard/core/network/api_constants.dart';

class ApiBaseUrlResolver {
  const ApiBaseUrlResolver();

  Future<String> resolve() async {
    const definedBaseUrl = String.fromEnvironment(
      ApiConstants.baseUrlDefineKey,
      defaultValue: '',
    );
    final trimmedDefinedBaseUrl = definedBaseUrl.trim();
    if (trimmedDefinedBaseUrl.isNotEmpty) {
      return trimmedDefinedBaseUrl;
    }

    if (!Platform.isAndroid) {
      return ApiConstants.localhostBaseUrl;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.isPhysicalDevice) {
      return ApiConstants.androidUsbDebugBaseUrl;
    }

    return ApiConstants.androidEmulatorBaseUrl;
  }
}

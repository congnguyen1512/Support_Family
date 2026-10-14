import 'dart:io';

import 'package:family_guard/core/error/failures.dart';
import 'package:family_guard/core/network/api_exception.dart';

String mapNetworkErrorMessage(
  Object error, {
  String fallback = 'Co loi xay ra. Vui long thu lai.',
}) {
  if (error is ApiException) {
    return error.message;
  }

  if (error is Failure) {
    return error.message;
  }

  if (error is SocketException) {
    return const NetworkFailure().message;
  }

  if (error is FormatException) {
    return 'Du lieu tra ve khong hop le.';
  }

  return fallback;
}

class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Đăng nhập thất bại']);
}

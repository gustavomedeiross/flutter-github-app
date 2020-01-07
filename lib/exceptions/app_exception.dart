class AppException with Exception{
  final String message;

  AppException([this.message = '']);
}
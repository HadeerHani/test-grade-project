// TODO Implement this library.
class ApiConstants {
  static const String baseApiUrl = 'http://10.0.2.2:3000/api';

  static const String userBaseUrl = '$baseApiUrl/user';
  static const String categoriesBaseUrl = '$baseApiUrl/categories';

  static const String login = '$userBaseUrl/login';
  static const String register = '$userBaseUrl/register';
  static const String confirmEmail = '$userBaseUrl/confirmEmail';
  static const String categories = categoriesBaseUrl;
  static const String verifyIdentity = '$baseApiUrl/user/verify-identity';
}

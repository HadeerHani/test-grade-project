import 'package:flutter_dotenv/flutter_dotenv.dart';

// TODO Implement this library.
class ApiConstants {
  static String get baseApiUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000/api';

  static String get userBaseUrl => '$baseApiUrl/user';
  static String get categoriesBaseUrl => '$baseApiUrl/categories';

  static String get login => '$userBaseUrl/login';
  static String get register => '$userBaseUrl/register';
  static String get confirmEmail => '$userBaseUrl/confirmEmail';
  static String get categories => categoriesBaseUrl;
  static String get verifyIdentity => '$baseApiUrl/user/verify-identity';
  static String get tasks => '$baseApiUrl/tasks';
  static String get customerTasks => '$tasks/customer';
  static String get workerTasks => '$tasks/worker';
  static String get offers => '$baseApiUrl/offers';
  static String get messages => '$baseApiUrl/messages';
}

class ApiConstants {
  static const String baseUrl = 'https://school-management-backend-6k06.onrender.com/api/v1';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String students = '/students';
  static String studentById(int id) => '/students/$id';
  static const String attendance = '/attendance';
  static const String fees = '/fees';
  static const String exams = '/exams';
  static const String notices = '/notices';
}


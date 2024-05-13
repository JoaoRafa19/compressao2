class Env {
  static const backendBaseUrl =
      String.fromEnvironment('BACKEND_BASE_URL', defaultValue: "");
  static const token = String.fromEnvironment('TOKEN');
}

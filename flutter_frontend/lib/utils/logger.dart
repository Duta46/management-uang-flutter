class Logger {
  static void debug(String message, {String? tag}) {
    String logMessage = tag != null ? '[$tag] $message' : message;
    print('DEBUG: $logMessage');
  }

  static void info(String message, {String? tag}) {
    String logMessage = tag != null ? '[$tag] $message' : message;
    print('INFO: $logMessage');
  }

  static void warning(String message, {String? tag}) {
    String logMessage = tag != null ? '[$tag] $message' : message;
    print('WARNING: $logMessage');
  }

  static void error(String message, {String? tag, StackTrace? stackTrace}) {
    String logMessage = tag != null ? '[$tag] $message' : message;
    print('ERROR: $logMessage');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }

  static void network(String message, {String? tag}) {
    String logMessage = tag != null ? '[$tag] $message' : message;
    print('NETWORK: $logMessage');
  }

  static void api(String message, {String? tag}) {
    String logMessage = tag != null ? '[$tag] $message' : message;
    print('API: $logMessage');
  }
}
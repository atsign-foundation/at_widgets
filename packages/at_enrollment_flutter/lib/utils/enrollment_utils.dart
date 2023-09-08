class EnrollmentUtil {
  /// input -> {'wavi': 'rw'}
  /// return -> 'wavi : rw'
  static String enrollmentTypeToWord(Map<String, dynamic> namespace) {
    String namespaceAccessType = '';
    for (var key in namespace.entries) {
      namespaceAccessType += '${key.key} : ';
      namespaceAccessType += getAccessType(key.value);
    }
    return namespaceAccessType;
  }

  static String getAccessType(String type) {
    if (type == 'rw') {
      return 'read and write';
    } else {
      return 'read';
    }
  }
}

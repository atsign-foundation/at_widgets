class EnrollmentUtil {
  /// input -> {'wavi': 'rw'}
  /// return -> 'wavi : rw'
  static String enrollmentTypeToWord(Map<String, dynamic> namespace) {
    String namespaceAccessType = '';
    for (var key in namespace.entries) {
      namespaceAccessType += '${key.key} : ';
      namespaceAccessType += key.value;
    }
    return namespaceAccessType;
  }
}

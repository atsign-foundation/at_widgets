class EnrollmentConfig {
  String namespace;
  String rootDomain;

  EnrollmentConfig({
    required this.namespace,
    this.rootDomain = 'root.atsign.org',
  });
}

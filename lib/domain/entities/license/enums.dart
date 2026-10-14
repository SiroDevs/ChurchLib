/// What the app should do right now.
enum LicenseStatus {
  checking,
  unactivated,
  trial,
  expired,
  licensed,
  revoked,
  clockError,
  notConfigured,
  developer;

  bool get allowsUse =>
      this == LicenseStatus.trial ||
      this == LicenseStatus.licensed ||
      this == LicenseStatus.developer;
}

/// The status written inside a signed token by the server.
enum TokenStatus { trial, expired, licensed, revoked }

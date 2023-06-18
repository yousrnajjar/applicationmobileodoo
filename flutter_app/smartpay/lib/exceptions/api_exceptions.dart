class OdooSessionExpiredException implements Exception {
  final String message;
  OdooSessionExpiredException(this.message);

  @override
  String toString() => 'OdooSessionExpiredException: $message';
}

class OdooAuthentificationError implements Exception {
  final String message;
  OdooAuthentificationError(this.message);
  @override
  String toString() => 'OdooSessionConfirmTokenException: $message';
}

class OdooSessionInvalidTokenException implements Exception {
  final String message;
  OdooSessionInvalidTokenException(this.message);
  @override
  String toString() => 'OdooSessionInvalidTokenException: $message';
}

class OdooErrorException implements Exception {
  final int code;
  final String errorType;
  final String message;
  OdooErrorException(this.errorType, this.message, this.code);

  @override
  String toString() => '$code - OdooErrorException:  $errorType - $message';
}

class OdooValidationError extends OdooErrorException {
  OdooValidationError(super.errorType, super.message, super.code);

  @override
  String toString() => '$code - Odoo Validation error:  $errorType - $message';
}


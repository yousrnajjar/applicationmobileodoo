
class NoExpenseSelectedException implements Exception {
  final String message;
  NoExpenseSelectedException(this.message);

  @override
  String toString() => 'NoExpenseSelectedException: $message';
}

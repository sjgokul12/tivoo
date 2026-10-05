abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _phone = RegExp(r'^\+?\d{10,13}$');

  static String? phoneOrEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your mobile number or email';
    if (!_email.hasMatch(v) && !_phone.hasMatch(v.replaceAll(' ', ''))) {
      return 'Enter a valid mobile number or email';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

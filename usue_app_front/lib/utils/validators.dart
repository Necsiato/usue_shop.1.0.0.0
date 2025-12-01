class Validators {
  static final RegExp _loginRegExp = RegExp(r'^[a-zA-Z0-9_.-]+$');
  static final RegExp _emailRegExp =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? login(String? value, {bool allowEmpty = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return allowEmpty ? null : 'Введите логин';
    }
    if (v.length < 3) return 'Минимум 3 символа';
    if (!_loginRegExp.hasMatch(v)) {
      return 'Разрешены буквы, цифры, ._-';
    }
    return null;
  }

  static String? password(String? value, {bool allowEmpty = false}) {
    final v = value ?? '';
    if (v.isEmpty) {
      return allowEmpty ? null : 'Введите пароль';
    }
    if (v.length < 6) return 'Минимум 6 символов';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasDigit = RegExp(r'[0-9]').hasMatch(v);
    if (!hasLetter || !hasDigit) {
      return 'Нужны буквы и цифры';
    }
    return null;
  }

  static String? email(String? value, {bool allowEmpty = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return allowEmpty ? null : 'Введите email';
    }
    if (!_emailRegExp.hasMatch(v)) return 'Некорректный email';
    return null;
  }

  static String? phone(String? value, {bool allowEmpty = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return allowEmpty ? null : 'Введите телефон';
    }
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Минимум 10 цифр';
    return null;
  }
}

import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.simpleCurrency(
  locale: 'ru_RU',
  name: 'RUB',
  decimalDigits: 0,
);

String formatCurrency(num value) => _currencyFormatter.format(value);

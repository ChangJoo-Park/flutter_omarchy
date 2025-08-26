// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
// Ported to Dart by OpenCode

/// A class representing a number in the calculator engine.
/// This is a port of the Number class from the Microsoft Calculator.
class Number {
  /// Creates a new Number with default values (zero).
  Number() : _sign = 0, _exp = 0, _mantissa = [];

  /// Creates a new Number with the specified sign, exponent, and mantissa.
  Number.fromComponents(this._sign, this._exp, this._mantissa);

  /// Creates a copy of another Number.
  Number.from(Number other)
    : _sign = other._sign,
      _exp = other._exp,
      _mantissa = List<int>.from(other._mantissa);

  /// The sign of the number (-1, 0, or 1).
  int _sign;

  /// The exponent of the number.
  int _exp;

  /// The mantissa of the number as a list of 32-bit integers.
  List<int> _mantissa;

  /// Gets the sign of the number.
  int get sign => _sign;

  /// Gets the exponent of the number.
  int get exp => _exp;

  /// Gets the mantissa of the number.
  List<int> get mantissa => _mantissa;

  /// Sets the sign of the number.
  set sign(int value) => _sign = value;

  /// Sets the exponent of the number.
  set exp(int value) => _exp = value;

  /// Sets the mantissa of the number.
  set mantissa(List<int> value) => _mantissa = value;

  /// Checks if the number is zero.
  bool isZero() => _sign == 0;

  /// Creates a copy of this Number.
  Number clone() => Number.from(this);

  @override
  String toString() {
    if (isZero()) {
      return '0';
    }

    final signStr = _sign < 0 ? '-' : '';
    final mantissaStr = _mantissa.join(',');

    return '$signStr[$mantissaStr]e$_exp';
  }
}


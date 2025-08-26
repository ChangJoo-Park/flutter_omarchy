// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
// Ported to Dart by OpenCode

import 'rational.dart';

/// Space to hold enough digits for a quadword binary number (64) plus digit separator strings for that number (20)
const int maxStrLen = 84;

/// A class representing a number section in the calculator input.
class CalcNumSec {
  /// Creates a new CalcNumSec with default values.
  CalcNumSec() : value = '', _isNegative = false;

  /// Clears the number section.
  void clear() {
    value = '';
    _isNegative = false;
  }

  /// Checks if the number section is empty.
  bool isEmpty() {
    return value.isEmpty;
  }

  /// Gets whether the number section is negative.
  bool isNegative() {
    return _isNegative;
  }

  /// Sets whether the number section is negative.
  void setNegative(bool isNegative) {
    _isNegative = isNegative;
  }

  /// The string value of the number section.
  String value;

  /// Whether the number section is negative.
  bool _isNegative;
}

/// A class representing the calculator input.
class CalcInput {
  /// Creates a new CalcInput with default values.
  CalcInput() : this.withDecimalSymbol('.');

  /// Creates a new CalcInput with the specified decimal symbol.
  CalcInput.withDecimalSymbol(this._decSymbol)
    : _hasExponent = false,
      _hasDecimal = false,
      _decPtIndex = 0,
      _base = CalcNumSec(),
      _exponent = CalcNumSec();

  /// Clears the calculator input.
  void clear() {
    _hasExponent = false;
    _hasDecimal = false;
    _decPtIndex = 0;
    _base.clear();
    _exponent.clear();
  }

  /// Tries to toggle the sign of the calculator input.
  bool tryToggleSign(bool isIntegerMode, String maxNumStr) {
    if (_hasExponent) {
      _exponent.setNegative(!_exponent.isNegative());
      return true;
    } else {
      _base.setNegative(!_base.isNegative());

      // Check if the number is within range
      if (!isIntegerMode) {
        return true;
      }

      // For integer mode, we need to check against maxNumStr
      final baseValue = _base.value;
      if (baseValue.isEmpty) {
        return true;
      }

      // Compare with maxNumStr
      if (baseValue.length < maxNumStr.length) {
        return true;
      }

      if (baseValue.length > maxNumStr.length) {
        return false;
      }

      return baseValue.compareTo(maxNumStr) <= 0;
    }
  }

  /// Tries to add a digit to the calculator input.
  bool tryAddDigit(
    int value,
    int radix,
    bool isIntegerMode,
    String maxNumStr,
    int wordBitWidth,
    int maxDigits,
  ) {
    // Convert digit to character
    String digitChar;
    if (value < 10) {
      digitChar = String.fromCharCode(value + 48); // '0' to '9'
    } else {
      digitChar = String.fromCharCode(value - 10 + 65); // 'A' to 'Z'
    }

    if (_hasExponent) {
      // Add to exponent
      if (_exponent.value.length >= maxDigits) {
        return false;
      }

      _exponent.value += digitChar;
      return true;
    } else {
      // Add to base
      if (_base.value.length >= maxDigits) {
        return false;
      }

      // If this is the first digit and it's 0, replace the existing string
      if (_base.value.isEmpty || (_base.value == '0' && !_hasDecimal)) {
        _base.value = digitChar;
      } else {
        _base.value += digitChar;
      }

      // Check if the number is within range for integer mode
      if (isIntegerMode) {
        final baseValue = _base.value;

        // Compare with maxNumStr
        if (baseValue.length < maxNumStr.length) {
          return true;
        }

        if (baseValue.length > maxNumStr.length) {
          // Remove the digit we just added
          _base.value = _base.value.substring(0, _base.value.length - 1);
          return false;
        }

        if (baseValue.compareTo(maxNumStr) > 0) {
          // Remove the digit we just added
          _base.value = _base.value.substring(0, _base.value.length - 1);
          return false;
        }
      }

      return true;
    }
  }

  /// Tries to add a decimal point to the calculator input.
  bool tryAddDecimalPt() {
    if (_hasExponent || _hasDecimal) {
      return false;
    }

    _hasDecimal = true;
    _decPtIndex = _base.value.length;

    // If the string is empty, add a leading zero
    if (_base.value.isEmpty) {
      _base.value = '0';
    }

    return true;
  }

  /// Checks if the calculator input has a decimal point.
  bool hasDecimalPt() {
    return _hasDecimal;
  }

  /// Tries to begin an exponent in the calculator input.
  bool tryBeginExponent() {
    if (_hasExponent) {
      return false;
    }

    _hasExponent = true;

    // If the base is empty, add a default value
    if (_base.value.isEmpty) {
      _base.value = '1';
    }

    return true;
  }

  /// Removes the last character from the calculator input.
  void backspace() {
    if (_hasExponent) {
      if (_exponent.value.isNotEmpty) {
        _exponent.value = _exponent.value.substring(
          0,
          _exponent.value.length - 1,
        );
      } else {
        _hasExponent = false;
      }
    } else {
      if (_base.value.isNotEmpty) {
        // Check if we're removing the decimal point
        if (_hasDecimal && _base.value.length == _decPtIndex + 1) {
          _hasDecimal = false;
        }

        _base.value = _base.value.substring(0, _base.value.length - 1);
      }
    }
  }

  /// Sets the decimal symbol for the calculator input.
  void setDecimalSymbol(String decSymbol) {
    _decSymbol = decSymbol;
  }

  /// Checks if the calculator input is empty.
  bool isEmpty() {
    return _base.isEmpty() && !_hasExponent;
  }

  /// Converts the calculator input to a string representation.
  String toStringRadix(int radix) {
    if (isEmpty()) {
      return '';
    }

    String result = _base.isNegative() ? '-' : '';

    // Add the base
    if (_hasDecimal) {
      final intPart = _base.value.substring(0, _decPtIndex);
      final fracPart = _base.value.substring(_decPtIndex);

      result += intPart + _decSymbol + fracPart;
    } else {
      result += _base.value;
    }

    // Add the exponent if present
    if (_hasExponent) {
      result += 'e';
      if (_exponent.isNegative()) {
        result += '-';
      }

      if (_exponent.value.isEmpty) {
        result += '0';
      } else {
        result += _exponent.value;
      }
    }

    return result;
  }

  /// Converts the calculator input to a Rational.
  Rational toRational(int radix, int precision) {
    if (isEmpty()) {
      return Rational();
    }

    // Parse the base
    String baseStr = _base.value;
    int sign = _base.isNegative() ? -1 : 1;

    // Handle decimal point
    int exponent = 0;
    if (_hasDecimal) {
      // Move the decimal point to the end
      exponent = -(_base.value.length - _decPtIndex);
      baseStr = baseStr.replaceAll('.', '');
    }

    // Parse the exponent
    if (_hasExponent) {
      int expValue = 0;
      if (_exponent.value.isNotEmpty) {
        expValue = int.parse(_exponent.value);
        if (_exponent.isNegative()) {
          expValue = -expValue;
        }
      }

      exponent += expValue;
    }

    // Convert the string to a number
    int value = 0;
    try {
      value = int.parse(baseStr, radix: radix);
    } catch (e) {
      // Handle parsing error
      return Rational();
    }

    // Create the rational number
    final result = Rational.fromInt(sign * value);

    // Apply the exponent
    if (exponent != 0) {
      final expRational = Rational.fromInt(radix).pow(exponent.abs());

      if (exponent > 0) {
        return result * expRational;
      } else {
        return result / expRational;
      }
    }

    return result;
  }

  /// Whether the calculator input has an exponent.
  bool _hasExponent;

  /// Whether the calculator input has a decimal point.
  bool _hasDecimal;

  /// The index of the decimal point in the base value.
  int _decPtIndex;

  /// The decimal symbol to use.
  String _decSymbol;

  /// The base part of the calculator input.
  CalcNumSec _base;

  /// The exponent part of the calculator input.
  CalcNumSec _exponent;
}

/// Extension method for Rational to add power function
extension RationalPower on Rational {
  /// Raises this rational number to the power of the given exponent.
  Rational pow(int exponent) {
    if (exponent == 0) {
      return Rational.fromInt(1);
    }

    if (exponent == 1) {
      return Rational.from(this);
    }

    if (exponent < 0) {
      // For negative exponents, calculate 1/(this^|exponent|)
      final inverted = Rational.fromInt(1) / this;
      return inverted.pow(-exponent);
    }

    // For positive exponents, use repeated multiplication
    Rational result = Rational.fromInt(1);
    Rational base = Rational.from(this);

    while (exponent > 0) {
      if (exponent % 2 == 1) {
        result = result * base;
      }

      base = base * base;
      exponent ~/= 2;
    }

    return result;
  }
}


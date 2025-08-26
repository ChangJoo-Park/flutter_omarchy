// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
// Ported to Dart by OpenCode

import 'number.dart';

/// Default Base/Radix to use for Rational calculations
/// RatPack calculations currently support up to Base64.
const int rationalBase = 10;

/// Default Precision to use for Rational calculations
const int rationalPrecision = 128;

/// Enum for number format
enum NumberFormat { float, scientific, engineering }

/// A class representing a rational number (p/q) in the calculator engine.
/// This is a port of the Rational class from the Microsoft Calculator.
class Rational {
  /// Creates a new Rational with default values (zero).
  Rational() : _p = Number(), _q = Number.fromComponents(1, 0, [1]);

  /// Creates a new Rational from a Number.
  Rational.fromNumber(Number n)
    : _p = n.clone(),
      _q = Number.fromComponents(1, 0, [1]);

  /// Creates a new Rational from a numerator and denominator.
  Rational.fromPQ(Number p, Number q) : _p = p.clone(), _q = q.clone();

  /// Creates a new Rational from an integer.
  Rational.fromInt(int i)
    : _p = Number.fromComponents(
        i < 0 ? -1 : (i > 0 ? 1 : 0),
        0,
        i.abs() > 0 ? [i.abs()] : [],
      ),
      _q = Number.fromComponents(1, 0, [1]);

  /// Creates a new Rational from an unsigned integer.
  Rational.fromUint(int ui)
    : _p = Number.fromComponents(ui > 0 ? 1 : 0, 0, ui > 0 ? [ui] : []),
      _q = Number.fromComponents(1, 0, [1]);

  /// Creates a new Rational from a 64-bit unsigned integer.
  Rational.fromUint64(int ui)
    : _p = Number.fromComponents(ui > 0 ? 1 : 0, 0, _uint64ToMantissa(ui)),
      _q = Number.fromComponents(1, 0, [1]);

  /// Creates a copy of another Rational.
  Rational.from(Rational other) : _p = other._p.clone(), _q = other._q.clone();

  /// The numerator of the rational number.
  Number _p;

  /// The denominator of the rational number.
  Number _q;

  /// Gets the numerator of the rational number.
  Number get p => _p;

  /// Gets the denominator of the rational number.
  Number get q => _q;

  /// Converts a 64-bit unsigned integer to a mantissa list.
  static List<int> _uint64ToMantissa(int ui) {
    if (ui == 0) return [];

    // Split into two 32-bit parts if needed
    if (ui > 0xFFFFFFFF) {
      return [ui & 0xFFFFFFFF, ui >> 32];
    } else {
      return [ui];
    }
  }

  /// Negates this rational number.
  Rational operator -() {
    final result = Rational.from(this);
    result._p.sign = -result._p.sign;
    return result;
  }

  /// Adds another rational number to this one.
  Rational operator +(Rational other) {
    // For a/b + c/d = (ad + bc)/bd
    final result = Rational();

    // Calculate ad
    final ad = _multiplyNumbers(_p, other._q);

    // Calculate bc
    final bc = _multiplyNumbers(other._p, _q);

    // Calculate ad + bc
    final sum = _addNumbers(ad, bc);

    // Calculate bd
    final bd = _multiplyNumbers(_q, other._q);

    result._p = sum;
    result._q = bd;

    // Simplify the result
    _simplify(result);

    return result;
  }

  /// Subtracts another rational number from this one.
  Rational operator -(Rational other) {
    return this + (-other);
  }

  /// Multiplies this rational number by another one.
  Rational operator *(Rational other) {
    // For a/b * c/d = (ac)/(bd)
    final result = Rational();

    // Calculate ac
    result._p = _multiplyNumbers(_p, other._p);

    // Calculate bd
    result._q = _multiplyNumbers(_q, other._q);

    // Simplify the result
    _simplify(result);

    return result;
  }

  /// Divides this rational number by another one.
  Rational operator /(Rational other) {
    // For (a/b) / (c/d) = (ad)/(bc)
    final result = Rational();

    // Calculate ad
    result._p = _multiplyNumbers(_p, other._q);

    // Calculate bc
    result._q = _multiplyNumbers(_q, other._p);

    // Adjust sign if denominator is negative
    if (result._q.sign < 0) {
      result._p.sign = -result._p.sign;
      result._q.sign = -result._q.sign;
    }

    // Simplify the result
    _simplify(result);

    return result;
  }

  /// Calculates the remainder when dividing this rational number by another one.
  Rational operator %(Rational other) {
    // a % b = a - (b * floor(a/b))
    final quotient = this / other;
    final floorQuotient = _floor(quotient);
    final product = other * floorQuotient;

    return this - product;
  }

  /// Performs a bitwise AND operation with another rational number.
  Rational operator &(Rational other) {
    final a = toUint64();
    final b = other.toUint64();
    return Rational.fromUint64(a & b);
  }

  /// Performs a bitwise OR operation with another rational number.
  Rational operator |(Rational other) {
    final a = toUint64();
    final b = other.toUint64();
    return Rational.fromUint64(a | b);
  }

  /// Performs a bitwise XOR operation with another rational number.
  Rational operator ^(Rational other) {
    final a = toUint64();
    final b = other.toUint64();
    return Rational.fromUint64(a ^ b);
  }

  /// Performs a left shift operation.
  Rational operator <<(Rational other) {
    final a = toUint64();
    final b = other.toUint64();
    return Rational.fromUint64(a << b);
  }

  /// Performs a right shift operation.
  Rational operator >>(Rational other) {
    final a = toUint64();
    final b = other.toUint64();
    return Rational.fromUint64(a >> b);
  }

  /// Checks if this rational number is equal to another one.
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Rational) return false;

    // Ensure both rationals are simplified
    final a = Rational.from(this);
    final b = Rational.from(other);
    _simplify(a);
    _simplify(b);

    // Compare numerators and denominators
    return _compareNumbers(a._p, b._p) == 0 && _compareNumbers(a._q, b._q) == 0;
  }

  @override
  int get hashCode => Object.hash(
    _p.sign,
    _p.exp,
    Object.hashAll(_p.mantissa),
    _q.sign,
    _q.exp,
    Object.hashAll(_q.mantissa),
  );

  /// Checks if this rational number is less than another one.
  bool operator <(Rational other) {
    // a/b < c/d if ad < bc
    final ad = _multiplyNumbers(_p, other._q);
    final bc = _multiplyNumbers(other._p, _q);

    return _compareNumbers(ad, bc) < 0;
  }

  /// Checks if this rational number is greater than another one.
  bool operator >(Rational other) {
    // a/b > c/d if ad > bc
    final ad = _multiplyNumbers(_p, other._q);
    final bc = _multiplyNumbers(other._p, _q);

    return _compareNumbers(ad, bc) > 0;
  }

  /// Checks if this rational number is less than or equal to another one.
  bool operator <=(Rational other) {
    return this < other || this == other;
  }

  /// Checks if this rational number is greater than or equal to another one.
  bool operator >=(Rational other) {
    return this > other || this == other;
  }

  /// Converts this rational number to a 64-bit unsigned integer.
  int toUint64() {
    // Simplify first
    final simplified = Rational.from(this);
    _simplify(simplified);

    // Calculate p/q as an integer
    if (simplified._p.isZero()) return 0;

    // If q is 1, just return p as an integer
    if (simplified._q.mantissa.length == 1 &&
        simplified._q.mantissa[0] == 1 &&
        simplified._q.exp == 0) {
      // Convert p to uint64
      int result = 0;
      final mantissa = simplified._p.mantissa;

      if (mantissa.length > 0) {
        result = mantissa[0];
        if (mantissa.length > 1) {
          result |= mantissa[1] << 32;
        }
      }

      return result;
    }

    // Otherwise, perform integer division
    // This is a simplified implementation
    return 0; // TODO: Implement proper integer division
  }

  /// Converts this rational number to a string representation.
  String toString({
    int radix = rationalBase,
    NumberFormat format = NumberFormat.float,
    int precision = rationalPrecision,
  }) {
    // Simplified implementation
    if (_p.isZero()) return '0';

    if (_q.mantissa.length == 1 && _q.mantissa[0] == 1 && _q.exp == 0) {
      // Integer case
      final sign = _p.sign < 0 ? '-' : '';
      return '$sign${_p.mantissa.join('')}';
    } else {
      // Fraction case
      final sign = _p.sign < 0 ? '-' : '';
      return '$sign${_p.mantissa.join('')}/${_q.mantissa.join('')}';
    }
  }

  /// Multiplies two Numbers.
  static Number _multiplyNumbers(Number a, Number b) {
    if (a.isZero() || b.isZero()) {
      return Number();
    }

    final result = Number();
    result.sign = a.sign * b.sign;
    result.exp = a.exp + b.exp;

    // Simplified multiplication
    if (a.mantissa.length == 1 && b.mantissa.length == 1) {
      final product = a.mantissa[0] * b.mantissa[0];
      if (product <= 0xFFFFFFFF) {
        result.mantissa = [product];
      } else {
        result.mantissa = [product & 0xFFFFFFFF, product >> 32];
      }
    } else {
      // For more complex cases, we'd need a more sophisticated algorithm
      // This is a placeholder
      result.mantissa = [1];
    }

    return result;
  }

  /// Adds two Numbers.
  static Number _addNumbers(Number a, Number b) {
    if (a.isZero()) return b.clone();
    if (b.isZero()) return a.clone();

    // Simplified addition
    final result = Number();

    // If signs are the same
    if (a.sign == b.sign) {
      result.sign = a.sign;

      // If exponents are the same
      if (a.exp == b.exp) {
        result.exp = a.exp;

        // Add mantissas
        if (a.mantissa.length == 1 && b.mantissa.length == 1) {
          final sum = a.mantissa[0] + b.mantissa[0];
          if (sum <= 0xFFFFFFFF) {
            result.mantissa = [sum];
          } else {
            result.mantissa = [sum & 0xFFFFFFFF, 1];
            result.exp += 1;
          }
        } else {
          // For more complex cases, we'd need a more sophisticated algorithm
          // This is a placeholder
          result.mantissa = [1];
        }
      } else {
        // Different exponents would require shifting
        // This is a placeholder
        result.mantissa = [1];
        result.exp = a.exp > b.exp ? a.exp : b.exp;
      }
    } else {
      // Different signs would require subtraction
      // This is a placeholder
      result.mantissa = [1];
      result.sign = a.sign;
      result.exp = a.exp;
    }

    return result;
  }

  /// Compares two Numbers.
  static int _compareNumbers(Number a, Number b) {
    // If signs are different
    if (a.sign != b.sign) {
      return a.sign > b.sign ? 1 : -1;
    }

    // If both are zero
    if (a.isZero() && b.isZero()) {
      return 0;
    }

    // If signs are the same, compare exponents
    if (a.exp != b.exp) {
      return a.sign * (a.exp > b.exp ? 1 : -1);
    }

    // If exponents are the same, compare mantissas
    // This is a simplified comparison
    if (a.mantissa.length != b.mantissa.length) {
      return a.sign * (a.mantissa.length > b.mantissa.length ? 1 : -1);
    }

    for (int i = a.mantissa.length - 1; i >= 0; i--) {
      if (a.mantissa[i] != b.mantissa[i]) {
        return a.sign * (a.mantissa[i] > b.mantissa[i] ? 1 : -1);
      }
    }

    return 0;
  }

  /// Simplifies a rational number by dividing both numerator and denominator by their GCD.
  static void _simplify(Rational r) {
    // If numerator is zero, set denominator to 1
    if (r._p.isZero()) {
      r._q = Number.fromComponents(1, 0, [1]);
      return;
    }

    // Ensure denominator is positive
    if (r._q.sign < 0) {
      r._p.sign = -r._p.sign;
      r._q.sign = -r._q.sign;
    }

    // Simplified GCD calculation and division
    // This is a placeholder for a more sophisticated implementation
  }

  /// Calculates the floor of a rational number.
  static Rational _floor(Rational r) {
    // Simplified floor implementation
    // For a/b, floor(a/b) = ⌊a/b⌋

    // If a/b is an integer, return it
    if (r._q.mantissa.length == 1 && r._q.mantissa[0] == 1 && r._q.exp == 0) {
      return r;
    }

    // Otherwise, calculate the integer part
    final result = Rational();

    // Simplified integer division
    // This is a placeholder
    result._p = Number.fromComponents(r._p.sign, 0, [1]);
    result._q = Number.fromComponents(1, 0, [1]);

    return result;
  }
}


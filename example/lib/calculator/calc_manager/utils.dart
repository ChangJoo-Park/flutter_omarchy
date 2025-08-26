// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
// Ported to Dart by OpenCode

import 'dart:math' as math;
import 'constants.dart';
import 'rational.dart';

/// Utility functions for the calculator engine
class CalcUtils {
  /// Converts a radix type to its numeric value
  static int radixFromRadixType(RadixType radixType) {
    switch (radixType) {
      case RadixType.decimal:
        return 10;
      case RadixType.hex:
        return 16;
      case RadixType.octal:
        return 8;
      case RadixType.binary:
        return 2;
      default:
        return 10;
    }
  }

  /// Gets the word bit width from a NumWidth
  static int wordBitWidthFromNumWidth(NumWidth numWidth) {
    switch (numWidth) {
      case NumWidth.qwordWidth:
        return 64;
      case NumWidth.dwordWidth:
        return 32;
      case NumWidth.wordWidth:
        return 16;
      case NumWidth.byteWidth:
        return 8;
      default:
        return 64;
    }
  }

  /// Calculates the quick log base 2 of a number
  static int quickLog2(int num) {
    if (num <= 0) {
      return 0;
    }
    
    return (math.log(num) / math.ln2).floor();
  }

  /// Groups digits according to the specified grouping
  static String groupDigits(String delimiter, List<int> grouping, String displayString, {bool isNumNegative = false}) {
    if (displayString.isEmpty) {
      return displayString;
    }
    
    // Handle negative sign
    String sign = '';
    String numberString = displayString;
    
    if (isNumNegative || displayString.startsWith('-')) {
      sign = '-';
      numberString = displayString.startsWith('-') ? displayString.substring(1) : displayString;
    }
    
    // Find decimal point
    int decimalPos = numberString.indexOf('.');
    String intPart = decimalPos >= 0 ? numberString.substring(0, decimalPos) : numberString;
    String fracPart = decimalPos >= 0 ? numberString.substring(decimalPos) : '';
    
    // Apply grouping to integer part
    String result = '';
    int currentPos = intPart.length;
    int groupIndex = 0;
    
    while (currentPos > 0) {
      int groupSize = grouping.isEmpty ? 3 : grouping[groupIndex % grouping.length];
      
      int start = math.max(0, currentPos - groupSize);
      String group = intPart.substring(start, currentPos);
      
      if (result.isNotEmpty) {
        result = group + delimiter + result;
      } else {
        result = group;
      }
      
      currentPos -= groupSize;
      groupIndex++;
    }
    
    return sign + result + fracPart;
  }

  /// Converts a digit grouping string to a list of grouping values
  static List<int> digitGroupingStringToGroupingVector(String groupingString) {
    if (groupingString.isEmpty) {
      return [3]; // Default grouping of 3
    }
    
    List<int> result = [];
    List<String> groups = groupingString.split(';');
    
    for (String group in groups) {
      int? value = int.tryParse(group);
      if (value != null && value > 0) {
        result.add(value);
      }
    }
    
    if (result.isEmpty) {
      return [3]; // Default grouping of 3
    }
    
    return result;
  }

  /// Checks if a number is invalid for the given parameters
  static bool isNumberInvalid(String numberString, int maxExp, int maxMantissa, int radix) {
    if (numberString.isEmpty) {
      return true;
    }
    
    // Check for decimal point and exponent
    int decimalPos = numberString.indexOf('.');
    int expPos = numberString.toLowerCase().indexOf('e');
    
    String mantissaStr;
    String expStr;
    
    if (expPos >= 0) {
      mantissaStr = numberString.substring(0, expPos);
      expStr = numberString.substring(expPos + 1);
    } else {
      mantissaStr = numberString;
      expStr = '';
    }
    
    // Remove decimal point from mantissa
    if (decimalPos >= 0 && decimalPos < mantissaStr.length) {
      mantissaStr = mantissaStr.substring(0, decimalPos) + mantissaStr.substring(decimalPos + 1);
    }
    
    // Check mantissa length
    if (mantissaStr.length > maxMantissa) {
      return true;
    }
    
    // Check exponent
    if (expStr.isNotEmpty) {
      int? exp = int.tryParse(expStr);
      if (exp == null || exp.abs() > maxExp) {
        return true;
      }
    }
    
    // Check if all characters are valid for the given radix
    for (int i = 0; i < mantissaStr.length; i++) {
      String digit = mantissaStr[i];
      if (digit == '-' || digit == '+') {
        if (i > 0) {
          return true; // Sign can only be at the beginning
        }
        continue;
      }
      
      int? value;
      if (digit.codeUnitAt(0) >= '0'.codeUnitAt(0) && digit.codeUnitAt(0) <= '9'.codeUnitAt(0)) {
        value = digit.codeUnitAt(0) - '0'.codeUnitAt(0);
      } else if (digit.codeUnitAt(0) >= 'a'.codeUnitAt(0) && digit.codeUnitAt(0) <= 'z'.codeUnitAt(0)) {
        value = digit.codeUnitAt(0) - 'a'.codeUnitAt(0) + 10;
      } else if (digit.codeUnitAt(0) >= 'A'.codeUnitAt(0) && digit.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
        value = digit.codeUnitAt(0) - 'A'.codeUnitAt(0) + 10;
      } else {
        return true; // Invalid character
      }
      
      if (value >= radix) {
        return true; // Digit too large for radix
      }
    }
    
    return false;
  }

  /// Truncates a rational number for integer math
  static Rational truncateNumForIntMath(Rational rat) {
    // For integer math, we just need to ensure the number is an integer
    // This is a simplified implementation
    final result = Rational.from(rat);
    
    // If the denominator is 1, it's already an integer
    if (result.q.mantissa.length == 1 && result.q.mantissa[0] == 1 && result.q.exp == 0) {
      return result;
    }
    
    // Otherwise, truncate to integer
    final intValue = result.toUint64();
    return Rational.fromUint64(intValue);
  }

  /// Generates a random number between 0 and 1
  static double generateRandomNumber() {
    return math.Random().nextDouble();
  }
}
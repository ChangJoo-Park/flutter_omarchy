// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
// Ported to Dart by OpenCode

/// Maximum depth for parentheses and precedence operations
const int maxPrecDepth = 25;

/// Enum for number width
enum NumWidth {
  /// Number width of 64 bits mode (default)
  qwordWidth,

  /// Number width of 32 bits mode
  dwordWidth,

  /// Number width of 16 bits mode
  wordWidth,

  /// Number width of 8 bits mode
  byteWidth,
}

/// Length of the NumWidth enum
const int numWidthLength = 4;

/// Enum for radix type
enum RadixType {
  /// Decimal (base 10)
  decimal,

  /// Hexadecimal (base 16)
  hex,

  /// Octal (base 8)
  octal,

  /// Binary (base 2)
  binary,
}

/// Enum for angle type
enum AngleType {
  /// Degrees
  degrees,

  /// Radians
  radians,

  /// Gradians
  gradians,
}

/// Operation codes for calculator commands
class OpCode {
  // Basic operations
  static const int add = 0x01;
  static const int subtract = 0x02;
  static const int multiply = 0x03;
  static const int divide = 0x04;
  static const int mod = 0x05;
  static const int percent = 0x06;
  static const int equals = 0x07;
  static const int clear = 0x08;
  static const int clearEntry = 0x09;
  static const int backspace = 0x0A;
  static const int negate = 0x0B;

  // Numeric input
  static const int digit0 = 0x10;
  static const int digit1 = 0x11;
  static const int digit2 = 0x12;
  static const int digit3 = 0x13;
  static const int digit4 = 0x14;
  static const int digit5 = 0x15;
  static const int digit6 = 0x16;
  static const int digit7 = 0x17;
  static const int digit8 = 0x18;
  static const int digit9 = 0x19;
  static const int decimalSeparator = 0x1A;

  // Scientific functions
  static const int sin = 0x20;
  static const int cos = 0x21;
  static const int tan = 0x22;
  static const int sinh = 0x23;
  static const int cosh = 0x24;
  static const int tanh = 0x25;
  static const int inv = 0x26;
  static const int ln = 0x27;
  static const int log = 0x28;
  static const int sqrt = 0x29;
  static const int square = 0x2A;
  static const int cuberoot = 0x2B;
  static const int cube = 0x2C;
  static const int pow = 0x2D;
  static const int powOf10 = 0x2E;
  static const int pi = 0x2F;

  // Memory operations
  static const int memoryStore = 0x30;
  static const int memoryRecall = 0x31;
  static const int memoryClear = 0x32;
  static const int memoryAdd = 0x33;
  static const int memorySubtract = 0x34;

  // Parentheses
  static const int openParenthesis = 0x40;
  static const int closeParenthesis = 0x41;

  // Bitwise operations
  static const int and = 0x50;
  static const int or = 0x51;
  static const int xor = 0x52;
  static const int not = 0x53;
  static const int shiftLeft = 0x54;
  static const int shiftRight = 0x55;

  // Radix and angle settings
  static const int degrees = 0x60;
  static const int radians = 0x61;
  static const int gradians = 0x62;
  static const int decimal = 0x63;
  static const int hex = 0x64;
  static const int octal = 0x65;
  static const int binary = 0x66;

  // Word size
  static const int qword = 0x70;
  static const int dword = 0x71;
  static const int word = 0x72;
  static const int byte = 0x73;
}

/// Error codes for calculator
class ErrorCode {
  static const int noError = 0;
  static const int divideByZero = 1;
  static const int domainError = 2;
  static const int overflow = 3;
  static const int invalidInput = 4;
  static const int memoryError = 5;
}


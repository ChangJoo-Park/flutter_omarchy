import 'package:example/calculator/calc_manager/calc_engine.dart';
import 'package:flutter/foundation.dart';

class CalculatorNotifier extends ChangeNotifier
    implements ICalcDisplay, IHistoryDisplay, IResourceProvider {
  late final engine = CalcEngine(
    integerMode: true,
    precedence: true,
    resourceProvider: this,
    historyDisplay: this,
    calcDisplay: this,
  );
  String _primaryDisplay = '';
  String get primaryDisplay => _primaryDisplay;

  String _expressionDisplay = '';
  String get expressionDisplay => _expressionDisplay;

  List<(String expression, String result)> _history = [];
  List<(String expression, String result)> get history => _history;

  @override
  void addHistoryItem(String expression, String result) {
    _history.add((expression, result));
    notifyListeners();
  }

  @override
  void announceOperator(String text) {
    // TODO: Audio?
  }

  @override
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  @override
  String getDecimalSeparator() {
    return '.';
  }

  @override
  String getDigitGroupingSeparator() {
    return '';
  }

  @override
  String getDigitGroupingString() {
    return '';
  }

  @override
  String getString(int id) {
    return '$id'; // TODO:
  }

  @override
  void setExpressionDisplay(String text) {
    _expressionDisplay = text;
    notifyListeners();
  }

  @override
  void setPrimaryDisplay(String text, {bool isError = false}) {
    _primaryDisplay = text;
    notifyListeners();
  }
}

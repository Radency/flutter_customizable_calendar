extension DoubleExtension on double {
  bool comparePrecision(double value, {double precision = 0.01}) {
    return (this - value) < precision;
  }
}
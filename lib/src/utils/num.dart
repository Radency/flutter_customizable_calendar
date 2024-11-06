extension NumExtension on num {
  bool comparePrecision(num value, {double precision = 0.01}) {
    return (this - value) < precision;
  }
}

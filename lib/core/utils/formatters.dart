/// Pure formatting helpers shared across features.
abstract final class Formatters {
  /// 8400 -> 8.4K, 1250000 -> 1.2M
  static String compact(int value) {
    if (value >= 1000000) return '${_trim(value / 1000000)}M';
    if (value >= 1000) return '${_trim(value / 1000)}K';
    return '$value';
  }

  /// 7558940 -> 7,558,940
  static String grouped(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 173s -> 02:53
  static String countdown(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// 18:43 -> 06:43 PM
  static String clock(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')}:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  static String _trim(double v) {
    final fixed = v.toStringAsFixed(1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }
}

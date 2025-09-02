import 'dart:developer' as developer;

/// Simple performance monitoring utility
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, Duration> _measurements = {};
  
  /// Start measuring a performance metric
  static void start(String label) {
    _startTimes[label] = DateTime.now();
    developer.log('🚀 Started: $label', name: 'Performance');
  }
  
  /// End measuring and log the duration
  static Duration end(String label) {
    final startTime = _startTimes[label];
    if (startTime == null) {
      developer.log('⚠️ No start time found for: $label', name: 'Performance');
      return Duration.zero;
    }
    
    final duration = DateTime.now().difference(startTime);
    _measurements[label] = duration;
    
    final durationMs = duration.inMilliseconds;
    final emoji = durationMs < 100 ? '⚡' : durationMs < 500 ? '🐌' : '🔥';
    
    developer.log('$emoji Completed: $label in ${durationMs}ms', name: 'Performance');
    
    _startTimes.remove(label);
    return duration;
  }
  
  /// Get the last measurement for a label
  static Duration? getMeasurement(String label) {
    return _measurements[label];
  }
  
  /// Clear all measurements
  static void clear() {
    _startTimes.clear();
    _measurements.clear();
  }
  
  /// Log a summary of all measurements
  static void logSummary() {
    if (_measurements.isEmpty) {
      developer.log('No measurements recorded', name: 'Performance');
      return;
    }
    
    developer.log('📊 Performance Summary:', name: 'Performance');
    _measurements.forEach((label, duration) {
      developer.log('  • $label: ${duration.inMilliseconds}ms', name: 'Performance');
    });
  }
}
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Manages API response caching with TTL (Time To Live) support
/// Prevents unnecessary API calls by serving fresh cached data
class CacheManager extends GetxService {
  final Map<String, CacheEntry> _cache = {};

  /// Default cache duration - 5 minutes
  static const Duration defaultCacheDuration = Duration(minutes: 5);

  /// Store data in cache with a specific key and optional custom TTL
  void set<T>(String key, T data, {Duration? ttl}) {
    final duration = ttl ?? defaultCacheDuration;
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: duration,
    );
    logger.d('💾 Cache SET: $key (TTL: ${duration.inMinutes}m)');
  }

  /// Retrieve data from cache if it exists and hasn't expired
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      logger.d('❌ Cache MISS: $key (not found)');
      return null;
    }

    if (entry.isExpired) {
      logger.d('⏰ Cache EXPIRED: $key');
      _cache.remove(key);
      return null;
    }

    final age = DateTime.now().difference(entry.timestamp);
    logger.d('✅ Cache HIT: $key (age: ${age.inSeconds}s)');
    return entry.data as T;
  }

  /// Check if cache contains fresh data for a key
  bool isFresh(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }

  /// Get the age of cached data in seconds
  int? getCacheAge(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    return DateTime.now().difference(entry.timestamp).inSeconds;
  }

  /// Clear specific cache entry
  void remove(String key) {
    _cache.remove(key);
    logger.d('🗑️ Cache REMOVE: $key');
  }

  /// Clear all cached data
  void clearAll() {
    _cache.clear();
    logger.d('🗑️ Cache CLEARED: All entries removed');
  }

  /// Clear only expired entries
  void clearExpired() {
    final keysToRemove = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (var key in keysToRemove) {
      _cache.remove(key);
    }
    
    logger.d('🗑️ Cache CLEANUP: Removed ${keysToRemove.length} expired entries');
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getStats() {
    final expired = _cache.values.where((e) => e.isExpired).length;
    final fresh = _cache.length - expired;
    
    return {
      'total': _cache.length,
      'fresh': fresh,
      'expired': expired,
      'keys': _cache.keys.toList(),
    };
  }
}

/// Internal cache entry model
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
  
  int get ageInSeconds => DateTime.now().difference(timestamp).inSeconds;
  int get remainingSeconds => ttl.inSeconds - ageInSeconds;
}

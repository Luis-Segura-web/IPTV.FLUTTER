import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CacheService {
  static Database? _database;
  static const String _dbName = 'iptv_cache.db';
  static const int _dbVersion = 1;

  static const String _cacheTable = 'cache';
  static const String _profileCacheTable = 'profile_cache';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_cacheTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_profileCacheTable (
        profile_id TEXT NOT NULL,
        cache_key TEXT NOT NULL,
        value TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        PRIMARY KEY (profile_id, cache_key)
      )
    ''');
  }

  Future<void> setCache(String key, dynamic value, {Duration? duration}) async {
    final db = await database;
    final expiresAt = DateTime.now().add(duration ?? const Duration(hours: 6));
    
    await db.insert(
      _cacheTable,
      {
        'key': key,
        'value': json.encode(value),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
        'expires_at': expiresAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<T?> getCache<T>(String key, T Function(dynamic) fromJson) async {
    final db = await database;
    final results = await db.query(
      _cacheTable,
      where: 'key = ? AND expires_at > ?',
      whereArgs: [key, DateTime.now().millisecondsSinceEpoch],
    );

    if (results.isEmpty) return null;

    try {
      final data = json.decode(results.first['value'] as String);
      return fromJson(data);
    } catch (e) {
      await deleteCache(key);
      return null;
    }
  }

  Future<void> setProfileCache(String profileId, String key, dynamic value, {Duration? duration}) async {
    final db = await database;
    final expiresAt = DateTime.now().add(duration ?? const Duration(hours: 6));
    
    await db.insert(
      _profileCacheTable,
      {
        'profile_id': profileId,
        'cache_key': key,
        'value': json.encode(value),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
        'expires_at': expiresAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<T?> getProfileCache<T>(String profileId, String key, T Function(dynamic) fromJson) async {
    final db = await database;
    final results = await db.query(
      _profileCacheTable,
      where: 'profile_id = ? AND cache_key = ? AND expires_at > ?',
      whereArgs: [profileId, key, DateTime.now().millisecondsSinceEpoch],
    );

    if (results.isEmpty) return null;

    try {
      final data = json.decode(results.first['value'] as String);
      return fromJson(data);
    } catch (e) {
      await deleteProfileCache(profileId, key);
      return null;
    }
  }

  Future<void> deleteCache(String key) async {
    final db = await database;
    await db.delete(_cacheTable, where: 'key = ?', whereArgs: [key]);
  }

  Future<void> deleteProfileCache(String profileId, String key) async {
    final db = await database;
    await db.delete(
      _profileCacheTable,
      where: 'profile_id = ? AND cache_key = ?',
      whereArgs: [profileId, key],
    );
  }

  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.delete(_cacheTable, where: 'expires_at <= ?', whereArgs: [now]);
    await db.delete(_profileCacheTable, where: 'expires_at <= ?', whereArgs: [now]);
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete(_cacheTable);
    await db.delete(_profileCacheTable);
  }

  Future<void> clearProfileCache(String profileId) async {
    final db = await database;
    await db.delete(_profileCacheTable, where: 'profile_id = ?', whereArgs: [profileId]);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
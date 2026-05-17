// DAO responsible for reading and saving local app settings per profile.
import 'package:sqflite/sqflite.dart';

import '../models/app_settings.dart';
import 'database_helper.dart';

class SettingsDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<AppSettings> getSettings() => getSettingsByUserId(1);

  Future<AppSettings> getSettingsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    await ensureDefaultSettingsForUser(userId);
    final rows = await db.query(
      'settings',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return AppSettings.fromMap(rows.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await updateSettingsByUserId(settings);
  }

  Future<void> updateSettingsByUserId(AppSettings settings) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppSettings> resetSettings() => resetSettingsByUserId(1);

  Future<AppSettings> resetSettingsByUserId(int userId) async {
    final settings = AppSettings(userId: userId);
    await updateSettingsByUserId(settings);
    return settings;
  }

  Future<void> ensureDefaultSettingsForUser(int userId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'settings',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return;
    }
    await db.insert('settings', AppSettings(userId: userId).toMap());
  }
}

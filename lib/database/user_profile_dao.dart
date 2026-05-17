// DAO for local user profiles.
import 'package:sqflite/sqflite.dart';

import '../models/user_profile.dart';
import 'database_helper.dart';

class UserProfileDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get _database => _databaseHelper.database;

  Future<int> insertUserProfile(UserProfile profile) async {
    final db = await _database;
    return db.transaction((txn) async {
      if (profile.isActive) {
        await txn.update('user_profiles', {'isActive': 0});
      }
      return txn.insert('user_profiles', profile.toMap());
    });
  }

  Future<List<UserProfile>> getAllProfiles() async {
    final db = await _database;
    final rows = await db.query(
      'user_profiles',
      orderBy: 'isActive DESC, createdAt ASC',
    );
    return rows.map(UserProfile.fromMap).toList();
  }

  Future<UserProfile?> getActiveProfile() async {
    final db = await _database;
    final rows = await db.query(
      'user_profiles',
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserProfile.fromMap(rows.first);
  }

  Future<UserProfile?> getProfileById(int id) async {
    final db = await _database;
    final rows = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserProfile.fromMap(rows.first);
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await _database;
    return db.update(
      'user_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteUserProfile(int id) async {
    final db = await _database;
    return db.delete('user_profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setActiveProfile(int id) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.update('user_profiles', {'isActive': 0});
      await txn.update(
        'user_profiles',
        {'isActive': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<bool> hasAnyProfile() async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM user_profiles',
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}

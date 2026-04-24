import 'package:food_snap/core/constants/app_constants.dart';
import 'package:food_snap/core/errors/failures.dart';
import 'package:food_snap/data/models/food_record_model.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    _db = await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tableFoodRecords} (
            id TEXT PRIMARY KEY,
            image_uri TEXT NOT NULL,
            detected_food_name TEXT NOT NULL,
            cuisine_tags TEXT NOT NULL,
            confidence_percent REAL NOT NULL,
            calories REAL NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            fiber REAL,
            sugar REAL,
            sodium REAL,
            serving_size TEXT,
            raw_api_summary TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw const DatabaseFailure(message: 'Database is not initialized');
    }
    return db;
  }

  Future<void> insertRecord(FoodRecord record) async {
    try {
      await _database.insert(
        AppConstants.tableFoodRecords,
        FoodRecordModel.toDbMap(record),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to insert record: $e');
    }
  }

  Future<List<FoodRecord>> getAllRecords() async {
    try {
      final maps = await _database.query(
        AppConstants.tableFoodRecords,
        orderBy: 'created_at DESC',
      );
      return maps.map(FoodRecordModel.fromDbMap).toList();
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to get records: $e');
    }
  }

  Future<FoodRecord?> getRecordById(String id) async {
    try {
      final maps = await _database.query(
        AppConstants.tableFoodRecords,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return null;
      }
      return FoodRecordModel.fromDbMap(maps.first);
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to get record: $e');
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _database.delete(
        AppConstants.tableFoodRecords,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to delete record: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _database.delete(AppConstants.tableFoodRecords);
    } catch (e) {
      throw DatabaseFailure(message: 'Failed to clear records: $e');
    }
  }
}

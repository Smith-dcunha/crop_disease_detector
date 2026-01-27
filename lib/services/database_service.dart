import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_history.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static Database? _database;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableScans} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        severity TEXT NOT NULL,
        is_healthy INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        detected_at TEXT NOT NULL,
        additional_info TEXT
      )
    ''');
  }

  // Insert a scan
  Future<int> insertScan(ScanHistory scan) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableScans,
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all scans
  Future<List<ScanHistory>> getAllScans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableScans,
      orderBy: 'detected_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ScanHistory.fromMap(maps[i]);
    });
  }

  // Get scans by filter
  Future<List<ScanHistory>> getScansByFilter({
    bool? isHealthy,
    int? limit,
  }) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (isHealthy != null) {
      whereClause = 'is_healthy = ?';
      whereArgs = [isHealthy ? 1 : 0];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableScans,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'detected_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ScanHistory.fromMap(maps[i]);
    });
  }

  // Get scan by ID
  Future<ScanHistory?> getScanById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableScans,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ScanHistory.fromMap(maps.first);
  }

  // Delete a scan
  Future<int> deleteScan(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableScans,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all scans
  Future<int> deleteAllScans() async {
    final db = await database;
    return await db.delete(AppConstants.tableScans);
  }

  // Get scan count
  Future<int> getScanCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableScans}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get disease count (non-healthy)
  Future<int> getDiseaseCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableScans} WHERE is_healthy = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get healthy count
  Future<int> getHealthyCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableScans} WHERE is_healthy = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    final total = await getScanCount();
    final diseased = await getDiseaseCount();
    final healthy = await getHealthyCount();

    return {
      'total': total,
      'diseased': diseased,
      'healthy': healthy,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
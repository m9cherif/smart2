import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const int xpPerLevel = 100;

  static Database? _database;
  DatabaseFactory? _databaseFactory;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final factory = await _resolveDatabaseFactory();
    final path = await _resolveDatabasePath();

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await _createTaskTable(db);
          await _createLearningTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE tasks ADD COLUMN dueDate TEXT');
            await db.execute(
              "ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT 'Medium'",
            );
            await db.execute(
              'ALTER TABLE tasks ADD COLUMN completed INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (oldVersion < 3) {
            await _createLearningTables(db);
          }
          if (oldVersion < 4) {
            await db.execute(
              'ALTER TABLE student_progress ADD COLUMN grade INTEGER NOT NULL DEFAULT 7',
            );
          }
        },
      ),
    );
  }

  Future<void> _createTaskTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        dueDate TEXT,
        priority TEXT NOT NULL DEFAULT 'Medium',
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createLearningTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_progress(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        xp INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        revisionCount INTEGER NOT NULL DEFAULT 0,
        dictationCount INTEGER NOT NULL DEFAULT 0,
        grade INTEGER NOT NULL DEFAULT 7,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS revision_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionKey TEXT NOT NULL,
        subjectKey TEXT NOT NULL,
        prompt TEXT NOT NULL,
        expectedAnswer TEXT NOT NULL,
        userAnswer TEXT NOT NULL,
        isCorrect INTEGER NOT NULL DEFAULT 0,
        revealed INTEGER NOT NULL DEFAULT 0,
        xpEarned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS dictation_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sourceText TEXT NOT NULL,
        spokenText TEXT NOT NULL,
        accuracy REAL NOT NULL,
        matchedWordCount INTEGER NOT NULL DEFAULT 0,
        missedWords TEXT NOT NULL,
        extraWords TEXT NOT NULL,
        mismatchedPairs TEXT NOT NULL,
        xpEarned INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await _ensureStudentProgressRow(db);
  }

  Future<void> _ensureStudentProgressRow(DatabaseExecutor db) async {
    await db.rawInsert(
      '''
      INSERT OR IGNORE INTO student_progress(
        id,
        xp,
        level,
        revisionCount,
        dictationCount,
        updatedAt
      ) VALUES(1, 0, 1, 0, 0, ?)
      ''',
      <Object>[DateTime.now().toIso8601String()],
    );
  }

  Future<DatabaseFactory> _resolveDatabaseFactory() async {
    if (_databaseFactory != null) {
      return _databaseFactory!;
    }

    if (kIsWeb) {
      throw UnsupportedError(
        'Study Planner is not available on the web build yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        sqfliteFfiInit();
        _databaseFactory = databaseFactoryFfi;
        return _databaseFactory!;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _databaseFactory = databaseFactory;
        return _databaseFactory!;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Study Planner is not supported on this platform.',
        );
    }
  }

  Future<String> _resolveDatabasePath() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Study Planner is not available on the web build yet.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        final supportDirectory = await getApplicationSupportDirectory();
        return join(supportDirectory.path, 'planner.db');
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return join(await getDatabasesPath(), 'planner.db');
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Study Planner is not supported on this platform.',
        );
    }
  }

  Future<int> insertTask({
    required String title,
    required String priority,
    DateTime? dueDate,
  }) async {
    final db = await database;
    return db.insert('tasks', <String, Object?>{
      'title': title,
      'date': DateTime.now().toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'completed': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return db.query(
      'tasks',
      orderBy:
          'completed ASC, CASE WHEN dueDate IS NULL THEN 1 ELSE 0 END, dueDate ASC, date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTodayTasks() async {
    final db = await database;

    return db.query(
      'tasks',
      where: 'completed = 0',
      orderBy:
          "CASE priority WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END, dueDate ASC",
    );
  }

  Future<int> updateTaskStatus(int id, bool completed) async {
    final db = await database;
    return db.update(
      'tasks',
      <String, Object>{'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<int> deleteCompletedTasks() async {
    final db = await database;
    return db.delete('tasks', where: 'completed = 1');
  }

  Future<StudentProgress> getStudentProgress() async {
    final db = await database;
    return _readStudentProgress(db);
  }

  Future<ProgressAwardResult> recordRevisionAttempt({
    required String questionKey,
    required String subjectKey,
    required String prompt,
    required String expectedAnswer,
    required String userAnswer,
    required bool isCorrect,
    required bool revealed,
  }) async {
    final db = await database;

    return db.transaction((txn) async {
      await _ensureStudentProgressRow(txn);
      final previous = await _readStudentProgress(txn);
      final xpEarned = _revisionXp(isCorrect: isCorrect, revealed: revealed);

      await txn.insert('revision_attempts', <String, Object?>{
        'questionKey': questionKey,
        'subjectKey': subjectKey,
        'prompt': prompt,
        'expectedAnswer': expectedAnswer,
        'userAnswer': userAnswer,
        'isCorrect': isCorrect ? 1 : 0,
        'revealed': revealed ? 1 : 0,
        'xpEarned': xpEarned,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final updated = await _updateStudentProgress(
        txn,
        current: previous,
        xpDelta: xpEarned,
        revisionDelta: 1,
      );

      return ProgressAwardResult(
        progress: updated,
        xpEarned: xpEarned,
        leveledUp: updated.level > previous.level,
      );
    });
  }

  Future<ProgressAwardResult> recordDictationSession({
    required String sourceText,
    required String spokenText,
    required double accuracy,
    required int matchedWordCount,
    required List<String> missedWords,
    required List<String> extraWords,
    required List<String> mismatchedPairs,
  }) async {
    final db = await database;

    return db.transaction((txn) async {
      await _ensureStudentProgressRow(txn);
      final previous = await _readStudentProgress(txn);
      final xpEarned = _dictationXp(accuracy);

      await txn.insert('dictation_sessions', <String, Object?>{
        'sourceText': sourceText,
        'spokenText': spokenText,
        'accuracy': accuracy,
        'matchedWordCount': matchedWordCount,
        'missedWords': jsonEncode(missedWords),
        'extraWords': jsonEncode(extraWords),
        'mismatchedPairs': jsonEncode(mismatchedPairs),
        'xpEarned': xpEarned,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final updated = await _updateStudentProgress(
        txn,
        current: previous,
        xpDelta: xpEarned,
        dictationDelta: 1,
      );

      return ProgressAwardResult(
        progress: updated,
        xpEarned: xpEarned,
        leveledUp: updated.level > previous.level,
      );
    });
  }

  Future<ProgressAwardResult> recordQuizAnswer(bool isCorrect) async {
    final db = await database;

    return db.transaction((txn) async {
      await _ensureStudentProgressRow(txn);
      final previous = await _readStudentProgress(txn);
      final xpEarned = isCorrect ? 20 : 0;

      if (xpEarned == 0) {
        return ProgressAwardResult(
          progress: previous,
          xpEarned: 0,
          leveledUp: false,
        );
      }

      final updated = await _updateStudentProgress(
        txn,
        current: previous,
        xpDelta: xpEarned,
      );

      return ProgressAwardResult(
        progress: updated,
        xpEarned: xpEarned,
        leveledUp: updated.level > previous.level,
      );
    });
  }

  Future<StudentProgress> _readStudentProgress(DatabaseExecutor db) async {
    await _ensureStudentProgressRow(db);
    final rows = await db.query(
      'student_progress',
      where: 'id = ?',
      whereArgs: <Object>[1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return StudentProgress.initial();
    }

    return StudentProgress.fromMap(rows.first);
  }

  Future<StudentProgress> _updateStudentProgress(
    DatabaseExecutor db, {
    required StudentProgress current,
    required int xpDelta,
    int revisionDelta = 0,
    int dictationDelta = 0,
  }) async {
    final updated = current.copyWith(
      xp: current.xp + xpDelta,
      level: _levelForXp(current.xp + xpDelta),
      revisionCount: current.revisionCount + revisionDelta,
      dictationCount: current.dictationCount + dictationDelta,
      updatedAt: DateTime.now(),
    );

    await db.update(
      'student_progress',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: <Object>[1],
    );

    return updated;
  }

  /// Deletes the existing database file and clears all stored records.
  ///
  /// After calling this method the next time `database` getter is used the
  /// database will be recreated using the current schema. This is useful for
  /// debugging or resetting the application state entirely.
  Future<void> formatDatabase() async {
    // drop the file so subsequent openDatabase will call onCreate
    final factory = await _resolveDatabaseFactory();
    final path = await _resolveDatabasePath();
    await factory.deleteDatabase(path);
    _database = null;
    // reinitialize immediately so callers can continue using service without
    // having to await the getter elsewhere.
    await database;
  }

  int _revisionXp({required bool isCorrect, required bool revealed}) {
    if (revealed || !isCorrect) {
      return 0;
    }
    return 15;
  }

  int _dictationXp(double accuracy) {
    if (accuracy >= 95) {
      return 30;
    }
    if (accuracy >= 80) {
      return 24;
    }
    if (accuracy >= 60) {
      return 18;
    }
    if (accuracy >= 40) {
      return 12;
    }
    if (accuracy >= 20) {
      return 6;
    }
    return 3;
  }

  int _levelForXp(int xp) => (xp ~/ xpPerLevel) + 1;
}

class StudentProgress {
  const StudentProgress({
    required this.xp,
    required this.level,
    required this.revisionCount,
    required this.dictationCount,
    required this.updatedAt,
  });

  factory StudentProgress.initial() {
    return StudentProgress(
      xp: 0,
      level: 1,
      revisionCount: 0,
      dictationCount: 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory StudentProgress.fromMap(Map<String, Object?> map) {
    return StudentProgress(
      xp: _intValue(map['xp']),
      level: _intValue(map['level']),
      revisionCount: _intValue(map['revisionCount']),
      dictationCount: _intValue(map['dictationCount']),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final int xp;
  final int level;
  final int revisionCount;
  final int dictationCount;
  final DateTime updatedAt;

  int get xpIntoCurrentLevel => xp % DatabaseService.xpPerLevel;

  int get xpTargetForNextLevel => DatabaseService.xpPerLevel;

  int get activityCount => revisionCount + dictationCount;

  double get levelProgress => xpIntoCurrentLevel / xpTargetForNextLevel;

  Map<String, Object> toMap() {
    return <String, Object>{
      'xp': xp,
      'level': level,
      'revisionCount': revisionCount,
      'dictationCount': dictationCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StudentProgress copyWith({
    int? xp,
    int? level,
    int? revisionCount,
    int? dictationCount,
    DateTime? updatedAt,
  }) {
    return StudentProgress(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      revisionCount: revisionCount ?? this.revisionCount,
      dictationCount: dictationCount ?? this.dictationCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }
}

class ProgressAwardResult {
  const ProgressAwardResult({
    required this.progress,
    required this.xpEarned,
    required this.leveledUp,
  });

  final StudentProgress progress;
  final int xpEarned;
  final bool leveledUp;
}

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  // Mock storage for web
  final List<Transaction> _webTransactions = [];

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender TEXT,
            amount REAL,
            date TEXT,
            type INTEGER,
            source INTEGER,
            body TEXT,
            recipient TEXT,
            transactionId TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE transactions ADD COLUMN recipient TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE transactions ADD COLUMN transactionId TEXT');
        }
      },
    );
  }

  Future<int> insertTransaction(Transaction transaction) async {
    if (kIsWeb) {
      // Mock insert for web
      // Check for duplicates by transactionId if available, otherwise by body and date
      if (transaction.transactionId != null) {
        if (_webTransactions.any((t) => t.transactionId == transaction.transactionId)) {
          return 0; // Duplicate transaction ID
        }
      } else {
        if (_webTransactions.any((t) => t.body == transaction.body && t.date == transaction.date)) {
          return 0;
        }
      }
      _webTransactions.add(transaction);
      return 1;
    }

    final db = await database;
    
    // Check for duplicates by transactionId if available
    if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'transactionId = ?',
        whereArgs: [transaction.transactionId],
      );

      if (maps.isNotEmpty) {
        return 0; // Duplicate transaction ID
      }
    } else {
      // Fallback: check by body and date if no transactionId
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'body = ? AND date = ?',
        whereArgs: [transaction.body, transaction.date.toIso8601String()],
      );

      if (maps.isNotEmpty) {
        return 0; // Already exists
      }
    }

    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions() async {
    if (kIsWeb) {
      return List.from(_webTransactions)..sort((a, b) => b.date.compareTo(a.date));
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<void> clearTransactions() async {
    if (kIsWeb) {
      _webTransactions.clear();
      return;
    }
    final db = await database;
    await db.delete('transactions');
  }
}

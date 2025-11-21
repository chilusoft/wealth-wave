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
      version: 5,
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
            transactionId TEXT,
            isVerified INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE deleted_transactions(
            transactionId TEXT PRIMARY KEY
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
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE transactions ADD COLUMN isVerified INTEGER DEFAULT 0');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE deleted_transactions(
              transactionId TEXT PRIMARY KEY
            )
          ''');
        }
      },
    );
  }

  Future<int> insertTransaction(Transaction transaction) async {
    if (kIsWeb) {
      // Mock insert for web
      // Check for duplicates: transactionId + sender + recipient must all match
      if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty) {
        if (_webTransactions.any((t) => 
          t.transactionId == transaction.transactionId &&
          t.sender == transaction.sender &&
          t.recipient == transaction.recipient)) {
          return 0; // Duplicate
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
    
    // Check if transaction was previously deleted
    if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty) {
      final List<Map<String, dynamic>> deletedMaps = await db.query(
        'deleted_transactions',
        where: 'transactionId = ?',
        whereArgs: [transaction.transactionId],
      );
      
      if (deletedMaps.isNotEmpty) {
        return 0; // Previously deleted, do not re-insert
      }
    }
    
    // Enhanced duplicate detection: transactionId + sender + recipient
    if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty) {
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'transactionId = ? AND sender = ? AND (recipient = ? OR (recipient IS NULL AND ? IS NULL))',
        whereArgs: [
          transaction.transactionId,
          transaction.sender,
          transaction.recipient,
          transaction.recipient,
        ],
      );

      if (maps.isNotEmpty) {
        return 0; // Duplicate: same ID, sender, and recipient
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

  Future<void> markAsVerified(int id, bool verified) async {
    if (kIsWeb) {
      final index = _webTransactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        final t = _webTransactions[index];
        _webTransactions[index] = Transaction(
          id: t.id,
          sender: t.sender,
          amount: t.amount,
          date: t.date,
          type: t.type,
          source: t.source,
          body: t.body,
          recipient: t.recipient,
          transactionId: t.transactionId,
          isVerified: verified,
        );
      }
      return;
    }

    final db = await database;
    await db.update(
      'transactions',
      {'isVerified': verified ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<List<Transaction>>> getPossibleDuplicates() async {
    List<Transaction> allTransactions;
    
    if (kIsWeb) {
      allTransactions = _webTransactions;
    } else {
      allTransactions = await getTransactions();
    }

    // Group by transactionId, find groups with multiple entries
    Map<String, List<Transaction>> grouped = {};
    
    for (var transaction in allTransactions) {
      if (transaction.transactionId != null && transaction.transactionId!.isNotEmpty) {
        if (!grouped.containsKey(transaction.transactionId)) {
          grouped[transaction.transactionId!] = [];
        }
        grouped[transaction.transactionId!]!.add(transaction);
      }
    }

    // Filter to only groups with more than one transaction
    return grouped.values.where((group) => group.length > 1).toList();
  }

  Future<void> deleteTransaction(int id) async {
    if (kIsWeb) {
      _webTransactions.removeWhere((t) => t.id == id);
      return;
    }

    final db = await database;
    
    // Get transaction details before deleting to save ID
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      columns: ['transactionId'],
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final transactionId = maps.first['transactionId'] as String?;
      if (transactionId != null && transactionId.isNotEmpty) {
        // Record as deleted
        await db.insert(
          'deleted_transactions',
          {'transactionId': transactionId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
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

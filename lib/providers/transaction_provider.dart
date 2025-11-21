import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/sms_service.dart';
import '../services/parser_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  
  final DatabaseService _databaseService = DatabaseService();
  final SmsService _smsService = SmsService();
  final ParserService _parserService = ParserService();

  // Filters
  String _searchQuery = '';
  DateTimeRange? _dateRange;
  TransactionSource? _sourceFilter;

  List<Transaction> get transactions => _getFilteredTransactions();
  List<Transaction> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  DateTimeRange? get dateRange => _dateRange;
  TransactionSource? get sourceFilter => _sourceFilter;

  double get totalBalance {
    double balance = 0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.credit) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  double get totalIncome {
    return transactions
        .where((tx) => tx.type == TransactionType.credit)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return transactions
        .where((tx) => tx.type == TransactionType.debit)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  List<Transaction> _getFilteredTransactions() {
    var filtered = List<Transaction>.from(_transactions);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tx) {
        final query = _searchQuery.toLowerCase();
        return tx.sender.toLowerCase().contains(query) ||
               tx.body.toLowerCase().contains(query) ||
               (tx.recipient?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Date range filter
    if (_dateRange != null) {
      filtered = filtered.where((tx) {
        return tx.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
               tx.date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Source filter
    if (_sourceFilter != null) {
      filtered = filtered.where((tx) => tx.source == _sourceFilter).toList();
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void setSourceFilter(TransactionSource? source) {
    _sourceFilter = source;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _dateRange = null;
    _sourceFilter = null;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    _transactions = await _databaseService.getTransactions();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncSms() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Get messages
      final messages = await _smsService.getMessages();
      
      // 2. Parse and Save
      int newCount = 0;
      for (var msg in messages) {
        final transaction = _parserService.parseMessage(msg);
        if (transaction != null) {
          int result = await _databaseService.insertTransaction(transaction);
          if (result > 0) newCount++;
        }
      }
      
      print("Synced $newCount new transactions");

      // 3. Reload from DB
      await loadTransactions();
      
    } catch (e) {
      print("Error syncing SMS: $e");
      // Handle error (maybe show a snackbar via a callback or error state)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

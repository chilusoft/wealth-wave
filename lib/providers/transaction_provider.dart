import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/sms_service.dart';
import '../services/parser_service.dart';

enum VerificationFilter { all, verified, unverified }
enum BalanceMode { total, verified, unverified }

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
  String _recipientFilter = '';
  VerificationFilter _verificationFilter = VerificationFilter.all;
  BalanceMode _balanceMode = BalanceMode.total;

  List<Transaction> get transactions => _getFilteredTransactions();
  List<Transaction> get allTransactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  DateTimeRange? get dateRange => _dateRange;
  TransactionSource? get sourceFilter => _sourceFilter;
  String get recipientFilter => _recipientFilter;
  VerificationFilter get verificationFilter => _verificationFilter;
  BalanceMode get balanceMode => _balanceMode;

  double get totalBalance => _calculateBalance(transactions);
  double get verifiedBalance => _calculateBalance(
    _transactions.where((tx) => tx.isVerified).toList()
  );
  double get unverifiedBalance => _calculateBalance(
    _transactions.where((tx) => !tx.isVerified).toList()
  );

  double get displayedBalance {
    switch (_balanceMode) {
      case BalanceMode.total:
        return totalBalance;
      case BalanceMode.verified:
        return verifiedBalance;
      case BalanceMode.unverified:
        return unverifiedBalance;
    }
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

  double _calculateBalance(List<Transaction> txList) {
    double balance = 0;
    for (var tx in txList) {
      if (tx.type == TransactionType.credit) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
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

    // Recipient filter (type-ahead)
    if (_recipientFilter.isNotEmpty) {
      filtered = filtered.where((tx) {
        final query = _recipientFilter.toLowerCase();
        return tx.recipient?.toLowerCase().contains(query) ?? false;
      }).toList();
    }

    // Verification filter
    if (_verificationFilter != VerificationFilter.all) {
      filtered = filtered.where((tx) {
        if (_verificationFilter == VerificationFilter.verified) {
          return tx.isVerified;
        } else {
          return !tx.isVerified;
        }
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

  void setRecipientFilter(String recipient) {
    _recipientFilter = recipient;
    notifyListeners();
  }

  void setVerificationFilter(VerificationFilter filter) {
    _verificationFilter = filter;
    notifyListeners();
  }

  void setBalanceMode(BalanceMode mode) {
    _balanceMode = mode;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _dateRange = null;
    _sourceFilter = null;
    _recipientFilter = '';
    _verificationFilter = VerificationFilter.all;
    notifyListeners();
  }

  Future<void> toggleVerification(int? id) async {
    if (id == null) return;
    
    final transaction = _transactions.firstWhere((t) => t.id == id);
    await _databaseService.markAsVerified(id, !transaction.isVerified);
    await loadTransactions();
  }

  Future<List<List<Transaction>>> getPossibleDuplicates() async {
    return await _databaseService.getPossibleDuplicates();
  }

  Future<void> deleteTransaction(int? id) async {
    if (id == null) return;
    await _databaseService.deleteTransaction(id);
    await loadTransactions();
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

import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AnalyticsService {
  // Calculate daily totals for a list of transactions
  Map<DateTime, DailyMetrics> calculateDailyMetrics(List<Transaction> transactions) {
    final Map<DateTime, DailyMetrics> dailyData = {};

    // Sort transactions by date
    final sortedTx = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedTx.isEmpty) return {};

    // Normalize dates (remove time component)
    for (var tx in sortedTx) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      
      if (!dailyData.containsKey(date)) {
        dailyData[date] = DailyMetrics(date: date);
      }

      if (tx.type == TransactionType.credit) {
        dailyData[date]!.income += tx.amount;
      } else {
        dailyData[date]!.expense += tx.amount;
      }
    }

    return dailyData;
  }

  // Get data for the last N days
  List<DailyMetrics> getLastNDaysMetrics(List<Transaction> transactions, int days) {
    final metricsMap = calculateDailyMetrics(transactions);
    final List<DailyMetrics> result = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      if (metricsMap.containsKey(date)) {
        result.add(metricsMap[date]!);
      } else {
        result.add(DailyMetrics(date: date)); // Empty day
      }
    }

    return result;
  }

  // Calculate totals by source
  Map<TransactionSource, double> calculateSourceTotals(List<Transaction> transactions) {
    final Map<TransactionSource, double> totals = {};

    for (var tx in transactions) {
      if (!totals.containsKey(tx.source)) {
        totals[tx.source] = 0;
      }
      
      // For pie charts, we usually care about volume or specific types
      // Here we'll sum up absolute values to show activity volume
      totals[tx.source] = totals[tx.source]! + tx.amount;
    }

    return totals;
  }
}

class DailyMetrics {
  final DateTime date;
  double income;
  double expense;

  DailyMetrics({
    required this.date,
    this.income = 0,
    this.expense = 0,
  });

  double get net => income - expense;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../services/analytics_service.dart';
import '../models/transaction_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  int _selectedDays = 7; // Default to last 7 days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            initialValue: _selectedDays,
            onSelected: (value) {
              setState(() {
                _selectedDays = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 Days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 Days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 Days')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Last $_selectedDays Days'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final metrics = _analyticsService.getLastNDaysMetrics(
            provider.allTransactions, 
            _selectedDays
          );

          if (metrics.isEmpty || metrics.every((m) => m.income == 0 && m.expense == 0)) {
            return const Center(
              child: Text('No data available for this period'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(metrics),
                const SizedBox(height: 24),
                const Text(
                  'Income vs Expense',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildLineChart(metrics),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Net Balance Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildBarChart(metrics),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<DailyMetrics> metrics) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var m in metrics) {
      totalIncome += m.income;
      totalExpense += m.expense;
    }

    final currencyFormat = NumberFormat.currency(symbol: 'ZMW ');

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Income',
            currencyFormat.format(totalIncome),
            Colors.green,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Expense',
            currencyFormat.format(totalExpense),
            Colors.red,
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<DailyMetrics> metrics) {
    // Find max Y value for scaling
    double maxY = 0;
    for (var m in metrics) {
      if (m.income > maxY) maxY = m.income;
      if (m.expense > maxY) maxY = m.expense;
    }
    maxY = maxY * 1.2; // Add 20% padding

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < metrics.length) {
                  // Show date every few days depending on range
                  int interval = _selectedDays > 14 ? (_selectedDays ~/ 5) : 1;
                  if (index % interval == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM d').format(metrics[index].date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: metrics.length.toDouble() - 1,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Income Line
          LineChartBarData(
            spots: metrics.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.income);
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          // Expense Line
          LineChartBarData(
            spots: metrics.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.expense);
            }).toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<DailyMetrics> metrics) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: metrics.map((m) => m.net.abs()).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < metrics.length) {
                  int interval = _selectedDays > 14 ? (_selectedDays ~/ 5) : 1;
                  if (index % interval == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('d').format(metrics[index].date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: metrics.asMap().entries.map((e) {
          final net = e.value.net;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: net.abs(),
                color: net >= 0 ? Colors.green : Colors.red,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

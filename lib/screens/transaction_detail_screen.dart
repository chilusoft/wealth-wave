import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'K');
    final dateFormat = DateFormat('EEEE, MMMM d, y \'at\' h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: transaction.type == TransactionType.credit
            ? Colors.green
            : Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: transaction.type == TransactionType.credit
                      ? [Colors.green.shade400, Colors.green.shade700]
                      : [Colors.red.shade400, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    transaction.type == TransactionType.credit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.type == TransactionType.credit ? 'Received' : 'Sent',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Details List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Source',
                    value: _getSourceName(transaction.source),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.phone_android,
                    title: 'Sender',
                    value: transaction.sender,
                    color: Colors.orange,
                  ),
                  if (transaction.recipient != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      icon: Icons.person,
                      title: transaction.type == TransactionType.credit
                          ? 'From'
                          : 'To',
                      value: transaction.recipient!,
                      color: Colors.purple,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    value: dateFormat.format(transaction.date),
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.message,
                    title: 'SMS Message',
                    value: transaction.body,
                    color: Colors.indigo,
                    isMultiline: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSourceName(TransactionSource source) {
    switch (source) {
      case TransactionSource.airtelMoney:
        return 'Airtel Money';
      case TransactionSource.momo:
        return 'MTN MoMo';
      case TransactionSource.stanChart:
        return 'Standard Chartered';
      case TransactionSource.fnb:
        return 'First National Bank';
      case TransactionSource.unknown:
        return 'Unknown';
    }
  }
}

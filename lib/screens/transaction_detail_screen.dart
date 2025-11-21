import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late bool _isVerified;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.transaction.isVerified;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'K');
    final dateFormat = DateFormat('EEEE, MMMM d, y \'at\' h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: widget.transaction.type == TransactionType.credit
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
                  colors: widget.transaction.type == TransactionType.credit
                      ? [Colors.green.shade400, Colors.green.shade700]
                      : [Colors.red.shade400, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    widget.transaction.type == TransactionType.credit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.transaction.type == TransactionType.credit ? 'Received' : 'Sent',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(widget.transaction.amount),
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
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildVerificationCard(),
                  const SizedBox(height: 1),
                  _buildDetailCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Source',
                    value: _getSourceName(widget.transaction.source),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 1),
                  _buildDetailCard(
                    icon: Icons.phone_android,
                    title: 'Sender',
                    value: widget.transaction.sender,
                    color: Colors.orange,
                  ),
                  if (widget.transaction.recipient != null) ...[
                    const SizedBox(height: 1),
                    _buildDetailCard(
                      icon: Icons.person,
                      title: widget.transaction.type == TransactionType.credit
                          ? 'From'
                          : 'To',
                      value: widget.transaction.recipient!,
                      color: Colors.purple,
                    ),
                  ],
                  const SizedBox(height: 1),
                  _buildDetailCard(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    value: dateFormat.format(widget.transaction.date),
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 1),
                  if (widget.transaction.transactionId != null) ...[
                    _buildDetailCard(
                      icon: Icons.tag,
                      title: 'Transaction ID',
                      value: widget.transaction.transactionId!,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 1),
                  ],
                  _buildDetailCard(
                    icon: Icons.message,
                    title: 'SMS Message',
                    value: widget.transaction.body,
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

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SwitchListTile(
        title: const Text(
          'Verified Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _isVerified ? 'This transaction is verified' : 'Mark as verified',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        value: _isVerified,
        activeColor: Colors.green,
        secondary: Icon(
          _isVerified ? Icons.check_circle : Icons.circle_outlined,
          color: _isVerified ? Colors.green : Colors.grey,
          size: 28,
        ),
        onChanged: (bool value) async {
          setState(() {
            _isVerified = value;
          });
          
          // Update in provider/database
          await Provider.of<TransactionProvider>(context, listen: false)
              .toggleVerification(widget.transaction.id);
        },
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
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
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

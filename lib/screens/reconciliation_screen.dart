import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({super.key});

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  bool _isLoading = true;
  List<List<Transaction>> _duplicateGroups = [];

  @override
  void initState() {
    super.initState();
    _loadDuplicates();
  }

  Future<void> _loadDuplicates() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final duplicates = await provider.getPossibleDuplicates();

    setState(() {
      _duplicateGroups = duplicates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconcile Duplicates'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _duplicateGroups.isEmpty
              ? _buildEmptyState()
              : _buildDuplicateList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
          const SizedBox(height: 16),
          const Text(
            'No Duplicates Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your transactions look clean!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _duplicateGroups.length,
      itemBuilder: (context, index) {
        final group = _duplicateGroups[index];
        return _buildDuplicateGroupCard(group);
      },
    );
  }

  Widget _buildDuplicateGroupCard(List<Transaction> group) {
    final transactionId = group.first.transactionId ?? 'Unknown ID';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Possible Duplicate: $transactionId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...group.map((tx) => _buildTransactionItem(tx)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final currencyFormat = NumberFormat.currency(symbol: 'ZMW ');
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormat.format(tx.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tx.type == TransactionType.credit
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteTransaction(tx),
                tooltip: 'Delete this duplicate',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tx.sender,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (tx.recipient != null)
            Text(
              'To: ${tx.recipient}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(tx.date),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            tx.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.deleteTransaction(tx.id);
      _loadDuplicates(); // Reload list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }
}

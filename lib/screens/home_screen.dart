import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'transaction_detail_screen.dart';
import 'reconciliation_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'K');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wealth Wave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Reports',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.merge_type),
            tooltip: 'Reconcile Duplicates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReconciliationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, provider),
          ),
          IconButton(
            icon: provider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            onPressed: provider.isLoading ? null : () => provider.syncSms(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) => provider.setSearchQuery(value),
            ),
          ),

          // Active filters display
          if (provider.dateRange != null || 
              provider.sourceFilter != null || 
              provider.recipientFilter.isNotEmpty ||
              provider.verificationFilter != VerificationFilter.all)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (provider.dateRange != null)
                    _buildFilterChip(
                      '${DateFormat('MMM d').format(provider.dateRange!.start)} - ${DateFormat('MMM d').format(provider.dateRange!.end)}',
                      () => provider.setDateRange(null),
                    ),
                  if (provider.sourceFilter != null)
                    _buildFilterChip(
                      _getSourceName(provider.sourceFilter!),
                      () => provider.setSourceFilter(null),
                    ),
                  if (provider.recipientFilter.isNotEmpty)
                    _buildFilterChip(
                      'To: ${provider.recipientFilter}',
                      () => provider.setRecipientFilter(''),
                    ),
                  if (provider.verificationFilter != VerificationFilter.all)
                    _buildFilterChip(
                      provider.verificationFilter == VerificationFilter.verified 
                          ? 'Verified Only' 
                          : 'Unverified Only',
                      () => provider.setVerificationFilter(VerificationFilter.all),
                    ),
                  TextButton.icon(
                    onPressed: () => provider.clearFilters(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear all'),
                  ),
                ],
              ),
            ),

          _buildBalanceCard(provider, currencyFormat),

          Expanded(
            child: provider.transactions.isEmpty
                ? _buildEmptyState(provider)
                : ListView.builder(
                    itemCount: provider.transactions.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final tx = provider.transactions[index];
                      return _buildTransactionCard(context, tx, currencyFormat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
      ),
    );
  }

  Widget _buildEmptyState(TransactionProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => provider.syncSms(),
            icon: const Icon(Icons.sync),
            label: const Text('Sync from SMS'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction tx, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      elevation: 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: tx.type == TransactionType.credit
                  ? Colors.green[100]
                  : Colors.red[100],
              child: Icon(
                tx.type == TransactionType.credit
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: tx.type == TransactionType.credit
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            if (tx.isVerified)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          tx.recipient ?? tx.sender,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getSourceName(tx.source),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              DateFormat('MMM d, y h:mm a').format(tx.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(tx.amount),
          style: TextStyle(
            color: tx.type == TransactionType.credit
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionDetailScreen(transaction: tx),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider, NumberFormat format) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBalanceToggle(provider, BalanceMode.total, 'Total'),
              const SizedBox(width: 8),
              _buildBalanceToggle(provider, BalanceMode.verified, 'Verified'),
              const SizedBox(width: 8),
              _buildBalanceToggle(provider, BalanceMode.unverified, 'Unverified'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getBalanceLabel(provider.balanceMode),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            format.format(provider.displayedBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Income', provider.totalIncome, Colors.green[100]!, format),
              _buildSummaryItem('Expense', provider.totalExpense, Colors.red[100]!, format),
            ],
          ),
        ],
      ),
    );
  }

  String _getBalanceLabel(BalanceMode mode) {
    switch (mode) {
      case BalanceMode.total: return 'Total Balance';
      case BalanceMode.verified: return 'Verified Balance';
      case BalanceMode.unverified: return 'Unverified Balance';
    }
  }

  Widget _buildBalanceToggle(TransactionProvider provider, BalanceMode mode, String label) {
    final isSelected = provider.balanceMode == mode;
    return GestureDetector(
      onTap: () => provider.setBalanceMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, NumberFormat format) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            format.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context, TransactionProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Verification Filter
                  const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: provider.verificationFilter == VerificationFilter.all,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setVerificationFilter(VerificationFilter.all);
                            setModalState(() {});
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Verified'),
                        selected: provider.verificationFilter == VerificationFilter.verified,
                        onSelected: (selected) {
                          provider.setVerificationFilter(
                              selected ? VerificationFilter.verified : VerificationFilter.all);
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Unverified'),
                        selected: provider.verificationFilter == VerificationFilter.unverified,
                        onSelected: (selected) {
                          provider.setVerificationFilter(
                              selected ? VerificationFilter.unverified : VerificationFilter.all);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recipient Filter
                  const Text('Recipient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      hintText: 'Filter by recipient name',
                      prefixIcon: const Icon(Icons.person_search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) => provider.setRecipientFilter(value),
                  ),
                  const SizedBox(height: 20),

                  // Date Range Filter
                  const Text('Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: provider.dateRange,
                      );
                      if (picked != null) {
                        provider.setDateRange(picked);
                        setModalState(() {});
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      provider.dateRange != null
                          ? '${DateFormat('MMM d, y').format(provider.dateRange!.start)} - ${DateFormat('MMM d, y').format(provider.dateRange!.end)}'
                          : 'Select date range',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Source Filter
                  const Text('Source', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Airtel Money'),
                        selected: provider.sourceFilter == TransactionSource.airtelMoney,
                        onSelected: (selected) {
                          provider.setSourceFilter(
                              selected ? TransactionSource.airtelMoney : null);
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('MTN MoMo'),
                        selected: provider.sourceFilter == TransactionSource.momo,
                        onSelected: (selected) {
                          provider.setSourceFilter(
                              selected ? TransactionSource.momo : null);
                          setModalState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Standard Chartered'),
                        selected: provider.sourceFilter == TransactionSource.stanChart,
                        onSelected: (selected) {
                          provider.setSourceFilter(
                              selected ? TransactionSource.stanChart : null);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
        return 'FNB';
      case TransactionSource.unknown:
        return 'Unknown';
    }
  }
}

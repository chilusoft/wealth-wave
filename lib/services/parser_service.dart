import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import '../models/transaction_model.dart';

class ParserService {
  // Regex patterns
  static final RegExp _amountRegex = RegExp(r'[K|ZMW]\s?([\d,]+\.?\d{0,2})', caseSensitive: false);
  static final RegExp _recipientRegex = RegExp(r'(?:to|from)\s+([A-Za-z\s]+)', caseSensitive: false);
  
  // Transaction ID patterns for different providers
  // Transaction ID patterns for different providers
  static final RegExp _transactionIdRegex = RegExp(
    r'(?:transaction|trans|txn|reference|ref)(?:\s+)?(?:id|no|number)?[\s:.-]*([A-Z0-9]{5,})',
    caseSensitive: false
  );
  
  Transaction? parseMessage(SmsMessage message) {
    final sender = message.sender?.toUpperCase() ?? '';
    final body = message.body ?? '';
    final date = message.date ?? DateTime.now();
    return parseRaw(sender, body, date);
  }

  Transaction? parseRaw(String sender, String body, DateTime date) {
    final normalizedSender = sender.toUpperCase();
    // Only process messages from these specific sources
    if (normalizedSender == 'AIRTELMONEY') {
      return _parseAirtel(body, date, sender);
    } else if (normalizedSender.contains('MOMO') || normalizedSender.contains('MTN')) {
      return _parseMomo(body, date, sender);
    } else if (sender.contains('STAN') || sender.contains('SCB') || 
               sender.contains('STANCHART')) {
      return _parseStanChart(body, date, sender);
    }

    // Reject all other sources (including FNB, promotional messages, etc.)
    return null;
  }

  Transaction? _parseAirtel(String body, DateTime date, String sender) {
    // Example: "You have received K100.00 from..."
    // Example: "Txn Id: ... You have sent K50.00 to..."
    
    // Extract transaction ID - required for all transactions
    String? transactionId = _extractTransactionId(body);
    if (transactionId == null || transactionId.isEmpty) {
      return null; // Reject SMS without transaction ID (promotional messages)
    }
    
    double amount = _extractAmount(body);
    if (amount == 0) return null;

    TransactionType type = TransactionType.debit;
    if (body.toLowerCase().contains('received')) {
      type = TransactionType.credit;
    }
    
    String? recipient = _extractRecipient(body);

    return Transaction(
      sender: sender,
      amount: amount,
      date: date,
      type: type,
      source: TransactionSource.airtelMoney,
      body: body,
      recipient: recipient,
      transactionId: transactionId,
    );
  }

  Transaction? _parseMomo(String body, DateTime date, String sender) {
    // Extract transaction ID - required for all transactions
    String? transactionId = _extractTransactionId(body);
    if (transactionId == null || transactionId.isEmpty) {
      return null; // Reject SMS without transaction ID (promotional messages)
    }
    
    double amount = _extractAmount(body);
    if (amount == 0) return null;

    TransactionType type = TransactionType.debit;
    if (body.toLowerCase().contains('received')) {
      type = TransactionType.credit;
    }
    
    String? recipient = _extractRecipient(body);

    return Transaction(
      sender: sender,
      amount: amount,
      date: date,
      type: type,
      source: TransactionSource.momo,
      body: body,
      recipient: recipient,
      transactionId: transactionId,
    );
  }

  Transaction? _parseStanChart(String body, DateTime date, String sender) {
    // Extract transaction ID - required for all transactions
    String? transactionId = _extractTransactionId(body);
    if (transactionId == null || transactionId.isEmpty) {
      return null; // Reject SMS without transaction ID (promotional messages)
    }
    
    double amount = _extractAmount(body);
    if (amount == 0) return null;

    TransactionType type = TransactionType.debit;
    if (body.toLowerCase().contains('credited')) {
      type = TransactionType.credit;
    }
    
    String? recipient = _extractRecipient(body);

    return Transaction(
      sender: sender,
      amount: amount,
      date: date,
      type: type,
      source: TransactionSource.stanChart,
      body: body,
      recipient: recipient,
      transactionId: transactionId,
    );
  }

  double _extractAmount(String body) {
    final match = _amountRegex.firstMatch(body);
    if (match != null) {
      String amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr) ?? 0.0;
    }
    return 0.0;
  }
  
  String? _extractRecipient(String body) {
    final match = _recipientRegex.firstMatch(body);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim();
    }
    return null;
  }
  
  static final RegExp _transactionIdStartRegex = RegExp(r'^([A-Z0-9]{5,})[\s.]', caseSensitive: false);

  String? _extractTransactionId(String body) {
    final match = _transactionIdRegex.firstMatch(body);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim().toUpperCase();
    }
    
    // Fallback: Check if ID is at the start of the message
    final startMatch = _transactionIdStartRegex.firstMatch(body);
    if (startMatch != null && startMatch.groupCount >= 1) {
      return startMatch.group(1)?.trim().toUpperCase();
    }

    return null;
  }
}


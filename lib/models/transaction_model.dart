class Transaction {
  final int? id;
  final String sender;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionSource source;
  final String body;
  final String? recipient; // Who received/sent the money
  final String? transactionId; // Transaction ID from SMS
  final bool isVerified; // Manual verification status

  Transaction({
    this.id,
    required this.sender,
    required this.amount,
    required this.date,
    required this.type,
    required this.source,
    required this.body,
    this.recipient,
    this.transactionId,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.index,
      'source': source.index,
      'body': body,
      'recipient': recipient,
      'transactionId': transactionId,
      'isVerified': isVerified ? 1 : 0,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      sender: map['sender'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values[map['type']],
      source: TransactionSource.values[map['source']],
      body: map['body'],
      recipient: map['recipient'],
      transactionId: map['transactionId'],
      isVerified: map['isVerified'] == 1,
    );
  }
}

enum TransactionType { credit, debit }

enum TransactionSource { airtelMoney, momo, stanChart, fnb, unknown }

class TransactionModel {
  final int id;
  final String date;
  final String note;
  final double? debit;
  final double? credit;
  final double balance;

  TransactionModel({
    required this.id,
    required this.date,
    required this.note,
    this.debit,
    this.credit,
    required this.balance,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      date: json['date'],
      note: json['note'],
      debit: json['debit']?.toDouble(),
      credit: json['credit']?.toDouble(),
      balance: json['balance'].toDouble(),
    );
  }
}

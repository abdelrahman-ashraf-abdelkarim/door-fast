import 'package:captain_app/models/transaction_model.dart';
import 'package:captain_app/widgets/transaction_card.dart';
import 'package:flutter/material.dart';

class TransactionLogScreen extends StatelessWidget {
  const TransactionLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات المالية'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: transactionLogData.length,
        itemBuilder: (context, index) {
          final item = transactionLogData[index];

          return TransactionCard(
            id: item.id,
            date: item.date,
            note: item.note,
            debit: item.debit,
            credit: item.credit,
            balance: item.balance,
          );
        },
      ),
    );
  }
}

final List<TransactionModel> transactionLogData = [
  TransactionModel(
    id: 1025,
    date: "24 أكتوبر 2023 . 09:00ص",
    note: "طلب رقم 556",
    debit: null,
    credit: 200,
    balance: 1200,
  ),
  TransactionModel(
    id: 1026,
    date: "25 أكتوبر 2023 . 10:30ص",
    note: "سحب رصيد",
    debit: 150,
    credit: null,
    balance: 1050,
  ),
];

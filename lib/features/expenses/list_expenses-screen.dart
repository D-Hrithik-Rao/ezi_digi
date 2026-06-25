import 'package:ezi_cable_digi/core/services/localization_service.dart';
import 'package:flutter/material.dart';
import '../../core/data/expense_storage.dart';

class ListExpensesScreen extends StatelessWidget {
  const ListExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseStorage.expenses;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.of(context, 'list_expenses'))),
      body: expenses.isEmpty
          ? Center(child: Text(AppStrings.of(context, 'no_expenses_found')))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final exp = expenses[index];

                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(exp.date),
                        ],
                      ),
                      Text("₹${exp.amount}"),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
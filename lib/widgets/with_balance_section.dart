import 'package:flutter/material.dart';
import '../models/product.dart';

class WithBalanceSection extends StatelessWidget {
  final Map<String, List<Product>> stallsWithBalance;
  final Map<String, bool> expandedStalls;
  final Function(String) onStallTap;
  final Widget Function(String, List<Product>) buildStallCard;

  const WithBalanceSection({
    Key? key,
    required this.stallsWithBalance,
    required this.expandedStalls,
    required this.onStallTap,
    required this.buildStallCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (stallsWithBalance.isNotEmpty) {
              stallsWithBalance.keys.forEach((stall) {
                onStallTap(stall);
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black45),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.black87),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'WITH BALANCE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  stallsWithBalance.values.any((products) => 
                    expandedStalls[products.first.name.split('(Stall: ')[1].split(')')[0]] ?? false)
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
        if (stallsWithBalance.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No stalls with balance',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          )
        else
          ...stallsWithBalance.entries.map((entry) => buildStallCard(entry.key, entry.value)),
      ],
    );
  }
}
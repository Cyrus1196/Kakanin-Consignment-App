import 'package:flutter/material.dart';
import '../models/product.dart';

class PaidSection extends StatelessWidget {
  final Map<String, List<Product>> paidStalls;
  final Map<String, bool> expandedStalls;
  final Function(String) onStallTap;
  final Widget Function(String, List<Product>) buildStallCard;

  const PaidSection({
    Key? key,
    required this.paidStalls,
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
            if (paidStalls.isNotEmpty) {
              paidStalls.keys.forEach((stall) {
                onStallTap(stall);
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: EdgeInsets.only(top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
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
                Icon(Icons.check_circle_outline, color: Colors.green[800]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PAID',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                Icon(
                  paidStalls.values.any((products) => 
                    expandedStalls[products.first.name.split('(Stall: ')[1].split(')')[0]] ?? false)
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.green[800],
                ),
              ],
            ),
          ),
        ),
        if (paidStalls.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No paid stalls',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          )
        else
          ...paidStalls.entries.map((entry) => buildStallCard(entry.key, entry.value)),
      ],
    );
  }
}
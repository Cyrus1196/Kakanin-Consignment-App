// screens/sales_report_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/sales_report.dart';
import '../database/hive_database.dart';

class SalesReportScreen extends StatefulWidget {
  final List<Product> products;
  SalesReportScreen({required this.products});

  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final box = await HiveDatabase.getProductsBox();
    setState(() {
      _products = box.values.where((product) => product.soldQuantity > 0).toList();
    });
  }

  double _calculateTotalSales() {
    double totalSales = 0.0;
    for (var product in _products) {
      if (product.saleDate != null) {
        DateTime saleDate = product.saleDate!;
        if (saleDate.isAfter(_startDate.subtract(Duration(days: 1))) && 
            saleDate.isBefore(_endDate.add(Duration(days: 1)))) {
          totalSales += product.price * product.soldQuantity;
        }
      }
    }
    return totalSales;
  }

  Widget _buildSalesItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 16)),
              Text(
                '₱${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          // Add sales breakdown by product and date
          ..._products
              .where((p) => p.soldQuantity > 0 && p.saleDate != null)
              .where((p) => p.saleDate!.isAfter(_startDate.subtract(Duration(days: 1))) && 
                          p.saleDate!.isBefore(_endDate.add(Duration(days: 1))))
              .map((p) => Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.name.split('(')[0].trim()}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            Text(
                              'Stall: ${p.name.split('(Stall: ')[1].split(')')[0]}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            Text(
                              'Date: ${p.saleDate!.year}-${p.saleDate!.month.toString().padLeft(2, '0')}-${p.saleDate!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        Text(
                          '₱${(p.price * p.soldQuantity).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Report'),
        backgroundColor: Colors.green[800],
      ),
      body: _buildSalesReportView(
        SalesReport(
          dailySales: _calculateTotalSales(),
          weeklySales: 0,
          monthlySales: 0,
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Widget _buildSalesReportView(SalesReport salesReport) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Range',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text('From'),
                              subtitle: Text('${_startDate.year}-${_startDate.month}-${_startDate.day}'),
                              onTap: () => _selectStartDate(context),
                              trailing: Icon(Icons.calendar_today),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: Text('To'),
                              subtitle: Text('${_endDate.year}-${_endDate.month}-${_endDate.day}'),
                              onTap: () => _selectEndDate(context),
                              trailing: Icon(Icons.calendar_today),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 16),
                      Text(
                        'Sales Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildSalesItem('Total Sales:', _calculateTotalSales()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalSalesByPeriod(DateTime date) {
    double totalSales = 0.0;
    for (var product in widget.products) {  // Changed from products to widget.products
      if (product.soldQuantity > 0) {
        totalSales += product.totalSales;
      }
    }
    return totalSales;
  }

  double _calculateTotalSalesByWeek(DateTime date) {
    double totalSales = 0.0;
    for (var product in widget.products) {  // Changed from products to widget.products
      if (product.soldQuantity > 0) {
        totalSales += product.totalSales;
      }
    }
    return totalSales;
  }

  double _calculateTotalSalesByMonth(DateTime date) {
    double totalSales = 0.0;
    for (var product in widget.products) {  // Changed from products to widget.products
      if (product.soldQuantity > 0) {
        totalSales += product.totalSales;
      }
    }
    return totalSales;
  }
}
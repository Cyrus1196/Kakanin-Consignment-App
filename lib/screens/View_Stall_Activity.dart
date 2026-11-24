import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/product_price.dart';
import '../database/hive_database.dart';
import 'package:collection/collection.dart';
import '../providers/product_price_provider.dart';

class StallActivityScreen extends StatefulWidget {
  @override
  _StallActivityScreenState createState() => _StallActivityScreenState();
}

class _StallActivityScreenState extends State<StallActivityScreen> {
  List<Product> products = [];
  Map<String, double> productPrices = {};
  final Map<Product, TextEditingController> _soldControllers = {};
  final Map<Product, int> _currentSoldQuantities = {};
  final priceProvider = ProductPriceProvider();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    priceProvider.updatePrices();
  }

  Future<void> _loadProducts() async {
    final box = await HiveDatabase.getProductsBox();
    setState(() {
      products = box.values.toList();
      for (var product in products) {
        _soldControllers[product] = TextEditingController();
        _currentSoldQuantities[product] = product.soldQuantity;
      }
    });
  }

  bool _stallIsPaid(List<Product> stallProducts) {
    return stallProducts.isNotEmpty &&
        stallProducts.every((product) => product.isPaid);
  }

  Future<void> _setStallPaid(List<Product> stallProducts, bool paid) async {
    for (final product in stallProducts) {
      product.isPaid = paid;
      await product.save();
    }
    await _loadProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          paid ? 'Moved to Paid' : 'Moved back to With Balance',
        ),
      ),
    );
  }

  Future<void> _updateSales(Product product) async {
    int soldQty = int.tryParse(_soldControllers[product]!.text) ?? 0;

    if (soldQty >= 0 && soldQty <= product.quantity) {
      final box = await HiveDatabase.getProductsBox();
      int productIndex = box.values.toList().indexOf(product);
      if (productIndex != -1) {
        final productName = product.name.split('(')[0].trim();
        final currentPrice = priceProvider.productPrices[productName] ?? product.price;
        product.updateSoldQuantity(soldQty);
        product.price = currentPrice;
        
        box.putAt(productIndex, product);
        
        setState(() {
          _loadProducts();
          _loadProductPrices();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ${productName} sold quantity to $soldQty')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid sold quantity!')),
      );
    }
  }

  void _loadProductPrices() {
    final box = Hive.box<ProductPrice>('product_prices');
    setState(() {
      productPrices = Map.fromEntries(
        box.values.map((price) => MapEntry(price.name, price.price))
      );
    });
  }

  void _changeSoldQuantity(Product product) {
    _soldControllers[product]!.text = _currentSoldQuantities[product].toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changed to current sold quantity for ${product.name}')),
    );
  }

  Widget _buildStallCard(String stallName, List<Product> productsInStall) {
    double totalStallSales = productsInStall.fold(
      0.0,
      (sum, product) => sum + product.totalBalance,
    );
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      stallName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Date: ${productsInStall.first.name.split('(Date: ')[1].split(')')[0]}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Total Sales: ₱${totalStallSales.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _setStallPaid(
                      productsInStall,
                      !_stallIsPaid(productsInStall),
                    ),
                    icon: Icon(
                      _stallIsPaid(productsInStall)
                          ? Icons.undo
                          : Icons.payments,
                      size: 18,
                    ),
                    label: Text(
                      _stallIsPaid(productsInStall)
                          ? 'Move back to With Balance'
                          : 'Mark as Paid',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...productsInStall.map((product) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.brown[100],
                        child: Icon(Icons.fastfood, size: 18, color: Colors.brown[800]),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name.split('(')[0].trim(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Price: ₱${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.28,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[300]!),
                          ),
                          child: Column(
                            children: [
                              Text('Quantity',
                                  style: TextStyle(color: Colors.blue[700])),
                              SizedBox(height: 8),
                              Text('${product.quantity}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900])),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.28,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Column(
                            children: [
                              Text('Sold',
                                  style: TextStyle(color: Colors.green[700])),
                              SizedBox(height: 8),
                              Text('${product.soldQuantity}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900])),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.28,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Column(
                            children: [
                              Text('Sales',
                                  style: TextStyle(color: Colors.orange[700])),
                              SizedBox(height: 8),
                              Text('₱${product.totalBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[900])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _soldControllers[product],
                          decoration: InputDecoration(
                            labelText: 'Sold',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: () => _updateSales(product),
                          icon: Icon(Icons.update, size: 16),
                          label: Text('Update', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var groupedProducts = groupBy<Product, String>(
      products,
      (Product product) => product.name.split('(Stall: ')[1].split(')')[0],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stall Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pending_actions),
                          SizedBox(width: 8),
                          Text('WITH BALANCE'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text('PAID'),
                        ],
                      ),
                    ),
                  ],
                  labelColor: Colors.green[800],
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green[800],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: groupedProducts.entries
                          .where((entry) => !_stallIsPaid(entry.value))
                          .length,
                      itemBuilder: (context, index) {
                        var withBalanceStalls = groupedProducts.entries
                            .where((entry) => !_stallIsPaid(entry.value))
                            .toList();
                        String stallName = withBalanceStalls[index].key;
                        List<Product> productsInStall = withBalanceStalls[index].value;
                        return _buildStallCard(stallName, productsInStall);
                      },
                    ),
                    ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: groupedProducts.entries
                          .where((entry) => _stallIsPaid(entry.value))
                          .length,
                      itemBuilder: (context, index) {
                        var paidStalls = groupedProducts.entries
                            .where((entry) => _stallIsPaid(entry.value))
                            .toList();
                        String stallName = paidStalls[index].key;
                        List<Product> productsInStall = paidStalls[index].value;
                        return _buildStallCard(stallName, productsInStall);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposeProducts();  // Call async method
    for (var controller in _soldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Add this new method to handle async disposal
  Future<void> _disposeProducts() async {
    final box = await HiveDatabase.getProductsBox();
    for (var product in products) {
      int productIndex = box.values.toList().indexOf(product);
      if (productIndex != -1) {
        await box.putAt(productIndex, product);
      }
    }
  }
}
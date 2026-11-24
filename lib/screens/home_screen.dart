// home_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mags101/screens/Add_Product_to_Stall.dart';
import 'package:mags101/screens/sales_report_screen.dart'; // Import sales report screen
import 'View_Stall_Activity.dart';
import '../models/product.dart';
import '../models/product_price.dart';
import '../providers/product_price_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _initializeProductPrices();
  }

  void _initializeProductPrices() {
    final box = Hive.box<ProductPrice>('product_prices');
    if (box.isEmpty) {
      final defaultPrices = {
        'Biko': 5.0,
        'Suman': 10.0,
        'Puto': 10.0,
        'Puto Maya': 5.0,
      };
      
      defaultPrices.forEach((name, price) {
        box.add(ProductPrice(name: name, price: price));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kakanin Consignment'),
        backgroundColor: Colors.green[800],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.green[800],
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_business, color: Colors.green[800]),
              title: Text('Add Product to Stall', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(onAddProduct: (Product product) {
                      setState(() {
                        products.add(product);
                      });
                    }),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_note, color: Colors.green[800]),
              title: Text('Manage Products', style: TextStyle(color: Colors.black)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final box = Hive.box<ProductPrice>('product_prices');
                    final TextEditingController newProductController = TextEditingController();
                    final TextEditingController newPriceController = TextEditingController();

                    return AlertDialog(
                      title: Text('Manage Products'),
                      content: Container(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: newProductController,
                              decoration: InputDecoration(
                                labelText: 'Product Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: newPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Price',
                                prefixText: '₱',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                final name = newProductController.text.trim();
                                final price = double.tryParse(newPriceController.text);
                                if (name.isNotEmpty && price != null && price > 0) {
                                  // Add new product directly
                                  box.add(ProductPrice(name: name, price: price));
                                  
                                  // Get all products and sort them
                                  var allProducts = box.values.toList()
                                    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                                  
                                  // Clear input fields
                                  newProductController.clear();
                                  newPriceController.clear();
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Product added successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please enter valid product details')),
                                  );
                                }
                              },
                              child: Text('Add Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                              ),
                            ),
                            Divider(),
                            Expanded(
                              child: ValueListenableBuilder(
                                valueListenable: box.listenable(),
                                builder: (context, Box<ProductPrice> box, _) {
                                  final prices = box.values.toList()
                                    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                                  return ListView.builder(
                                    itemCount: prices.length,
                                    itemBuilder: (context, index) {
                                      final price = prices[index];
                                      return ListTile(
                                        title: Text('${price.name} - ₱${price.price.toStringAsFixed(2)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () => _editProductPrice(price.name),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                final index = box.values.toList().indexOf(price);
                                                box.deleteAt(index);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text('Sales Report', style: TextStyle(color: Colors.black)), // Sales Report
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesReportScreen(products: products), // Go to SalesReportScreen
                  ),
                );
              },
            ),
            ListTile(
              title: Text('View Stall Activity', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StallActivityScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kakanin Stall',
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Monitor Your Products',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddProductScreen(onAddProduct: (Product product) {
                                      setState(() {
                                        products.add(product);
                                      });
                                    }),
                                  ),
                                );
                              },
                              child: Text('Add Product to Stall'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.brown[600],
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                textStyle: TextStyle(fontSize: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StallActivityScreen(),
                                  ),
                                );
                              },
                              child: Text('View Stall Activity'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.brown[600],
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                textStyle: TextStyle(fontSize: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                          ),
                        ],
                      ),
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
  
  // Add this import at the top
  
  
  final priceProvider = ProductPriceProvider();
  
  void _editProductPrice(String productName) {
    final box = Hive.box<ProductPrice>('product_prices');
    final currentPrice = box.values.firstWhere(
      (price) => price.name == productName,
      orElse: () => ProductPrice(name: productName, price: 0.0),
    ).price;
    
    TextEditingController priceController = TextEditingController(
      text: currentPrice.toString()
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $productName Price'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'New Price',
              prefixText: '₱',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? newPrice = double.tryParse(priceController.text);
                if (newPrice != null && newPrice > 0) {
                  priceProvider.updatePrice(productName, newPrice);
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),  // Added missing child parameter
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
              ),
            ),
          ],
        );
      },
    );
  }
}
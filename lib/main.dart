import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'models/product_price.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register adapters if not already registered
  if (!Hive.isAdapterRegistered(ProductAdapter().typeId)) {
    Hive.registerAdapter(ProductAdapter());
  }
  if (!Hive.isAdapterRegistered(ProductPriceAdapter().typeId)) {
    Hive.registerAdapter(ProductPriceAdapter());
  }

  // Open boxes
  await Hive.openBox<Product>('products');
  await Hive.openBox<ProductPrice>('product_prices');
  await Hive.openBox<String>('available_stalls');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kakanin Consignment',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            devicePixelRatio: 1.0,
          ),
          child: child!,
        );
      },
      home: HomeScreen(),
    );
  }
}
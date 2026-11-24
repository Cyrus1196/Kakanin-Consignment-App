import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/product_price.dart';

class HiveDatabase {
  static Future<Box<Product>> getProductsBox() async {
    if (!Hive.isBoxOpen('products')) {
      return await Hive.openBox<Product>('products');
    }
    return Hive.box<Product>('products');
  }

  static Future<Box<ProductPrice>> getProductPricesBox() async {
    if (!Hive.isBoxOpen('product_prices')) {
      return await Hive.openBox<ProductPrice>('product_prices');
    }
    return Hive.box<ProductPrice>('product_prices');
  }

  static Future<Box<String>> getAvailableStallsBox() async {
    if (!Hive.isBoxOpen('available_stalls')) {
      return await Hive.openBox<String>('available_stalls');
    }
    return Hive.box<String>('available_stalls');
  }

  static Future<void> initializeBoxes() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProductPriceAdapter());
    }

    await getProductsBox();
    await getProductPricesBox();
    await getAvailableStallsBox();
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
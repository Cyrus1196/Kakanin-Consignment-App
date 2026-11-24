import 'package:hive_flutter/hive_flutter.dart';
import '../models/consignment_entry.dart';
import '../models/product_price.dart';

class HiveDatabase {
  static const String productPricesBoxName = 'product_prices';
  static const String consignmentsBoxName = 'consignments';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(ProductPriceAdapter().typeId)) {
      Hive.registerAdapter(ProductPriceAdapter());
    }
    if (!Hive.isAdapterRegistered(ConsignmentEntryAdapter().typeId)) {
      Hive.registerAdapter(ConsignmentEntryAdapter());
    }

    final box = await getProductPricesBox();
    if (box.isEmpty) {
      const defaultPrices = {
        'Biko': 5.0,
        'Suman': 10.0,
        'Puto': 10.0,
        'Puto Maya': 5.0,
      };
      for (final entry in defaultPrices.entries) {
        await box.add(ProductPrice(name: entry.key, price: entry.value));
      }
    }

    await getConsignmentsBox();
  }

  static Future<Box<ProductPrice>> getProductPricesBox() async {
    if (!Hive.isBoxOpen(productPricesBoxName)) {
      return Hive.openBox<ProductPrice>(productPricesBoxName);
    }
    return Hive.box<ProductPrice>(productPricesBoxName);
  }

  static Box<ProductPrice> productPricesBox() {
    return Hive.box<ProductPrice>(productPricesBoxName);
  }

  static Future<void> addProduct(String name, double price) {
    return productPricesBox().add(ProductPrice(name: name, price: price));
  }

  static Future<void> updateProduct(ProductPrice product, String name, double price) {
    return productPricesBox().put(
      product.key,
      ProductPrice(name: name, price: price),
    );
  }

  static Future<void> deleteProduct(ProductPrice product) {
    return product.delete();
  }

  static Future<Box<ConsignmentEntry>> getConsignmentsBox() async {
    if (!Hive.isBoxOpen(consignmentsBoxName)) {
      return Hive.openBox<ConsignmentEntry>(consignmentsBoxName);
    }
    return Hive.box<ConsignmentEntry>(consignmentsBoxName);
  }

  static Box<ConsignmentEntry> consignmentsBox() {
    return Hive.box<ConsignmentEntry>(consignmentsBoxName);
  }

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<void> addConsignment(
    String productName,
    double price,
    DateTime date,
  ) async {
    final box = consignmentsBox();
    final day = DateTime(date.year, date.month, date.day);
    for (final entry in box.values) {
      if (entry.productName.toLowerCase() == productName.toLowerCase() &&
          _sameDay(entry.date, day)) {
        entry.quantity += 1;
        entry.price = price;
        await entry.save();
        return;
      }
    }
    await box.add(
      ConsignmentEntry(
        productName: productName,
        price: price,
        quantity: 1,
        date: day,
      ),
    );
  }

  static Future<void> changeQuantity(ConsignmentEntry entry, int quantity) {
    if (quantity < 1) return deleteConsignment(entry);
    entry.quantity = quantity;
    return entry.save();
  }

  static Future<void> deleteConsignment(ConsignmentEntry entry) {
    return entry.delete();
  }
}

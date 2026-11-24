import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  int soldQuantity;

  @HiveField(4)  // Add this field
  DateTime? saleDate;

  @HiveField(5)  // Use the next available field number
  String? stallName;

  @HiveField(6)
  bool isPaid;

  Product({
    required this.name,
    required this.quantity,
    required this.price,
    this.soldQuantity = 0,
    this.saleDate,
    this.stallName,
    this.isPaid = false,
  });

  void updateSoldQuantity(int newSoldQuantity) {
    soldQuantity = newSoldQuantity;
    saleDate = DateTime.now();  // Set sale date when updating sold quantity
    save();
  }

  double get totalBalance => price * soldQuantity;
  double get totalSales => price * soldQuantity;
}
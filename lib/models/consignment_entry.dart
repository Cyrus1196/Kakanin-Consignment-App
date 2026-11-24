import 'package:hive/hive.dart';

part 'consignment_entry.g.dart';

@HiveType(typeId: 2)
class ConsignmentEntry extends HiveObject {
  @HiveField(0)
  String productName;

  @HiveField(1)
  double price;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  DateTime date;

  ConsignmentEntry({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.date,
  });
}

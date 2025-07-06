import 'package:hive/hive.dart';

part 'sale_entity.g.dart';

@HiveType(typeId: 3)
class SaleEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String batchId;

  @HiveField(2)
  final String buyerName;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int chickCount;

  @HiveField(5)
  final double pricePerChick;

  @HiveField(6)
  final double paidAmount;

  @HiveField(7)
  final String? note;

  SaleEntity({
    required this.id,
    required this.batchId,
    required this.buyerName,
    required this.date,
    required this.chickCount,
    required this.pricePerChick,
    required this.paidAmount,
    this.note,
  });

  // الحسابات التلقائية
  double get totalPrice => chickCount * pricePerChick;
  double get remainingAmount => totalPrice - paidAmount;

  SaleEntity copyWith({
    String? id,
    String? batchId,
    String? buyerName,
    DateTime? date,
    int? chickCount,
    double? pricePerChick,
    double? paidAmount,
    String? note,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      buyerName: buyerName ?? this.buyerName,
      date: date ?? this.date,
      chickCount: chickCount ?? this.chickCount,
      pricePerChick: pricePerChick ?? this.pricePerChick,
      paidAmount: paidAmount ?? this.paidAmount,
      note: note ?? this.note,
    );
  }
}

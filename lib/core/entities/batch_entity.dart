import 'package:hive/hive.dart';

part 'batch_entity.g.dart';

@HiveType(typeId: 0)
class BatchEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String supplier;

  @HiveField(4)
  final int chickCount;

  @HiveField(5)
  final double chickBuyPrice;

  @HiveField(7)
  final String? note;

  BatchEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.supplier,
    required this.chickCount,
    required this.chickBuyPrice,
    this.note,
  });

  // الحسابات التلقائية
  double get totalBuyPrice => chickCount * chickBuyPrice;
  double get actualChickCost => chickBuyPrice;
  double get totalActualCost => chickCount * actualChickCost;

  BatchEntity copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? supplier,
    int? chickCount,
    double? chickBuyPrice,
    String? note,
  }) {
    return BatchEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      supplier: supplier ?? this.supplier,
      chickCount: chickCount ?? this.chickCount,
      chickBuyPrice: chickBuyPrice ?? this.chickBuyPrice,
      note: note ?? this.note,
    );
  }
}

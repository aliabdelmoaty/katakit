import 'package:hive/hive.dart';

part 'addition_entity.g.dart';

@HiveType(typeId: 1)
class AdditionEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String batchId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double cost;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String userId;

  @HiveField(6)
  final DateTime updatedAt;

  AdditionEntity({
    required this.id,
    required this.batchId,
    required this.name,
    required this.cost,
    required this.date,
    required this.userId,
    required this.updatedAt,
  });

  AdditionEntity copyWith({
    String? id,
    String? batchId,
    String? name,
    double? cost,
    DateTime? date,
    String? userId,
    DateTime? updatedAt,
  }) {
    return AdditionEntity(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

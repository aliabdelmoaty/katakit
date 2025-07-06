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

  AdditionEntity({
    required this.id,
    required this.batchId,
    required this.name,
    required this.cost,
    required this.date,
  });

  AdditionEntity copyWith({
    String? id,
    String? batchId,
    String? name,
    double? cost,
    DateTime? date,
  }) {
    return AdditionEntity(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      date: date ?? this.date,
    );
  }
} 
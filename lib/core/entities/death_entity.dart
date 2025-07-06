import 'package:hive/hive.dart';

part 'death_entity.g.dart';

@HiveType(typeId: 2)
class DeathEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String batchId;

  @HiveField(2)
  final int count;

  @HiveField(3)
  final DateTime date;

  DeathEntity({
    required this.id,
    required this.batchId,
    required this.count,
    required this.date,
  });

  DeathEntity copyWith({
    String? id,
    String? batchId,
    int? count,
    DateTime? date,
  }) {
    return DeathEntity(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      count: count ?? this.count,
      date: date ?? this.date,
    );
  }
}

import 'package:hive/hive.dart';

@HiveType(typeId: 100)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String type; // add/edit/delete
  @HiveField(2)
  final String entityType; // batch/addition/death/sale
  @HiveField(3)
  final Map<String, dynamic> data;
  @HiveField(4)
  final DateTime createdAt;

  SyncQueueItem({
    required this.id,
    required this.type,
    required this.entityType,
    required this.data,
    required this.createdAt,
  });
}

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 100;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem(
      id: fields[0] as String,
      type: fields[1] as String,
      entityType: fields[2] as String,
      data: (fields[3] as Map).cast<String, dynamic>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.entityType)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncQueueService {
  static const String _boxName = 'sync_queue';

  Future<void> addToQueue(SyncQueueItem item) async {
    final box = await Hive.openBox<SyncQueueItem>(_boxName);
    await box.add(item);
  }

  Future<List<SyncQueueItem>> getQueue() async {
    final box = await Hive.openBox<SyncQueueItem>(_boxName);
    return box.values.toList();
  }

  Future<void> removeFromQueue(String id) async {
    final box = await Hive.openBox<SyncQueueItem>(_boxName);
    final index = box.values.toList().indexWhere((item) => item.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  Future<void> clearQueue() async {
    final box = await Hive.openBox<SyncQueueItem>(_boxName);
    await box.clear();
  }
}

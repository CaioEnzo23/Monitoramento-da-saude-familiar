import 'package:hive_flutter/hive_flutter.dart';
import 'package:monitoramento_saude_familiar/models/Item_model.dart';

class ItemController {
  static const _itemNome = 'itemBox';
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_itemNome);
  }

  // Salva lista de tarefas no Hive
  Future<void> itemSave(Map<DateTime, List<ItemModel>> tasks) async {
    //transformando em lista
    final data = tasks.map(
      (key, value) =>
          MapEntry(key.toIso8601String(), value.map((t) => t.toMap()).toList()),
    );
    await _box.put('tasks', data);
  }

  // Carrega tarefas do Hive
  Map<DateTime, List<ItemModel>> itemCarregamento() {
    final raw = _box.get('item') ?? {};

    //convertendo em map
    return (raw as Map).map((key, value) {
      final date = DateTime.parse(key);
      final tasks = (value as List)
          .map((e) => ItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      return MapEntry(date, tasks);
    });
  }
}

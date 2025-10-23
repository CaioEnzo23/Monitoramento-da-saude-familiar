class ItemModel {
  final String titulo;
  final DateTime data;
  final String constancia;
  final List<String> diasSelecionados;

  ItemModel({
    required this.titulo,
    required this.data,
    required this.constancia,
    required this.diasSelecionados,
  });

  //para usar na hive
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'data': data.toIso8601String(),
      'constancia': constancia,
      'diasSelecionados': diasSelecionados,
    };
  }

  //Constrói a partir de Map
  factory ItemModel.fromMap(Map data) {
    return ItemModel(
      titulo: data['titulo'],
      data: DateTime.parse(data['data']),
      constancia: data['constancia'],
      diasSelecionados: List<String>.from(data['diasSelecionados'] ?? []),
    );
  }
}

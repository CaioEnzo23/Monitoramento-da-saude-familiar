import 'package:flutter/material.dart';
import 'Dialog_valor_saude_widget.dart'; // 👈 importe o arquivo do diálogo

class Item extends StatelessWidget {
  final String nome;
  final String status;
  final String? hora;
  final Map<String, dynamic>? valores;
  final VoidCallback? onDelete;
  final void Function(Map<String, String> values)? onValueSaved;
  final VoidCallback? onGraphTap;

  const Item({
    super.key,
    required this.nome,
    required this.status,
    this.hora,
    this.valores,
    this.onDelete,
    this.onValueSaved,
    this.onGraphTap,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.grey;
      case 'normal':
        return Colors.green;
      case 'alto':
        return Colors.redAccent;
      case 'baixo':
        return Colors.blueAccent;
      case 'preenchido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatValues() {
    if (valores == null || valores!.isEmpty) {
      return '';
    }

    final mappedValues = valores!.map((key, value) {
      final label = _humanizeKey(key);
      return MapEntry(label, value);
    });

    if (mappedValues.length == 1) {
      return mappedValues.values.first.toString();
    }

    return mappedValues.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('  •  ');
  }

  String _humanizeKey(String key) {
    switch (key) {
      case 'sistolica':
        return 'Sistólica';
      case 'diastolica':
        return 'Diastólica';
      case 'spo2':
        return 'SpO₂';
      case 'bpm':
        return 'BPM';
      case 'valor':
        return 'Valor';
      default:
        if (key.isEmpty) return key;
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedValues = _formatValues();

    return GestureDetector(
      onTap: () => abrirDialogValorSaude(
        context: context,
        nome: nome,
        onSave: onValueSaved ?? (valores) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Valores inseridos para $nome: $valores"),
              backgroundColor: Colors.black,
            ),
          );
        },
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formattedValues.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      formattedValues,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (hora != null) ...[
              Text(
                hora!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 12),
            ],
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            if (onGraphTap != null)
              GestureDetector(
                onTap: onGraphTap,
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

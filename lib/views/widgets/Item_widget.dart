import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/views/pages/Dash_page.dart';
import 'Dialog_valor_saude_widget.dart'; // 👈 importe o arquivo do diálogo

class Item extends StatelessWidget {
  final String nome;
  final String status;
  final String? hora;
  final VoidCallback? onDelete;
  final void Function(Map<String, String> values)? onValueSaved;
  final VoidCallback? onGraphTap;

  const Item({
    super.key,
    required this.nome,
    required this.status,
    this.hora,
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

  @override
  Widget build(BuildContext context) {
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
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                nome,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                if (hora != null)
                  Text(
                    hora!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                if (hora != null) const SizedBox(width: 8),
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
                const SizedBox(width: 16),
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
          ],
        ),
      ),
    );
  }
}

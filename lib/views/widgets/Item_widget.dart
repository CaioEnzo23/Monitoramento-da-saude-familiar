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

  Widget _buildValuesWidget() {
    if (valores == null || valores!.isEmpty) {
      return const SizedBox.shrink();
    }

    final valueStyle = const TextStyle(color: Colors.white70, fontSize: 13);
    List<Widget> valueWidgets = [];

    switch (nome) {
      case 'Oxigenação e Pulso':
        final spo2 = valores!['valor1'] ?? 'N/A';
        final bpm = valores!['valor2'] ?? 'N/A';
        valueWidgets.add(Text('SpO2: $spo2%', style: valueStyle));
        valueWidgets.add(Text('BPM: ${bpm}bpm', style: valueStyle));
        break;
      case 'Pressão Arterial':
        final sys = valores!['valor1'] ?? 'N/A';
        final dia = valores!['valor2'] ?? 'N/A';
        valueWidgets.add(Text('Sistólica: $sys mmHg', style: valueStyle));
        valueWidgets.add(Text('Diastólica: $dia mmHg', style: valueStyle));
        break;
      case 'Glicemia em Jejum':
      case 'Glicemia Pós Brandial':
        final valor = valores!['valor'] ?? 'N/A';
        valueWidgets.add(Text('$valor mg/dL', style: valueStyle));
        break;
      case 'Temperatura':
        final valor = valores!['valor'] ?? 'N/A';
        valueWidgets.add(Text('$valor °C', style: valueStyle));
        break;
      case 'Peso':
        final valor = valores!['valor'] ?? 'N/A';
        valueWidgets.add(Text('$valor kg', style: valueStyle));
        break;
      case 'Altura':
        final valor = valores!['valor'] ?? 'N/A';
        valueWidgets.add(Text('$valor m', style: valueStyle));
        break;
      default:
        final valuesString = valores!.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(', ');
        valueWidgets.add(Text(valuesString, style: valueStyle, overflow: TextOverflow.ellipsis));
        break;
    }

    if (valueWidgets.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: valueWidgets,
      );
    } else if (valueWidgets.isNotEmpty) {
      return valueWidgets.first;
    } else {
      return const SizedBox.shrink();
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
                  ),
                  if (valores != null && valores!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildValuesWidget(),
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

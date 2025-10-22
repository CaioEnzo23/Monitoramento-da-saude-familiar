import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/views/pages/dash_page.dart';
import 'Dialog_valor_saude_widget.dart'; // 👈 importe o arquivo do diálogo

class Item extends StatelessWidget {
  final String nome;
  final String status;

  const Item({super.key, required this.nome, required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'alto':
        return Colors.redAccent;
      case 'baixo':
        return Colors.blueAccent;
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
        onSave: (valor) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Valor inserido para $nome: $valor"),
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
            Text(
              nome,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Row(
              children: [
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    debugPrint('Ver estatísticas de $nome');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LineChartSample2(), // sua nova tela
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

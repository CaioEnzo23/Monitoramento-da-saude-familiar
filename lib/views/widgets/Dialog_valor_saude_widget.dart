import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogValorSaudeWidget extends StatelessWidget {
  final String nome;
  final void Function(Map<String, String> valores) onSave;

  const DialogValorSaudeWidget({
    super.key,
    required this.nome,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDialogContent(context);
  }

  Widget _buildDialogContent(BuildContext context) {
    switch (nome) {
      case 'Glicemia em Jejum':
      case 'Glicemia Pós Brandial':
        return _buildSingleValueDialog(context, nome, 'mg/dL');
      case 'Pressão Arterial':
        return _buildDualValueDialog(context, 'Pressão Sistólica', 'mmHg', 'sistolica', 'Pressão Diastólica', 'mmHg', 'diastolica');
      case 'Oxigenação e Pulso':
        return _buildDualValueDialog(context, 'Saturação de O2', '%', 'spo2', 'Batimentos por minuto', 'bpm', 'bpm');
      case 'Temperatura':
        return _buildSingleValueDialog(context, nome, '°C');
      default:
        return _buildSingleValueDialog(context, nome, 'Valor');
    }
  }

  Widget _buildSingleValueDialog(BuildContext context, String title, String unit) {
    final TextEditingController valorController = TextEditingController();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      title: Text(
        "Adicionar valor para $title",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        autofocus: true,
        controller: valorController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
        ],
        decoration: InputDecoration(
          labelText: "Digite o valor ($unit)",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      actions: _buildActions(context, {'valor': valorController}),
    );
  }

  Widget _buildDualValueDialog(BuildContext context, String title1, String unit1, String key1, String title2, String unit2, String key2) {
    final TextEditingController valor1Controller = TextEditingController();
    final TextEditingController valor2Controller = TextEditingController();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      title: Text(
        "Adicionar valor para $nome",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            controller: valor1Controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
            ],
            decoration: InputDecoration(
              labelText: "$title1 ($unit1)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: valor2Controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$')),
            ],
            decoration: InputDecoration(
              labelText: "$title2 ($unit2)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: _buildActions(context, {key1: valor1Controller, key2: valor2Controller}),
    );
  }

  List<Widget> _buildActions(BuildContext context, Map<String, TextEditingController> controllers) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Cancelar",
          style: TextStyle(color: Colors.black87),
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          final Map<String, String> valores = {};
          bool allFieldsFilled = true;
          controllers.forEach((key, controller) {
            final valor = controller.text.trim();
            if (valor.isNotEmpty) {
              valores[key] = valor;
            } else {
              allFieldsFilled = false;
            }
          });

          if (allFieldsFilled) {
            onSave(valores);
            Navigator.pop(context);
          }
        },
        child: const Text("Salvar", style: TextStyle(color: Colors.white)),
      ),
    ];
  }
}

void abrirDialogValorSaude({
  required BuildContext context,
  required String nome,
  required void Function(Map<String, String> valores) onSave,
}) {
  showDialog(
    context: context,
    builder: (context) => DialogValorSaudeWidget(nome: nome, onSave: onSave),
  );
}
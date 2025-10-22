import 'package:flutter/material.dart';

class DialogValorSaudeWidget extends StatelessWidget {
  final String nome;
  final void Function(String valor) onSave;

  const DialogValorSaudeWidget({
    super.key,
    required this.nome,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController valorController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      title: Text(
        "Adicionar valor para $nome",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        autofocus: true,
        enableSuggestions: false,
        autocorrect: false,

        controller: valorController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Digite o valor",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      actions: [
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
            String valor = valorController.text.trim();
            if (valor.isNotEmpty) {
              onSave(valor);
              Navigator.pop(context);
            }
          },
          child: const Text("Salvar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

void abrirDialogValorSaude({
  required BuildContext context,
  required String nome,
  required void Function(String valor) onSave,
}) {
  showDialog(
    context: context,
    builder: (context) => DialogValorSaudeWidget(nome: nome, onSave: onSave),
  );
}

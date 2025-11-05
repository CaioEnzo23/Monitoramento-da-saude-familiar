import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/models/crud_services.dart';
import 'package:monitoramento_saude_familiar/models/models.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _relacaoController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _nomeController.dispose();
    _relacaoController.dispose();
    super.dispose();
  }

  void _salvarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text;
      final relacao = _relacaoController.text;

      final newUser = User(
        nome: nome,
        relacao: relacao,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _userService.create(newUser);

      if (mounted) {
        Navigator.of(context).pop(); // Fecha o dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário "$nome" criado com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bem-vindo! Crie o primeiro usuário'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: João Silva',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um nome.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relacaoController,
              decoration: const InputDecoration(
                labelText: 'Relação',
                hintText: 'Ex: Pai, Mãe, Filho(a)',
              ),
               validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira uma relação.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvarUsuario,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

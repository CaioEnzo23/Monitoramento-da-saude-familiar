import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:monitoramento_saude_familiar/models/crud_services.dart';
import 'package:monitoramento_saude_familiar/views/widgets/add_user_dialog.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _selectedValue = DateTime.now();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Garante que o contexto está pronto antes de mostrar o dialog
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _verificarPrimeiroUsuario();
    });
  }

  void _verificarPrimeiroUsuario() async {
    final userCount = await _userService.count();
    if (userCount == 0 && mounted) {
      showDialog(
        context: context,
        // Impede o usuário de fechar o dialog sem criar um perfil
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AddUserDialog();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saúde Familiar'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DatePicker(
            DateTime.now(),
            height: 100,
            initialSelectedDate: _selectedValue,
            selectionColor: Colors.black,
            selectedTextColor: Colors.white,
            onDateChange: (date) {
              setState(() {
                _selectedValue = date;
              });
            },
          ),
          // O resto do conteúdo da sua página pode vir aqui
        ],
      ),
    );
  }
}

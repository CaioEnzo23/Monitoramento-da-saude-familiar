import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class BotaoFlutuanteWidget extends StatefulWidget {
  const BotaoFlutuanteWidget({super.key});

  @override
  State<BotaoFlutuanteWidget> createState() => _BotaoFlutuanteWidgetState();
}

class _BotaoFlutuanteWidgetState extends State<BotaoFlutuanteWidget> {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.blue,
          label: 'Criar',
          onTap: () {
            print('Editar clicado');
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.delete, color: Colors.white),
          backgroundColor: Colors.red,
          label: 'Deletar',
          onTap: () {
            print('Deletar clicado');
          },
        ),
      ],
    );
  }
}

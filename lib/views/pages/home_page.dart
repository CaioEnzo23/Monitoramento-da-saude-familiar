import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/views/widgets/calendario_widget.dart';
import 'package:monitoramento_saude_familiar/views/widgets/carrosel_slider_widget.dart';
import 'package:monitoramento_saude_familiar/views/widgets/item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[
                  SizedBox(height: 50),

                  CarroselSlider(),

                  SizedBox(height: 14),

                  Calendario(),

                  SizedBox(height: 14),

                  ListView(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Item(nome: 'teste', status: 'alto'),
                      Item(nome: 'teste', status: 'normal'),
                      Item(nome: 'teste', status: 'baixo'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
          tooltip: 'Increment',
          onPressed: () {},
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

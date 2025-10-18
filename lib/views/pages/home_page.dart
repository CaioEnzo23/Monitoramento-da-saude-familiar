import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:monitoramento_saude_familiar/views/widgets/item_monitoramento.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedValue = DateTime.now();

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

                  CarouselSlider(
                    items: [
                      for (int i = 0; i < 2; i++)
                        Container(
                          margin: EdgeInsets.all(11),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: Text(
                            'Perfil $i',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),
                        ),
                    ],
                    options: CarouselOptions(height: 80),
                  ),

                  SizedBox(height: 14),

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
                  SizedBox(height: 14),

                  ListView(
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
                      ItemMonitoramento(),
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

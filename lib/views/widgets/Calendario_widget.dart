import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';

class Calendario extends StatefulWidget {
  final Function(DateTime) onDateChange;
  const Calendario({super.key, required this.onDateChange});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  DateTime _selectedValue = DateTime.now();

  @override
  Widget build(BuildContext context) {
    
    return DatePicker(
      
      DateTime.now(),
      height: 100,
      initialSelectedDate: _selectedValue,
      selectionColor: Colors.green,
      selectedTextColor: Colors.white,
      onDateChange: (date) {
        setState(() {
          _selectedValue = date;
          widget.onDateChange(date);
        });
      },
    );
  }
}

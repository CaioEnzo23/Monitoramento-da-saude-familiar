import 'package:flutter/material.dart';

class ItemMonitoramento extends StatelessWidget {
  const ItemMonitoramento({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text("item", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

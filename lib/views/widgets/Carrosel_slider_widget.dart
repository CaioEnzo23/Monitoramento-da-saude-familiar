import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarroselSlider extends StatefulWidget {
  const CarroselSlider({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CarroselSliderState createState() => _CarroselSliderState();
}

class _CarroselSliderState extends State<CarroselSlider> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
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
    );
  }
}

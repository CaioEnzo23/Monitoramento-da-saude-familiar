import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/models/profile_model.dart';

class CarroselSlider extends StatelessWidget {
  final List<Profile> profiles;
  final void Function(int index, CarouselPageChangedReason reason)? onPageChanged;
  final VoidCallback onAddProfile;
  final Function(int) onDeleteProfile;

  const CarroselSlider({
    super.key,
    required this.profiles,
    this.onPageChanged,
    required this.onAddProfile,
    required this.onDeleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        ...profiles.asMap().entries.map((entry) {
          int index = entry.key;
          Profile profile = entry.value;
          return Container(
            margin: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(21),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        profile.nome,
                        style: const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onDeleteProfile(index),
                    child: Container(
                      width: 50,
                      color: Colors.red,
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        GestureDetector(
          onTap: onAddProfile,
          child: Container(
            margin: const EdgeInsets.all(11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(21),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
      options: CarouselOptions(
        height: 100,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
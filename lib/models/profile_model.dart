import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 0)
class Profile {
  @HiveField(0)
  final String nome;

  @HiveField(1)
  final int idade;

  @HiveField(2)
  final double peso;

  @HiveField(3)
  final double altura;

  Profile({required this.nome, required this.idade, required this.peso, required this.altura});
}

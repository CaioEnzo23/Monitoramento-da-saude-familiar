// ----- User Model -----
class User {
  final int? id;
  final String nome;
  final String? relacao;
  final String? updatedAt;
  final String? createdAt;

  User({
    this.id,
    required this.nome,
    this.relacao,
    this.updatedAt,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'relacao': relacao,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      relacao: map['relacao'],
      updatedAt: map['updated_at'],
      createdAt: map['created_at'],
    );
  }
}

// ----- Atributo Model -----
class Atributo {
  final int? id;
  final String nomeAtributo;
  final String? unidadeMedida;
  final String? createdAt;

  Atributo({
    this.id,
    required this.nomeAtributo,
    this.unidadeMedida,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_atributo': nomeAtributo,
      'unidade_medida': unidadeMedida,
      'created_at': createdAt,
    };
  }

  factory Atributo.fromMap(Map<String, dynamic> map) {
    return Atributo(
      id: map['id'],
      nomeAtributo: map['nome_atributo'],
      unidadeMedida: map['unidade_medida'],
      createdAt: map['created_at'],
    );
  }
}

// ----- HistoricoAtributo Model -----
class HistoricoAtributo {
  final int? id;
  final int userId;
  final int atributoId;
  final String valorAtributo;
  final String? createdAt;

  HistoricoAtributo({
    this.id,
    required this.userId,
    required this.atributoId,
    required this.valorAtributo,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'atributo_id': atributoId,
      'valor_atributo': valorAtributo,
      'created_at': createdAt,
    };
  }

  factory HistoricoAtributo.fromMap(Map<String, dynamic> map) {
    return HistoricoAtributo(
      id: map['id'],
      userId: map['user_id'],
      atributoId: map['atributo_id'],
      valorAtributo: map['valor_atributo'],
      createdAt: map['created_at'],
    );
  }
}

// ----- Remedio Model -----
class Remedio {
  final int? id;
  final String remedioNome;
  final String? createdAt;

  Remedio({
    this.id,
    required this.remedioNome,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remedio_nome': remedioNome,
      'created_at': createdAt,
    };
  }

  factory Remedio.fromMap(Map<String, dynamic> map) {
    return Remedio(
      id: map['id'],
      remedioNome: map['remedio_nome'],
      createdAt: map['created_at'],
    );
  }
}

// ----- RemediosDose Model -----
class RemediosDose {
  final int? id;
  final int remedioId;
  final int userId;
  final bool doseAtiva;
  final double valorDose;
  final String medida;
  final String? updatedAt;
  final String? createdAt;

  RemediosDose({
    this.id,
    required this.remedioId,
    required this.userId,
    this.doseAtiva = true,
    required this.valorDose,
    required this.medida,
    this.updatedAt,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remedio_id': remedioId,
      'user_id': userId,
      'dose_ativa': doseAtiva ? 1 : 0, // Converte bool para integer
      'valor_dose': valorDose,
      'medida': medida,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }

  factory RemediosDose.fromMap(Map<String, dynamic> map) {
    return RemediosDose(
      id: map['id'],
      remedioId: map['remedio_id'],
      userId: map['user_id'],
      doseAtiva: map['dose_ativa'] == 1, // Converte integer para bool
      valorDose: map['valor_dose'],
      medida: map['medida'],
      updatedAt: map['updated_at'],
      createdAt: map['created_at'],
    );
  }
}
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart'; // Importe o helper
import 'models.dart'; // Importe os modelos

// ----- CRUD para a tabela 'users' -----
class UserService {
  final String _table = 'users';
  
  // Create
  Future<int> create(User user) async {
    Database db = await DatabaseHelper.instance.database;
    // O 'user.toMap()' é usado aqui
    return await db.insert(_table, user.toMap());
  }

  // Read (Single User by ID) - Retorna JSON
  Future<Map<String, dynamic>?> get(int id) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Read (All Users) - Retorna Lista de JSON
  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(_table);
  }

  // Update
  Future<int> update(User user) async {
    Database db = await DatabaseHelper.instance.database;
    // Atualiza o campo 'updated_at' antes de salvar
    User userToUpdate = User(
      id: user.id,
      nome: user.nome,
      relacao: user.relacao,
      createdAt: user.createdAt,
      updatedAt: DateTime.now().toIso8601String(), // Atualiza o timestamp
    );
    
    return await db.update(
      _table,
      userToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Count Users
  Future<int> count() async {
    Database db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

// ----- CRUD para a tabela 'atributos' -----
class AtributoService {
  final String _table = 'atributos';
  
  Future<int> create(Atributo atributo) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(_table, atributo.toMap());
  }

  Future<Map<String, dynamic>?> get(int id) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(_table);
  }

  Future<int> update(Atributo atributo) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      _table,
      atributo.toMap(),
      where: 'id = ?',
      whereArgs: [atributo.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ----- CRUD para a tabela 'historico_atributos' -----
class HistoricoAtributoService {
  final String _table = 'historico_atributos';
  
  Future<int> create(HistoricoAtributo historico) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(_table, historico.toMap());
  }

  Future<Map<String, dynamic>?> get(int id) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Função útil: Pegar todo o histórico de um usuário específico
  Future<List<Map<String, dynamic>>> getByUserId(int userId) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC', // Ordena pelo mais recente
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(_table);
  }

  Future<int> update(HistoricoAtributo historico) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      _table,
      historico.toMap(),
      where: 'id = ?',
      whereArgs: [historico.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


// ----- CRUD para a tabela 'remedios' -----
class RemedioService {
  final String _table = 'remedios';
  
  Future<int> create(Remedio remedio) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(_table, remedio.toMap());
  }

  Future<Map<String, dynamic>?> get(int id) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(_table);
  }

  Future<int> update(Remedio remedio) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      _table,
      remedio.toMap(),
      where: 'id = ?',
      whereArgs: [remedio.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ----- CRUD para a tabela 'remedios_doses' -----
class RemediosDoseService {
  final String _table = 'remedios_doses';
  
  Future<int> create(RemediosDose dose) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(_table, dose.toMap());
  }

  Future<Map<String, dynamic>?> get(int id) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Função útil: Pegar todas as doses de um usuário
  Future<List<Map<String, dynamic>>> getByUserId(int userId) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(_table);
  }

  Future<int> update(RemediosDose dose) async {
    Database db = await DatabaseHelper.instance.database;
    // Atualiza o campo 'updated_at' antes de salvar
    RemediosDose doseToUpdate = RemediosDose(
      id: dose.id,
      remedioId: dose.remedioId,
      userId: dose.userId,
      doseAtiva: dose.doseAtiva,
      valorDose: dose.valorDose,
      medida: dose.medida,
      createdAt: dose.createdAt,
      updatedAt: DateTime.now().toIso8601String(), // Atualiza o timestamp
    );

    return await db.update(
      _table,
      doseToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [dose.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Habilitar chaves estrangeiras
    await db.execute('PRAGMA foreign_keys = ON');

    // Tabela Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        relacao TEXT,
        updated_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabela Atributos
    await db.execute('''
      CREATE TABLE atributos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_atributo TEXT NOT NULL UNIQUE,
        unidade_medida TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabela Historico Atributos
    await db.execute('''
      CREATE TABLE historico_atributos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        atributo_id INTEGER NOT NULL,
        valor_atributo TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (atributo_id) REFERENCES atributos (id) ON DELETE CASCADE
      )
    ''');

    // Tabela Remedios
    await db.execute('''
      CREATE TABLE remedios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remedio_nome TEXT NOT NULL UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabela Remedios Doses
    await db.execute('''
      CREATE TABLE remedios_doses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remedio_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        dose_ativa INTEGER DEFAULT 1, -- 1 para true, 0 para false
        valor_dose REAL NOT NULL, -- REAL para decimal
        medida TEXT NOT NULL,
        updated_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (remedio_id) REFERENCES remedios (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }
}
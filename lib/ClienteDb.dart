import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class ClienteDb {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE clientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nome TEXT,
        telefone text,
        endereco text,
        comidafav text,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'softCliente.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(
      String nome, String telefone, String endereco, String comidafav) async {
    final db = await ClienteDb.db();

    final data = {
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
      'comidafav': comidafav
    };
    final id = await db.insert('clientes', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await ClienteDb.db();
    return db.query('clientes', orderBy: "id");
  }

  static Future<int> updateItem(int id, String nome, String telefone,
      String endereco, String comidafav) async {
    final db = await ClienteDb.db();

    final data = {
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
      'comidafav': comidafav,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('clientes', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await ClienteDb.db();
    try {
      await db.delete("clientes", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Erro: $err");
    }
  }
}

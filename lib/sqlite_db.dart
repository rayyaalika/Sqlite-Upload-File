import 'package:sqflite_upload_file/model/foto.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static Future<sql.Database> db() async {
    return sql.openDatabase(join(await sql.getDatabasesPath(), 'catatan.db'),
        version: 1, onCreate: (database, version) async {
          await database.execute("""
        CREATE TABLE foto (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          judul TEXT,
          deskripsi TEXT,
          photo TEXT
        )
      """);
        });
  }

  static Future<int> tambahFoto(Foto foto) async {
    final db = await DatabaseHelper.db();
    final data = foto.toList();
    return db.insert('foto', data);
  }

  static Future<List<Map<String, dynamic>>> getFoto() async {
    final db = await DatabaseHelper.db();
    return db.query("foto");
  }

  static Future<int> updateFoto(Foto foto) async {
    final db = await DatabaseHelper.db();
    final data =  foto.toList();
    return db.update('foto', data, where: "id=?", whereArgs: [foto.id]);
  }

  static Future<int> deleteFoto(int id) async {
    final db = await DatabaseHelper.db();
    return db.delete('foto', where: 'id=$id');
  }

}

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/plant.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mis_plantas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        especie TEXT NOT NULL,
        fechaUltimoRiego TEXT NOT NULL,
        fechaUltimoAbono TEXT NOT NULL,
        frecuenciaRiegoDias INTEGER NOT NULL,
        frecuenciaAbonoDias INTEGER NOT NULL,
        localImagePath TEXT NOT NULL,
        ubicacion TEXT,
        estadoSalud TEXT,
        exposicionSolar TEXT,
        humedadOptima TEXT,
        recordatorioActivo INTEGER DEFAULT 1
      )
    ''');

    // Semillas iniciales exactas de DESIGN.md
    final now = DateTime.now();
    final seedPlants = [
      Plant(
        id: 'anturio-01',
        nombre: 'Anturio',
        especie: 'Anthurium Andreanum',
        fechaUltimoRiego: now.subtract(const Duration(days: 4)),
        fechaUltimoAbono: now.subtract(const Duration(days: 12)),
        frecuenciaRiegoDias: 4,
        frecuenciaAbonoDias: 20,
        localImagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAF7hbpbngQTil3E1tpR8-k-w5QoxNhitxKBKXVakCGBfnHlwLG1gghDzzIQjCpjqfz50chyyASki0dS-bBIKggIixRpx8rk4bygKj-s2-muNT1wl_m4a1yXnStemWaDqrx0Ty5cA_TzQlciq3lTA3xUcOSYEs4SliPT8-tiDTn85kbKPNTlMSsijaO59DG_p9ja3AMzguj7d4eLvE5gIefWH6ITfaWfLwKTiNzFbGRm07IZ-aK7-Sdlw',
        ubicacion: 'Habitación',
        estadoSalud: 'urgente',
      ),
      Plant(
        id: 'suculenta-02',
        nombre: 'Suculenta',
        especie: 'Echeveria Elegans',
        fechaUltimoRiego: now.subtract(const Duration(days: 11)),
        fechaUltimoAbono: now.subtract(const Duration(days: 31)),
        frecuenciaRiegoDias: 12,
        frecuenciaAbonoDias: 45,
        localImagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDcV5P6okvjmX_zOQhDX1a3NqLdS_0kaz0sHFER0YQ8fan1PvHpD7oPB1ln-a3XcPLWBHWSvaqDOU41eR2TEi4ylJBP2E7oDOtm0OA2-NTd9cCZTFcsttm8hQjqnejdhkA5zYuZ2AJKTlXopt4GkNcu7b4ubJHehENKjgQ7Mwzv1FR9Kp2Tvtod691iYrf-Oh04KQIzb15gbBMpossQgc-SzkLtIPYLlMB2hjZjClH-jA3yT2IfV5mstQ',
        ubicacion: 'En la terraza',
        estadoSalud: 'atencion',
      ),
      Plant(
        id: 'bonsai-03',
        nombre: 'Bonsái',
        especie: 'Ficus Retusa',
        fechaUltimoRiego: now.subtract(const Duration(days: 1)),
        fechaUltimoAbono: now.subtract(const Duration(days: 10)),
        frecuenciaRiegoDias: 3,
        frecuenciaAbonoDias: 15,
        localImagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAi8GHGn5jefJpOIkKJKsg5Up8UgPKw8IzLe5NcwbLEh6aiW1casR6X-J-CNYUp0oRu4BLSzgH1sdxOsQhoUuRhFyRHZeWEqw-0wBovJUZPJd6lKjrtbr7XHIGDyYYk2Jj6CrcJ9zA7k3RYhxTR16YjIWqFasxKbMLWt_4idXf5oWKUSF5SDqalthyLUrFq_0ii-LL4noOzPbKvPmdhlKB19D2NWncjAboJvbEcS670iJI_fLntWpR0uw',
        ubicacion: 'Escritorio',
        estadoSalud: 'saludable',
      ),
      Plant(
        id: 'ficus-04',
        nombre: 'Ficus',
        especie: 'Ficus Lyrata',
        fechaUltimoRiego: now.subtract(const Duration(days: 4)),
        fechaUltimoAbono: now.subtract(const Duration(days: 18)),
        frecuenciaRiegoDias: 7,
        frecuenciaAbonoDias: 30,
        localImagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC4F6zemv0hDOZjT5O4V9Il2cRCZEQYIDmUwpFNRLC3CUgHgqcQ53ACtYnccxpMo2W9uqiPwnhm8A5JJZzW13fMNiOgeeAxDsUVAKaMB4xQdfHLz9rQF-Xk_cEZL8E5BRYXUJmNOfyIicPqzJp7SuNvHtdMTjWkYJioKKQcQXrjHfDLZa-sGqeynGse5ayKYmsmiW9a9Pox2_bQXeDoTVDJRW7QxsJLLJo_cOSpODv-Bx1qkbLAhX9kQg',
        ubicacion: 'Comedor • Interior',
        estadoSalud: 'saludable',
      ),
      Plant(
        id: 'jade-05',
        nombre: 'Jade',
        especie: 'Crassula Ovata',
        fechaUltimoRiego: now.subtract(const Duration(days: 6)),
        fechaUltimoAbono: now.subtract(const Duration(days: 10)),
        frecuenciaRiegoDias: 10,
        frecuenciaAbonoDias: 30,
        localImagePath: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBah26ccGDexf9cPIb42QGUx5Ie4_sKP8qRcNwJp6Q2Kuba8WLFTdMcxydEYXXoelxDkYuYUCv7E2_L00wCg-btSxiCBekByKwDIbUNzEZx7W8caWPf8EAl1Lt6NvtHan81ZmgoXrTj6UNqilaq3Pmigbg_kP-Bi0jUJzy33koZxEOQJEha8cs2nGSa-_DhrO0iLc6uAObhqTwOaWK09zWNzHR_FIZ2EQD9vD54zEWgd16FLfLKSg4DsQ',
        ubicacion: 'Salón principal',
        estadoSalud: 'saludable',
      ),
    ];

    for (final plant in seedPlants) {
      await db.insert('plants', plant.toMap());
    }
  }

  Future<List<Plant>> getAllPlants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('plants');
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }

  Future<int> insertPlant(Plant plant) async {
    final db = await database;
    return await db.insert('plants', plant.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updatePlant(Plant plant) async {
    final db = await database;
    return await db.update('plants', plant.toMap(), where: 'id = ?', whereArgs: [plant.id]);
  }

  Future<int> deletePlant(String id) async {
    final db = await database;
    return await db.delete('plants', where: 'id = ?', whereArgs: [id]);
  }

  /// Acción rápida: registrar riego hoy
  Future<void> registrarRiego(String id) async {
    final db = await database;
    await db.update(
      'plants',
      {'fechaUltimoRiego': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Acción rápida: registrar abono hoy
  Future<void> registrarAbono(String id) async {
    final db = await database;
    await db.update(
      'plants',
      {'fechaUltimoAbono': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'package:sqflite/sqflite.dart';

import '../db.dart';

class Partida {
  final int? id;
  final String fechaFin;
  final int duracionSegundos;
  final int aciertos;
  final int fallos;
  final int jugadorId;

  Partida(
      {this.id,
      required this.fechaFin,
      required this.duracionSegundos,
      required this.aciertos,
      required this.fallos,
      required this.jugadorId});

  Partida.partidasFromMap(Map<String, dynamic> item)
      : id = item["id"],
        fechaFin = item["fechaFin"],
        duracionSegundos = item["duracionSegundos"],
        aciertos = item["aciertos"],
        fallos = item["fallos"],
        jugadorId = item["jugadorId"];

  Map<String, Object> partidasToMap() {
    return {
      'fechaFin': fechaFin,
      'duracionSegundos': duracionSegundos,
      'aciertos': aciertos,
      'fallos': fallos,
      'jugadorId': jugadorId
    };
  }

  @override
  String toString() {
    return 'Partida {id: $id, fechaFin: $fechaFin, duracionSegundos: $duracionSegundos,'
        'aciertos: $aciertos, fallos: $fallos, jugadorId: $jugadorId}';
  }
}

// metodo para insertar un jugador en la BBDD
Future<int> insertPartida(Partida partida) async {
  Database database = await initializeDB();
  int id = await database.insert("partida", partida.partidasToMap());
  return id;
}

// Método para obtener las partidas de un jugador dado su userId
Future<List<Partida>> getPartidasByUserId(int jugadorId) async {
  Database database = await initializeDB();
  List<Map<String, dynamic>> result = await database.query(
    'partida',
    where: 'jugadorId = ?',
    whereArgs: [jugadorId],
    orderBy: 'id DESC', // Ordenar por id en orden descendente
  );

  // Mapear los resultados a objetos Partida
  List<Partida> partidas =
      result.map((item) => Partida.partidasFromMap(item)).toList();

  return partidas;
}
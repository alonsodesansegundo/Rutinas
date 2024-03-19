import 'package:sqflite/sqflite.dart';

import '../../obj/PartidasPaginacion.dart';
import '../db.dart';
import 'grupo.dart';

class PartidaView {
  final int? id;
  final String fechaFin;
  final int duracionSegundos;
  final int aciertos;
  final int fallos;
  final String jugadorName;
  final String grupoName;

  PartidaView(
      {this.id,
      required this.fechaFin,
      required this.duracionSegundos,
      required this.aciertos,
      required this.fallos,
      required this.jugadorName,
      required this.grupoName});

  PartidaView.partidasFromMap(Map<String, dynamic> item)
      : id = item["id"],
        fechaFin = item["fechaFin"],
        duracionSegundos = item["duracionSegundos"],
        aciertos = item["aciertos"],
        fallos = item["fallos"],
        jugadorName = item["jugadorName"],
        grupoName = item["grupoName"];

  Map<String, Object> partidasToMap() {
    return {
      'fechaFin': fechaFin,
      'duracionSegundos': duracionSegundos,
      'aciertos': aciertos,
      'fallos': fallos,
      'jugadorName': jugadorName,
      'grupoName': grupoName
    };
  }

  @override
  String toString() {
    return 'Partida {id: $id, fechaFin: $fechaFin, duracionSegundos: $duracionSegundos,'
        'aciertos: $aciertos, fallos: $fallos, jugadorName: $jugadorName, grupoName: $grupoName}';
  }
}

Future<PartidasPaginacion> getAllPartidasView(
    int pageNumber, int pageSize, String txtNombre, Grupo? grupo) async {
  try {
    final Database db = await initializeDB();
    int offset = (pageNumber - 1) * pageSize;
    String whereClause = '';

    // Agregar condiciones de búsqueda por nombre de jugador y nombre de grupo
    if (txtNombre.isNotEmpty) {
      whereClause += " WHERE jugador.nombre LIKE '%$txtNombre%'";
    }
    if (grupo != null) {
      whereClause += (whereClause.isEmpty ? ' WHERE' : ' AND');
      whereClause += " grupo.id = ${grupo.id}";
    }

    final List<Map<String, dynamic>> partidasMap = await db.rawQuery('''
      SELECT partida.*, jugador.nombre AS jugadorName, grupo.nombre AS grupoName
      FROM partida
      JOIN jugador ON partida.jugadorId = jugador.id
      JOIN grupo ON jugador.grupoId = grupo.id
      $whereClause
      ORDER BY fechaFin DESC
      LIMIT $pageSize OFFSET $offset
    ''');
    final List<PartidaView> partidas =
        partidasMap.map((map) => PartidaView.partidasFromMap(map)).toList();

    // Comprobar si hay más preguntas disponibles
    final List<Map<String, dynamic>> totalPreguntasMap = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM partida
      JOIN jugador ON partida.jugadorId = jugador.id
      JOIN grupo ON jugador.grupoId = grupo.id
      $whereClause
    ''');
    final int totalPartidas =
        totalPreguntasMap.isNotEmpty ? totalPreguntasMap[0]['total'] : 0;
    final bool hayMasPartidas = offset + pageSize < totalPartidas;

    return PartidasPaginacion(partidas, hayMasPartidas);
  } catch (e) {
    print("Error al obtener preguntas: $e");
    return PartidasPaginacion([], false);
  }
}
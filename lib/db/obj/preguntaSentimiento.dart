import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../obj/PreguntaSentimientoPaginacion.dart';
import '../db.dart';
import '../sentimientosScripts/adolescencia.dart';
import '../sentimientosScripts/atenciont.dart';
import '../sentimientosScripts/infancia.dart';
import 'nivel.dart';

///Clase relativa a la tabla PreguntaSentimiento
class PreguntaSentimiento {
  final int? id;
  final String enunciado;
  final Uint8List? imagen;
  final int nivelId;
  final String fecha;
  final int byTerapeuta;

  ///Constructor de la clase PreguntaSentimiento
  PreguntaSentimiento(
      {this.id,
      required this.enunciado,
      this.imagen,
      required this.nivelId,
      required this.fecha,
      required this.byTerapeuta});

  ///Crea una instancia de PreguntaSentimiento a partir de un mapa de datos, dicho mapa debe contener:
  ///id, enunciado, imagen, nivelId, fecha y byTerapeuta
  PreguntaSentimiento.sentimientosFromMap(Map<String, dynamic> item)
      : id = item["id"],
        enunciado = item["enunciado"],
        imagen = item["imagen"],
        nivelId = item["nivelId"],
        fecha = item["fecha"],
        byTerapeuta = item["byTerapeuta"];

  ///Convierte una instancia de PreguntaSentimientos a un mapa de datos
  Map<String, Object> sentimientosToMap() {
    return {
      'enunciado': enunciado,
      'nivelId': nivelId,
      'fecha': fecha,
      'byTerapeuta': byTerapeuta
    };
  }

  ///Sobreescritura del método equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PreguntaSentimiento &&
        other.id == id &&
        other.enunciado == enunciado &&
        other.nivelId == nivelId &&
        other.fecha == fecha &&
        other.byTerapeuta == byTerapeuta;
  }

  ///Sobreescritura del método hashCode
  @override
  int get hashCode =>
      id.hashCode ^
      enunciado.hashCode ^
      nivelId.hashCode ^
      fecha.hashCode ^
      byTerapeuta.hashCode;

  ///Sobreescritura del método toString
  @override
  String toString() {
    return 'PreguntaSentimiento {id: $id, enunciado: $enunciado,'
        ' imagen: $imagen, '
        'nivelId: $nivelId}, '
        'fecha: $fecha}, '
        'byTerapeuta: $byTerapeuta, ';
  }
}

///Método que nos permite obtener todas las preguntas de un nivel del juego Sentimientos
///<br><b>Parámetros</b><br>
///[nivelId] Identificador del nivel que queremos obtener las preguntas<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///Lista de las preguntas del juego Sentimientos
Future<List<PreguntaSentimiento>> getPreguntasSentimiento(int nivelId,
    [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    final List<Map<String, dynamic>> preguntasMap = await database.query(
        'preguntaSentimiento',
        where: 'nivelId = ?',
        whereArgs: [nivelId]);
    return preguntasMap
        .map((map) => PreguntaSentimiento.sentimientosFromMap(map))
        .toList();
  } catch (e) {
    print("Error al obtener preguntas sentimientos: $e");
    return [];
  }
}

///Método que nos permite obtener las preguntas del juego Sentimientos de forma paginada. Usado para el
///punto de vista del terapeuta
///<br><b>Parámetros</b><br>
///[pageNumber] Página de la que queremos obtener los resultados. Comenzamos en la página 1<br>
///[pageSize] Cantidad de resultados que queremos obtener por página<br>
///[txtBuscar] Texto de la pregunta para filtrar la búsqueda<br>
///[nivel] Nivel para filtrar la búsqueda<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///Resultado de la búsqueda con paginación
Future<PreguntaSentimientoPaginacion> getPreguntaSentimientoPaginacion(
    int pageNumber, int pageSize, String txtBuscar, Nivel? nivel,
    [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    int offset = (pageNumber - 1) * pageSize;
    String whereClause = '';

    // Agregar condiciones de búsqueda por enunciado y nivel
    if (txtBuscar.isNotEmpty) {
      whereClause += "enunciado LIKE '%$txtBuscar%'";
    }
    if (nivel != null) {
      whereClause +=
          (whereClause.isNotEmpty ? ' AND ' : '') + "nivelId = ${nivel.id}";
    }

    final List<Map<String, dynamic>> preguntasMap = await database.query(
      'preguntaSentimiento',
      where: whereClause.isEmpty ? null : whereClause,
      orderBy: 'id DESC',
      limit: pageSize,
      offset: offset,
    );
    final List<PreguntaSentimiento> preguntas = preguntasMap
        .map((map) => PreguntaSentimiento.sentimientosFromMap(map))
        .toList();

    // Comprobar si hay más preguntas disponibles
    final List<Map<String, dynamic>> totalSituacionesMap = await database.query(
        'preguntaSentimiento',
        where: whereClause.isEmpty ? null : whereClause);
    final bool hayMasPreguntas =
        (offset + pageSize) < totalSituacionesMap.length;

    return PreguntaSentimientoPaginacion(preguntas, hayMasPreguntas);
  } catch (e) {
    print("Error al obtener preguntas situaciones: $e");
    return PreguntaSentimientoPaginacion([], false);
  }
}

///Método que nos permite insertar una nueva pregunta al juego Sentimientos
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones<br>
///[enunciado] Enunciado de la pregunta<br>
///[imgPersonaje] Lista de enteros que es la imagen del personaje<br>
///[nivelId] Identificador del nivel al que va a pertenecer la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta que ha sido añadida
Future<int> insertPreguntaSentimiento(Database database, String enunciado,
    List<int> imgPersonaje, int nivelId) async {
  int id = -1;
  await database.transaction((txn) async {
    if (imgPersonaje.isEmpty)
      id = await txn.rawInsert(
        "INSERT INTO preguntaSentimiento (enunciado, imagen, nivelId, byTerapeuta, fecha) VALUES (?, ?, ?, ?, ?)",
        [
          enunciado,
          null,
          nivelId,
          1,
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
        ],
      );
    else
      id = await txn.rawInsert(
        "INSERT INTO preguntaSentimiento (enunciado, imagen, nivelId, byTerapeuta, fecha) VALUES (?, ?, ?, ?, ?)",
        [
          enunciado,
          imgPersonaje,
          nivelId,
          1,
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
        ],
      );
  });

  return id;
}

///Método que nos permite insertar las preguntas por defecto del juego Sentimientos
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones<br>
///[enunciado] Enunciado de la pregunta<br>
///[pathImg] Ruta en la que se encuentra la imagen del personaje<br>
///[nivelId] Identificador del nivel al que va a pertenecer la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta que ha sido añadida
Future<int> insertPreguntaSentimientoInitialData(
    Database database, String enunciado, String pathImg, int nivelId) async {
  int id = -1;
  ByteData imageData = await rootBundle.load(pathImg);
  List<int> bytes = imageData.buffer.asUint8List();
  await database.transaction((txn) async {
    id = await txn.rawInsert(
      "INSERT INTO preguntaSentimiento (enunciado, imagen, nivelId, fecha) VALUES (?, ?, ?, ?)",
      [
        enunciado,
        bytes,
        nivelId,
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
      ],
    );
  });

  return id;
}

///Método que nos permite eliminar una pregunta del juego Sentimientos a partir de su identificador
///<br><b>Parámetros</b><br>
///[preguntaSentimientoId] Identificador de la pregunta del juego Sentimientos que queremos eliminar<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
Future<void> removePreguntaSentimiento(int preguntaSentimientoId,
    [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    await database.delete(
      'preguntaSentimiento',
      where: 'id = ?',
      whereArgs: [preguntaSentimientoId],
    );
  } catch (e) {
    print('Error al eliminar la pregunta sentimiento: $e');
  }
}

///Método que nos permite actualizar una pregunta del juego Sentimientos
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecuta la actualización<br>
///[id] Identificador de la pregunta que queremos actualizar<br>
///[enunciado] Nuevo valor del enunciado<br>
///[imgPersonaje] Nueva lista de enteros que representa la imagen del personaje<br>
///[nivelId] Nuevo valor del nivel al que pertenece la pregunta
Future<void> updatePregunta(Database database, int id, String enunciado,
    List<int> imgPersonaje, int nivelId,
    [Database? db]) async {
  final Database database = db ?? await initializeDB();
  if (imgPersonaje.isEmpty)
    await database.update(
      'preguntaSentimiento',
      {
        'enunciado': enunciado,
        'imagen': null,
        'nivelId': nivelId,
        'fecha': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  else
    await database.update(
      'preguntaSentimiento',
      {
        'enunciado': enunciado,
        'imagen': imgPersonaje,
        'nivelId': nivelId,
        'fecha': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [id],
    );
}

///Método que se encarga de hacer la insercción de las preguntas del juego Sentimientos que están presentes inicialmente
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones
void insertSentimientos(Database database) {
  insertPreguntaSentimientoInitialDataAtencionT(database);
  insertPreguntaSentimientoInitialDataInfancia(database);
  insertPreguntaSentimientoInitialDataAdolescencia(database);
}

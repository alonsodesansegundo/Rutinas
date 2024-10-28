import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../obj/SituacionRutinaPaginacion.dart';
import '../db.dart';
import '../rutinasScripts/adolescencia.dart';
import '../rutinasScripts/atenciont.dart';
import '../rutinasScripts/infancia.dart';
import 'nivel.dart';

///Clase relativa a la tabla SituacionRutina
class SituacionRutina {
  final int? id;
  final String enunciado;
  final Uint8List? personajeImg;
  final int nivelId;
  final String fecha;
  final int byTerapeuta;

  ///Constructor de la clase SituacionRutina
  SituacionRutina(
      {this.id,
      required this.enunciado,
      this.personajeImg,
      required this.nivelId,
      required this.fecha,
      required this.byTerapeuta});

  ///Crea una instancia de SituacionRutina a partir de un mapa de datos, dicho mapa debe contener:
  ///id, enunciado, personajeImg, nivelId, fecha y byTerapeuta
  SituacionRutina.situacionesFromMap(Map<String, dynamic> item)
      : id = item["id"],
        enunciado = item["enunciado"],
        personajeImg = item["personajeImg"],
        nivelId = item["nivelId"],
        fecha = item["fecha"],
        byTerapeuta = item["byTerapeuta"];

  ///Crea una instancia de SituacionIronia a partir de un mapa de datos, dicho mapa debe contener:
  ///id, enunciado, imagen, nivelId, fecha y byTerapeuta
  Map<String, Object> situacionesToMap() {
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

    return other is SituacionRutina &&
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
    return 'SituacionRutina {id: $id, enunciado: $enunciado,'
        ' personajeImg: $personajeImg, '
        'nivelId: $nivelId}, '
        'fecha: $fecha}, '
        'byTerapeuta: $byTerapeuta, ';
  }
}

///Método que nos permite obtener las preguntas del juego Rutinas
///<br><b>Parámetros</b><br>
///[nivelId] Identificador del nivel del que queremos obtener las preguntas<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///Lista de preguntas del juego Rutinas pertenecientes al nivelId
Future<List<SituacionRutina>> getSituacionesRutinas(int nivelId,
    [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    final List<Map<String, dynamic>> preguntasMap = await database
        .query('situacionRutina', where: 'nivelId = ?', whereArgs: [nivelId]);
    return preguntasMap
        .map((map) => SituacionRutina.situacionesFromMap(map))
        .toList();
  } catch (e) {
    print("Error al obtener situaciones: $e");
    return [];
  }
}

///Método que nos permite obtener las preguntas del juego Rutinas de forma paginada. Usado para el
///punto de vista del terapeuta
///<br><b>Parámetros</b><br>
///[pageNumber] Página de la que queremos obtener los resultados. Comenzamos en la página 1<br>
///[pageSize] Cantidad de resultados que queremos obtener por página<br>
///[txtBuscar] Texto de la pregunta para filtrar la búsqueda<br>
///[nivel] nivel para filtrar la búsqueda<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///Resultado de la búsqueda con paginación
Future<SituacionRutinaPaginacion> getSituacionRutinaPaginacion(
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

    final List<Map<String, dynamic>> situacionesMap = await database.query(
      'situacionRutina',
      where: whereClause.isEmpty ? null : whereClause,
      orderBy: 'id DESC',
      limit: pageSize,
      offset: offset,
    );
    final List<SituacionRutina> situaciones = situacionesMap
        .map((map) => SituacionRutina.situacionesFromMap(map))
        .toList();

    // Comprobar si hay más preguntas disponibles
    final List<Map<String, dynamic>> totalSituacionesMap = await database.query(
        'situacionRutina',
        where: whereClause.isEmpty ? null : whereClause);
    final bool hayMasPreguntas =
        (offset + pageSize) < totalSituacionesMap.length;

    return SituacionRutinaPaginacion(situaciones, hayMasPreguntas);
  } catch (e) {
    print("Error al obtener situaciones: $e");
    return SituacionRutinaPaginacion([], false);
  }
}

///Método que nos permite insertar una nueva pregunta al juego Rutinas
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones<br>
///[enunciado] Enunciado de la pregunta<br>
///[imgPersonaje] Lista de enteros que es la imagen<br>
///[nivelId] Identificador del nivel al que va a pertenecer la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta que se ha añadido
Future<int> insertSituacionRutina(Database database, String enunciado,
    List<int> imgPersonaje, int nivelId) async {
  int id = -1;
  await database.transaction((txn) async {
    if (imgPersonaje.isEmpty)
      id = await txn.rawInsert(
        "INSERT INTO situacionRutina (enunciado, personajeImg, nivelId, byTerapeuta, fecha) VALUES (?, ?, ?, ?, ?)",
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
        "INSERT INTO situacionRutina (enunciado, personajeImg, nivelId, byTerapeuta, fecha) VALUES (?, ?, ?, ?, ?)",
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

///Método que nos permite insertar las preguntas por defecto del juego Rutinas
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones<br>
///[enunciado] Enunciado de la pregunta<br>
///[pathImg] Ruta en la que se encuentra la imagen<br>
///[nivelId] Identificador del nivel al que va a pertenecer la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta que se ha añadido
Future<int> insertSituacionRutinaInitialData(
    Database database, String enunciado, String pathImg, int nivelId) async {
  int id = -1;
  ByteData imageData = await rootBundle.load(pathImg);
  List<int> bytes = imageData.buffer.asUint8List();
  await database.transaction((txn) async {
    id = await txn.rawInsert(
      "INSERT INTO situacionRutina (enunciado, personajeImg, nivelId, fecha) VALUES (?, ?, ?, ?)",
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

///Método que nos permite eliminar una pregunta del juego Rutinas a partir de su identificador
///<br><b>Parámetros</b><br>
///[situacionRutinaId] Identificador de la pregunta del juego Rutinas que queremos eliminar<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
Future<void> removePreguntaRutinas(int situacionRutinaId,
    [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    await database.delete(
      'situacionRutina',
      where: 'id = ?',
      whereArgs: [situacionRutinaId],
    );
  } catch (e) {
    print('Error al eliminar la situación rutina: $e');
  }
}

///Método que nos permite actualizar una pregunta del juego Rutinas
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecuta la actualización<br>
///[id] Identificador de la pregunta que queremos actualizar<br>
///[enunciado] Nuevo valor del enunciado<br>
///[imgPersonaje] Nueva lista de enteros que representa la imagen<br>
///[nivelId] Nuevo valor del nivel al que pertenece la pregunta<br>
Future<void> updatePregunta(Database database, int id, String enunciado,
    List<int> imgPersonaje, int nivelId) async {
  if (imgPersonaje.isEmpty)
    await database.update(
      'situacionRutina',
      {
        'enunciado': enunciado,
        'personajeImg': null,
        'nivelId': nivelId,
        'fecha': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  else
    await database.update(
      'situacionRutina',
      {
        'enunciado': enunciado,
        'personajeImg': imgPersonaje,
        'nivelId': nivelId,
        'fecha': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
      },
      where: 'id = ?',
      whereArgs: [id],
    );
}

///Método que se encarga de hacer la insercción de las preguntas del juego Rutinas que están presentes inicialmente
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones
void insertRutinas(Database database) {
  insertPreguntaRutinaInitialDataAtencionT(database);
  insertPreguntaRutinaInitialDataInfancia(database);
  insertPreguntaRutinaInitialDataAdolescencia(database);
}

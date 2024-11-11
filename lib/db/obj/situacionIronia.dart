import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../obj/SituacionIroniaPaginacion.dart';
import '../db.dart';
import '../ironiasScripts/nivel3.dart';
import '../ironiasScripts/nivel1.dart';
import '../ironiasScripts/nivel2.dart';
import 'nivel.dart';

///Clase relativa a la tabla SituacionIronia
class SituacionIronia {
  final int? id;
  final String enunciado;
  final Uint8List? imagen;
  final int nivelId;
  final String fecha;
  final int byTerapeuta;
  int visible;

  ///Constructor de la clase SituacionIronia
  SituacionIronia(
      {this.id,
      required this.enunciado,
      this.imagen,
      required this.nivelId,
      required this.fecha,
      required this.byTerapeuta,
      required this.visible});

  ///Crea una instancia de SituacionIronia a partir de un mapa de datos, dicho mapa debe contener:
  ///id, enunciado, imagen, nivelId, fecha y byTerapeuta
  SituacionIronia.situacionesFromMap(Map<String, dynamic> item)
      : id = item["id"],
        enunciado = item["enunciado"],
        imagen = item["imagen"],
        nivelId = item["nivelId"],
        fecha = item["fecha"],
        byTerapeuta = item["byTerapeuta"],
        visible = item["visible"];

  ///Convierte una instancia de SituacionIronia a un mapa de datos
  Map<String, Object> situacionesToMap() {
    return {
      'enunciado': enunciado,
      'nivelId': nivelId,
      'fecha': fecha,
      'byTerapeuta': byTerapeuta,
      'visible': visible
    };
  }

  ///Sobreescritura del método equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SituacionIronia &&
        other.id == id &&
        other.enunciado == enunciado &&
        other.nivelId == nivelId &&
        other.fecha == fecha &&
        other.byTerapeuta == byTerapeuta &&
        other.visible == visible;
  }

  ///Sobreescritura del método hashCode
  @override
  int get hashCode =>
      id.hashCode ^
      enunciado.hashCode ^
      nivelId.hashCode ^
      fecha.hashCode ^
      byTerapeuta.hashCode ^
      visible.hashCode;

  ///Sobreescritura del método toString
  @override
  String toString() {
    return 'SituacionIronia {id: $id, enunciado: $enunciado,'
        ' imagen: $imagen, '
        'nivelId: $nivelId, '
        'fecha: $fecha, '
        'byTerapeuta: $byTerapeuta, '
        'visible: $visible';
  }
}

///Método que nos permite obtener las preguntas del juego Humor
///<br><b>Parámetros</b><br>
///[nivelId] Identificador del nivel del que queremos obtener las preguntas<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///Lista de preguntas del juego Humor pertenecientes al nivelId
Future<List<SituacionIronia>> getSituacionesIronias(int nivelId,
    [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    final List<Map<String, dynamic>> preguntasMap = await database
        .query('situacionIronia', where: 'nivelId = ? AND visible = ?', whereArgs: [nivelId,1]);
    return preguntasMap
        .map((map) => SituacionIronia.situacionesFromMap(map))
        .toList();
  } catch (e) {
    print("Error al obtener situaciones: $e");
    return [];
  }
}

///Método que nos permite obtener las preguntas del juego Humor de forma paginada. Usado para el
///punto de vista del terapeuta
///<br><b>Parámetros</b><br>
///[pageNumber] Página de la que queremos obtener los resultados. Comenzamos en la página 1<br>
///[pageSize] Cantidad de resultados que queremos obtener por página<br>
///[txtBuscar] Texto de la pregunta para filtrar la búsqueda<br>
///[nivel] Nivel para filtrar la búsqueda<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///Resultado de la búsqueda con paginación
Future<SituacionIroniaPaginacion> getSituacionIroniaPaginacion(
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
      'situacionIronia',
      where: whereClause.isEmpty ? null : whereClause,
      orderBy: 'id DESC',
      limit: pageSize,
      offset: offset,
    );
    final List<SituacionIronia> situaciones = situacionesMap
        .map((map) => SituacionIronia.situacionesFromMap(map))
        .toList();

    // Comprobar si hay más preguntas disponibles
    final List<Map<String, dynamic>> totalSituacionesMap = await database.query(
        'situacionIronia',
        where: whereClause.isEmpty ? null : whereClause);
    final bool hayMasPreguntas =
        (offset + pageSize) < totalSituacionesMap.length;

    return SituacionIroniaPaginacion(situaciones, hayMasPreguntas);
  } catch (e) {
    print("Error al obtener situaciones: $e");
    return SituacionIroniaPaginacion([], false);
  }
}

///Método que nos permite insertar una nueva pregunta al juego Humor
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones<br>
///[enunciado] Enunciado de la pregunta<br>
///[imagen] Lista de enteros que es la imagen<br>
///[nivelId] Identificador del nivel al que va a pertenecer la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta añadida
Future<int> insertSituacionIronia(
    Database database, String enunciado, List<int> imagen, int nivelId, {int visibility = 1}) async {
  int id = -1;
  await database.transaction((txn) async {
    if (imagen.isEmpty)
      id = await txn.rawInsert(
        "INSERT INTO situacionIronia (enunciado, imagen, nivelId, byTerapeuta, fecha, visible) VALUES (?, ?, ?, ?, ?, ?)",
        [
          enunciado,
          null,
          nivelId,
          1,
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          visibility
        ],
      );
    else
      id = await txn.rawInsert(
        "INSERT INTO situacionIronia (enunciado, imagen, nivelId, byTerapeuta, fecha, visible) VALUES (?, ?, ?, ?, ?, ?)",
        [
          enunciado,
          imagen,
          nivelId,
          1,
          DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          visibility
        ],
      );
  });

  return id;
}

///Método que nos permite insertar las preguntas por defecto del juego Humor
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones<br>
///[enunciado] Enunciado de la pregunta<br>
///[pathImg] Ruta en la que se encuentra la imagen<br>
///[nivelId] Identificador del nivel al que va a pertenecer la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta añadida
Future<int> insertSituacionIroniaInitialData(
    Database database, String enunciado, String pathImg, int nivelId) async {
  int id = -1;
  ByteData imageData = await rootBundle.load(pathImg);
  List<int> bytes = imageData.buffer.asUint8List();
  await database.transaction((txn) async {
    id = await txn.rawInsert(
      "INSERT INTO situacionIronia (enunciado, imagen, nivelId, fecha) VALUES (?, ?, ?, ?)",
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

///Método que nos permite eliminar una pregunta del juego Humor a partir de su identificador
///<br><b>Parámetros</b><br>
///[situacionIroniaId] Identificador de la pregunta del juego Humor que queremos eliminar<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
Future<void> removePreguntaIronia(int situacionIroniaId, [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    await database.delete(
      'situacionIronia',
      where: 'id = ?',
      whereArgs: [situacionIroniaId],
    );
  } catch (e) {
    print('Error al eliminar la situación ironía: $e');
  }
}

///Método que nos permite actualizar una pregunta del juego Humor
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecuta la actualización<br>
///[id] Identificador de la pregunta que queremos actualizar<br>
///[enunciado] Nuevo valor del enunciado<br>
///[imagen] Nueva lista de enteros que representa la imagen<br>
///[nivelId] Nuevo valor del nivel al que pertenece la pregunta
///<br><b>Salida</b><br>
///Identificador de la pregunta que ha sido actualizada
Future<int> updatePreguntaIronia(Database database, int id, String enunciado,
    List<int> imagen, int nivelId, {int visibility = 1}) async {
  return await database.update(
    'situacionIronia',
    {
      'enunciado': enunciado,
      'imagen': imagen,
      'nivelId': nivelId,
      'fecha': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      'visible': visibility
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

///Método que nos permite cambiar la visibilidad de la situacionId
Future<void> changeVisibility(int situacionId, [Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();

    // Obtener el valor actual de 'visible' para la situación especificada
    final List<Map<String, dynamic>> result = await database.query(
      'situacionIronia',
      columns: ['visible'],
      where: 'id = ?',
      whereArgs: [situacionId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      // Invertir el valor de 'visible' (0 -> 1 o 1 -> 0)
      int currentVisible = result.first['visible'] ?? 0;
      int newVisible = currentVisible == 0 ? 1 : 0;

      // Actualizar el valor de 'visible' en la base de datos
      await database.update(
        'situacionIronia',
        {'visible': newVisible},
        where: 'id = ?',
        whereArgs: [situacionId],
      );
    }
  } catch (e) {
    print("Error al cambiar visibilidad: $e");
  }
}

///Método que se encarga de hacer la insercción de las preguntas del juego Humor que están presentes inicialmente
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones
void insertIronias(Database database) {
  insertIroniasInitialDataNivel1(database);
  insertIroniasInitialDataNivel2(database);
  insertIroniasInitialDataNivel3(database);
}

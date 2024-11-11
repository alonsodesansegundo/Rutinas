import 'package:sqflite/sqflite.dart';

import '../db.dart';

///Clase relativa a la tabla Nivel
class Nivel {
  final int id;
  final String nombre;

  ///Constructor de la clase Nivel
  Nivel({required this.id, required this.nombre});

  ///Crea una instancia de Nivel a partir de un mapa de datos, dicho mapa debe contener: id, nombre
  Nivel.nivelesFromMap(Map<String, dynamic> item)
      : id = item["id"],
        nombre = item["nombre"];

  ///Convierte una instancia de Nivel a un mapa de datos
  Map<String, Object> nivelesToMap() {
    return {'id': id, 'nombre': nombre};
  }

  ///Sobreescritura del método equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Nivel &&
        other.id == id &&
        other.nombre == nombre;
  }

  ///Sobreescritura del método hashCode
  @override
  int get hashCode => id.hashCode ^ nombre.hashCode;

  ///Sobreescritura del método toString
  @override
  String toString() {
    return 'Nivel {id: $id, name: $nombre}';
  }
}

///Método que se encarga de obtener los resultados de la tabla Nivel
///<br><b>Parámetros</b><br>
///@params database Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
///<br><b>Salida</b><br>
///@returns La lista de niveles existentes
Future<List<Nivel>> getNiveles([Database? db]) async {
  try {
    final Database database = db ?? await initializeDB();
    final List<Map<String, dynamic>> nivelesMap = await database.query('nivel');
    return nivelesMap.map((map) => Nivel.nivelesFromMap(map)).toList();
  } catch (e) {
    print("Error al obtener niveles: $e");
    return [];
  }
}

///Método que nos permite obtener un objeto Nivel dado un id
///<br><b>Parámetros</b><br>
///[groupId] Identificador del nivel que queremos obtener<br>
///[db] Parámetro opcional. Le pasamos un objeto Database en caso de estar probando dicho método
Future<Nivel> getNivelById(int groupId, [Database? db]) async {
  // Usa el parámetro db proporcionado o inicializa uno nuevo si db es null
  final Database database = db ?? await initializeDB();

  // Realiza la consulta en la base de datos
  final List<Map<String, dynamic>> nivelMap = await database.query(
    'nivel',
    where: 'id = ?',
    whereArgs: [groupId],
  );
  if (nivelMap.isNotEmpty) {
    return Nivel.nivelesFromMap(nivelMap.first);
  } else {
    throw Exception(
        'No se encontró ningún nivel con el ID especificado: $groupId');
  }
}

///Método que se encarga de hacer la insercción de niveles que están presentes inicialmente
///<br><b>Parámetros</b><br>
///@params database Objeto Database sobre la cual se ejecutan las insercciones
void insertNiveles(Database database) async {
  await database.transaction((txn) async {
    txn.rawInsert(
        "INSERT INTO nivel (nombre) VALUES ('Nivel 1')");
    txn.rawInsert(
        "INSERT INTO nivel (nombre) VALUES ('Nivel 2')");
    txn.rawInsert(
        "INSERT INTO nivel (nombre) VALUES ('Nivel 3')");
  });
}

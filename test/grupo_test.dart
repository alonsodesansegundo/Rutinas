import 'package:Rutirse/db/db.dart';
import 'package:Rutirse/db/obj/nivel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  late Database database;

  // Inicializa la base de datos antes de cada prueba
  setUp(() async {
    database = await databaseFactory.openDatabase(inMemoryDatabasePath);
    createTables(database);
  });

  // Elimino la tabla grupo después de cada prueba
  tearDown(() async {
    await database.delete('grupo');
    await database.close();
  });

  // Test 1
  test('Test for check nivelesToMap', () async {
    insertNiveles(database);
    Nivel grupoExpected =
        new Nivel(id: 1, nombre: "Atención T.");
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles[0].nivelesToMap(), grupoExpected.nivelesToMap());
  });

  // Test 2
  test('Test for check toString', () async {
    insertNiveles(database);
    Nivel grupoExpected =
        new Nivel(id: 1, nombre: "Atención T.");
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles[0].toString(), grupoExpected.toString());
  });

  // Test 3
  test('Test for check insert groups', () async {
    insertNiveles(database);
    final List<Map<String, dynamic>> result = await database.query('grupo');
    expect(result.length, 3);
  });

  // Test 4
  test('Test for check getNiveles (length)', () async {
    insertNiveles(database);
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles.length, 3);
  });

  // Test 5
  test('Test for check getNiveles (order element 0)', () async {
    Nivel grupoExpected =
        new Nivel(id: 1, nombre: "Atención T.");
    insertNiveles(database);
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles[0], grupoExpected);
  });

  // Test
  test('Test for check getNiveles (order element 1)', () async {
    insertNiveles(database);
    Nivel grupoExpected =
        new Nivel(id: 2, nombre: "Infancia");
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles[1], grupoExpected);
  });

  // Test
  test('Test for check getNiveles (order element 2)', () async {
    insertNiveles(database);
    Nivel grupoExpected =
        new Nivel(id: 3, nombre: "Adolescencia");
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles[2], grupoExpected);
  });

  // Test
  test('Test for check hashCode', () async {
    insertNiveles(database);
    Nivel grupoExpected =
        new Nivel(id: 1, nombre: "Atención T.");
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles[0].hashCode, grupoExpected.hashCode);
  });

  // Test
  test('Test for check getNiveles without insert of groups', () async {
    List<Nivel> niveles = await getNiveles(database);
    expect(niveles, []);
  });

  // Test
  test('Test for check getNivelById with existent id', () async {
    insertNiveles(database);
    Nivel grupoExpected =
        new Nivel(id: 1, nombre: "Atención T.");
    Nivel grupo = await getNivelById(1, database);
    expect(grupo, grupoExpected);
  });

  // Test
  test('Test for check getNivelById with not existent id', () async {
    expect(getNivelById(-1, database), throwsA(isA<Exception>()));
  });
}

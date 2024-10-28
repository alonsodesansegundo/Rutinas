// PREGUNTAS SENTIMIENTOS PARA EL GRUPO DE ATENCIÓN T.
import 'package:sqflite/sqflite.dart';

import '../obj/preguntaSentimiento.dart';
import '../obj/situacion.dart';

///Path correspondiente a donde se almacenan las imágenes de las preguntas del juego Sentimientos
String pathSentimientos = 'assets/img/sentimientos/';

/// Path correspondiente a donde se almacenan las imágenes de los personajes del juego Rutinas
String pathPersonaje = 'assets/img/personajes/';

///Método encargado de las insercciones de preguntas predeterminadas para el juego Sentimientos del grupo Atención Temprana
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones
void insertPreguntaSentimientoInitialDataAtencionT(Database database) async {
  int grupoAtencionT = 1;

  int id_P1 = await insertPreguntaSentimientoInitialData(
      database,
      'Jaime está contento después de acabar la carrera, ¿por qué?',
      pathPersonaje + 'corredor.png',
      grupoAtencionT);
  insertSituacionInitialData(
      database, "Ganó la carrera", 1, pathSentimientos + "ganar.png", id_P1);
  insertSituacionInitialData(
      database, "Perdió la carrera", 0, pathSentimientos + "perder.png", id_P1);

  int id_P2 = await insertPreguntaSentimientoInitialData(
      database,
      'Jaime está triste después de acabar la carrera, ¿por qué?',
      pathPersonaje + 'corredor.png',
      grupoAtencionT);
  insertSituacionInitialData(
      database, "Ganó la carrera", 0, pathSentimientos + "ganar.png", id_P2);
  insertSituacionInitialData(
      database, "Perdió la carrera", 1, pathSentimientos + "perder.png", id_P2);

  int id_P3 = await insertPreguntaSentimientoInitialData(
      database,
      'Jaime se ha asustado al ver...',
      pathPersonaje + 'asustado.png',
      grupoAtencionT);
  insertSituacionInitialData(
      database, "Monstruo", 1, pathSentimientos + "monstruo.png", id_P3);
  insertSituacionInitialData(
      database, "Peluche", 0, pathSentimientos + "peluche.png", id_P3);

  int id_P4 = await insertPreguntaSentimientoInitialData(
      database,
      'Carmen se ha puesto contenta al ver...',
      pathPersonaje + 'contenta.png',
      grupoAtencionT);
  insertSituacionInitialData(
      database, "Monstruo", 0, pathSentimientos + "monstruo.png", id_P4);
  insertSituacionInitialData(
      database, "Peluche", 1, pathSentimientos + "peluche.png", id_P4);

  int id_P5 = await insertPreguntaSentimientoInitialData(
      database,
      'Jaime y Carmen hoy están muy contentos, por eso están...',
      pathPersonaje + 'ambos.png',
      grupoAtencionT);
  insertSituacionInitialData(
      database, "Abrazados", 1, pathSentimientos + "abrazo.png", id_P5);
  insertSituacionInitialData(
      database, "Discutiendo", 0, pathSentimientos + "discutir.png", id_P5);

  int id_P6 = await insertPreguntaSentimientoInitialData(
      database,
      'Carmen y Jaime hoy están muy enfadados, por eso están...',
      pathPersonaje + 'enfadadosAmbos.png',
      grupoAtencionT);
  insertSituacionInitialData(
      database, "Abrazados", 0, pathSentimientos + "abrazo.png", id_P6);
  insertSituacionInitialData(
      database, "Discutiendo", 1, pathSentimientos + "discutir.png", id_P6);
}

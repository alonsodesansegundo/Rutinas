// PREGUNTAS IRONIAS PARA EL NIVEL FACIL
import 'package:sqflite/sqflite.dart';

import '../obj/respuestaIronia.dart';
import '../obj/situacionIronia.dart';

///Path correspondiente a donde se almacenan las imágenes del juego Humor
String pathIronias = 'assets/img/humor/';

///Método encargado de las insercciones de preguntas predeterminadas para el juego Humor del grupo Atención Temprana
///<br><b>Parámetros</b><br>
///[database] Objeto Database sobre la cual se ejecutan las insercciones
void insertIroniasInitialDataNivel1(Database database) async {
  int nivel1 = 1;

  int id_P1 = await insertSituacionIroniaInitialData(
      database,
      '¿Qué le dice una vaca a otra vaca? ¡Muuucho gusto!',
      pathIronias + 'vaca.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 0, id_P1);
  insertRespuestaIronia(database, "Sí, es una broma.", 1, id_P1);

  int id_P2 = await insertSituacionIroniaInitialData(
      database,
      '¿Qué le dice una vaca a otra vaca? ¡Muuu!',
      pathIronias + 'vaca.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 1, id_P2);
  insertRespuestaIronia(database, "Sí, es una broma.", 0, id_P2);

  int id_P3 = await insertSituacionIroniaInitialData(
      database,
      '¿Por qué el elefante no usa un ordenador? Porque le tiene miedo al ratón.',
      pathIronias + 'elefante.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 0, id_P3);
  insertRespuestaIronia(database, "Sí, es una broma.", 1, id_P3);

  int id_P4 = await insertSituacionIroniaInitialData(
      database,
      '¿Por qué el elefante no usa un ordenador? Porque sus patas son demasiado grandes para los teclados y ratones.',
      pathIronias + 'elefante.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 1, id_P4);
  insertRespuestaIronia(database, "Sí, es una broma.", 0, id_P4);

  int id_P5 = await insertSituacionIroniaInitialData(database,
      '¡Qué lento va el caracol!', pathIronias + 'caracol.png', nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 1, id_P5);
  insertRespuestaIronia(database, "Sí, es una broma.", 0, id_P5);

  int id_P6 = await insertSituacionIroniaInitialData(
      database,
      '¡Qué rápido va el caracol!',
      pathIronias + 'caracol.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 0, id_P6);
  insertRespuestaIronia(database, "Sí, es una broma.", 1, id_P6);

  int id_P7 = await insertSituacionIroniaInitialData(
      database, '¡Qué mal día hace!', pathIronias + 'sol.png', nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 0, id_P7);
  insertRespuestaIronia(database, "Sí, es una broma.", 1, id_P7);

  int id_P8 = await insertSituacionIroniaInitialData(database,
      '¡Qué mal día hace!', pathIronias + 'lluvia.png', nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 1, id_P8);
  insertRespuestaIronia(database, "Sí, es una broma.", 0, id_P8);

  int id_P9 = await insertSituacionIroniaInitialData(
      database,
      '¿Qué baile le gusta más al tomate? La salsa.',
      pathIronias + 'tomate.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 0, id_P9);
  insertRespuestaIronia(database, "Sí, es una broma.", 1, id_P9);

  int id_10 = await insertSituacionIroniaInitialData(
      database,
      '¿Qué baile le gusta más al tomate? Al tomate no le gusta ningún baile.',
      pathIronias + 'tomate.png',
      nivel1);
  insertRespuestaIronia(database, "No, no es una broma.", 1, id_10);
  insertRespuestaIronia(database, "Sí, es una broma.", 0, id_10);
}

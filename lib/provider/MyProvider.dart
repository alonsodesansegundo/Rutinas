import 'package:flutter/material.dart';

import '../db/obj/nivel.dart';
import '../db/obj/jugador.dart';

///Clase MyProvider de la aplicación, para almacenar de manera eficiente y rápida datos de uso (jugador y nivel)
class MyProvider with ChangeNotifier {
  late Jugador _jugador;
  late Nivel _nivel;

  ///Getter de jugador
  Jugador get jugador => this._jugador;

  ///Setter de jugador
  set jugador(Jugador jugador) {
    this._jugador = jugador; //actualizamos el valor
    notifyListeners(); //notificamos a los widgets que esten escuchando el stream.
  }

  ///Getter de nivel
  Nivel get nivel => this._nivel;

  ///Setter de nivel
  set nivel(Nivel nivel) {
    this._nivel = nivel; //actualizamos el valor
    notifyListeners(); //notificamos a los widgets que esten escuchando el stream.
  }
}

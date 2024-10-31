import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../db/obj/accion.dart';
import '../../db/obj/jugador.dart';
import '../../db/obj/partida.dart';
import '../../db/obj/partidaRutinas.dart';
import '../../db/obj/situacionRutina.dart';
import '../../obj/CartaAccion.dart';
import '../../provider/MyProvider.dart';
import '../../widgets/ExitDialog.dart';
import '../../widgets/ImageTextButton.dart';
import '../../widgets/PreguntaWidget.dart';
import '../common/menuJugador.dart';
import '../main.dart';

Random random = Random(); // para generar numeros aleatorios

///Pantalla de juego del juego Rutinas
class JugarRutinas extends StatefulWidget {
  @override
  JugarRutinasState createState() => JugarRutinasState();
}

/// Estado asociado a la pantalla [JugarRutinas] que gestiona la lógica
/// y la interfaz de usuario de la pantalla
class JugarRutinasState extends State<JugarRutinas>
    with WidgetsBindingObserver {
  late FlutterTts flutterTts; // para reproducir audio

  late bool flag,
      isSpeaking,
      reproduceVoice; // bandera para cargar las preguntas solo 1 vez

  late List<SituacionRutina> situacionRutinaList; // lista de preguntas

  late List<CartaAccion> cartasAcciones; // acciones de la pregunta actual

  late int indiceActual; // índice de la pregunta actual

  late double titleSize,
      textSize,
      espacioPadding,
      espacioAlto,
      imgWidth,
      personajeWidth,
      imgVolverHeight,
      espacioCartas,
      ancho,
      imgBtnWidth;

  late int cartasFila; // numero de cartas por fila

  late ImageTextButton btnSeguirJugando,
      btnSeguirJugandoCambiaPregunta,
      btnSalir,
      btnMenu;

  late ExitDialog exitDialog, incorrectDialog, correctDialog, endGameDialog;

  late int aciertos, fallos;

  late DateTime timeInicio, timeFin;

  late bool loadProvider, loadData;

  late Jugador jugadorActual;

  @override
  void initState() {
    super.initState();
    loadData = false;
    flutterTts = FlutterTts();
    timeInicio = DateTime.now();
    flag = false;
    situacionRutinaList = [];
    cartasAcciones = [];
    indiceActual = -1;
    aciertos = 0;
    fallos = 0;
    loadProvider = false;
    reproduceVoice = false;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) _stopSpeaking();
  }

  @override
  Widget build(BuildContext context) {
    if (!loadData) {
      loadData = true;
      _createVariablesSize();
      _createButtonsFromDialogs();
      _createDialogs();
    }
    if (!loadProvider) {
      var myProvider = Provider.of<MyProvider>(context);
      jugadorActual = myProvider.jugador;
      loadProvider = true;
    }

    return WillPopScope(
      onWillPop: () async {
        _stopSpeaking();
        return true; // Permite que la pantalla se cierre
      },
      child: Scaffold(
        body: DynMouseScroll(
          durationMS: myDurationMS,
          scrollSpeed: myScrollSpeed,
          animationCurve: Curves.easeOutQuart,
          builder: (context, controller, physics) => SingleChildScrollView(
            controller: controller,
            physics: physics, // Habilita el scroll vertical siempre
            child: Padding(
              padding: EdgeInsets.all(espacioPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinea los elementos a la izquierda
                        children: [
                          Text(
                            'Rutinas',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: titleSize,
                            ),
                          ),
                          Text(
                            'Juego',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: titleSize / 2,
                            ),
                          ),
                        ],
                      ),
                      ImageTextButton(
                        image: Image.asset('assets/img/botones/salir.png',
                            height: imgVolverHeight * 1.5),
                        text: Text(
                          'Salir',
                          style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: textSize,
                              color: Colors.black),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return exitDialog;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  FutureBuilder<void>(
                    future: _cargarPreguntas(),
                    builder: (context, snapshot) {
                      if (situacionRutinaList.isEmpty) {
                        return Text("Cargando...");
                      } else {
                        return Column(
                          children: [
                            PreguntaWidget(
                              enunciado:
                                  situacionRutinaList[indiceActual].enunciado,
                              isLoading: false,
                              subtextSize: textSize,
                              imgWidth: personajeWidth,
                              personajeImg: situacionRutinaList[indiceActual]
                                  .personajeImg,
                              rightSpace: espacioPadding,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  //mostrar cada una de las CartaAccion de la lista cartaAcciones
                  SizedBox(
                    height: _calcularAltura(
                        ancho,
                        cartasFila,
                        espacioPadding,
                        espacioCartas,
                        (cartasAcciones.length / cartasFila).ceil()),
                    child: GridView.builder(
                      physics:
                          NeverScrollableScrollPhysics(), // Deshabilita el scroll vertical
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cartasFila,
                        crossAxisSpacing: espacioCartas,
                        mainAxisSpacing: espacioCartas,
                        childAspectRatio: (1 / 1.6),
                      ),
                      itemCount: cartasAcciones.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _cartaPulsada(cartasAcciones[index]);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              color: cartasAcciones[index].backgroundColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Image.memory(
                                      cartasAcciones[index].accion.imagen!),
                                  width: imgWidth,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        cartasAcciones[index].backgroundColor,
                                  ),
                                  padding: EdgeInsets.all(espacioPadding / 3),
                                  child: Text(
                                    cartasAcciones[index].accion.texto,
                                    style: TextStyle(
                                      fontFamily: 'ComicNeue',
                                      fontSize: textSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: espacioAlto,
                  ),
                  ImageTextButton(
                    image: Image.asset(
                      'assets/img/botones/fin.png',
                      width: imgWidth * 0.75,
                    ),
                    text: Text(
                      'Confirmar',
                      style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                          color: Colors.black),
                    ),
                    onPressed: () {
                      if (_comprobarRespuestas()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            if (situacionRutinaList.length != 1) {
                              _cambiarPregunta();
                              _speak('Fantástico');
                              return correctDialog;
                            } else {
                              _speak("¡Enhorabuena!");
                              return this.endGameDialog;
                            }
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            _speak('¡Oops!');
                            return incorrectDialog;
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: espacioAlto),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///Método que se utiliza para darle valor a las variables relacionadas con tamaños de fuente, imágenes, etc.
  void _createVariablesSize() {
    Size screenSize = MediaQuery.of(context).size;

    cartasFila = 3;
    ancho = screenSize.width;
    titleSize = screenSize.width * 0.10;
    textSize = screenSize.width * 0.03;
    espacioPadding = screenSize.height * 0.03;
    espacioAlto = screenSize.width * 0.01;
    espacioCartas = screenSize.height * 0.02;
    personajeWidth = screenSize.width / 4;
    imgVolverHeight = screenSize.height / 32;
    imgWidth = screenSize.width / 4;
    imgBtnWidth = screenSize.width / 5;
  }

  ///Método encargado de inicializar los botones que tendrán los cuadros de dialogo
  void _createButtonsFromDialogs() {
    // boton para seguir jugando
    btnSeguirJugando = ImageTextButton(
      image: Image.asset(
        'assets/img/botones/jugar.png',
        width: imgBtnWidth,
      ),
      text: Text(
        'Seguir jugando',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    btnSeguirJugandoCambiaPregunta = ImageTextButton(
      image: Image.asset(
        'assets/img/botones/jugar.png',
        width: imgBtnWidth,
      ),
      text: Text(
        'Seguir jugando',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _speak(situacionRutinaList[indiceActual].enunciado);
      },
    );

    // boton para salir del juego
    btnSalir = ImageTextButton(
      image: Image.asset(
        'assets/img/botones/salir.png',
        width: imgBtnWidth,
      ),
      text: Text(
        'Salir',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        _stopSpeaking();
        saveProgreso();
        Navigator.pop(context);
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MenuJugador(
                    juego: 'rutinas',
                  )),
        );
      },
    );

    btnMenu = ImageTextButton(
      image: Image.asset(
        'assets/img/botones/salir.png',
        width: imgBtnWidth,
      ),
      text: Text(
        'Ir al menú',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        _stopSpeaking();
        saveProgreso();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MenuJugador(
                    juego: 'rutinas',
                  )),
        );
      },
    );
  }

  ///Método encargado de inicializar los cuadros de dialogo que tendrá la pantalla
  void _createDialogs() {
    // cuadro de dialogo para salir del juego o no
    exitDialog = ExitDialog(
        title: 'Aviso',
        titleSize: titleSize,
        content:
            "¿Estás seguro de que quieres salir del juego? \nSi lo haces, irás al menú principal.\n"
            "Puedes confirmar la salida o seguir disfrutando del juego.",
        contentSize: textSize,
        leftImageTextButton: btnSeguirJugando,
        rightImageTextButton: btnSalir);

    // cuadro de dialogo para cuando hay alguna respuesta incorrecta
    incorrectDialog = ExitDialog(
        title: '¡Oops!',
        titleSize: titleSize,
        content:
            "Hay algunas respuestas incorrectas, ¡pero sigue intentándolo!\n"
            "Te animamos a que lo intentes de nuevo y mejorar.\n"
            "¡Ánimo, tú puedes!\n\n"
            "PISTA: fíjate en los colores de las cartas...",
        contentSize: textSize,
        leftImageTextButton: btnSeguirJugando,
        rightImageTextButton: btnSalir,
        optionalImage: Image.asset(
          'assets/img/medallas/incorrecto.png',
          width: imgWidth,
        ));

    // cuadro de dialogo para cuando todas las respuestas son correctas
    correctDialog = ExitDialog(
        title: '¡Fantástico!',
        titleSize: titleSize,
        content: "¡Enhorabuena, lo has hecho excelente! "
            "\nHas ordenado todas las acciones de manera perfecta.\n"
            "¡Gran trabajo!",
        contentSize: textSize,
        leftImageTextButton: btnSeguirJugandoCambiaPregunta,
        rightImageTextButton: btnSalir,
        optionalImage: Image.asset(
          'assets/img/medallas/correcto.png',
          width: imgWidth,
        ));

    // cuadro de dialogo cuando hemos completado todas las preguntas del juego
    endGameDialog = ExitDialog(
        title: '¡Enhorabuena!',
        titleSize: titleSize,
        content:
            "¡Qué gran trabajo, bravo! Has superado todas las fases del juego.\n"
            "Espero que hayas disfrutado y aprendido con esta experiencia.\n"
            "¡Sigue trabajando para mejorar tu tiempo!",
        contentSize: textSize,
        leftImageTextButton: btnMenu,
        optionalImage: Image.asset(
          'assets/img/medallas/trofeo.png',
          width: imgWidth,
        ));
  }

  ///Método para cargar todas las preguntas del juego Rutinas en la variable [situacionRutinaList], desordenarlas y seleccionar una para comenzar [indiceActual]
  Future<void> _cargarPreguntas() async {
    if (!flag) {
      flag = true;
      try {
        var myProvider = Provider.of<MyProvider>(context);
        // obtengo las preguntas del nivel correspondiente
        List<SituacionRutina> situaciones =
            await getSituacionesRutinas(myProvider.nivel.id);
        setState(() {
          situacionRutinaList = situaciones; // actualizo la lista
          indiceActual =
              random.nextInt(situacionRutinaList.length); // pregunta aleatoria
          _speak(situacionRutinaList[indiceActual].enunciado);
          _cargarAcciones(); // cargo las acciones de la pregunta actual
        });
      } catch (e) {
        // no se debe de producir ningún error al ser una BBDD local
        print("Error al obtener la lista de preguntas: $e"); //
      }
    }
  }

  ///Método que se encarga de cargar las acciones de la pregunta actual en [cartasAcciones]
  Future<void> _cargarAcciones() async {
    try {
      List<Accion> acciones =
          await getAcciones(situacionRutinaList[indiceActual].id ?? -1);
      setState(() {
        acciones.shuffle(); // desordenar acciones
        // creo las cartas
        cartasAcciones = acciones.map((accion) {
          return CartaAccion(
            accion: accion,
          );
        }).toList();
      });
    } catch (e) {
      // no se debe de producir ningún error al ser una BBDD local
      print("Error al obtener la lista de acciones: $e");
    }
  }

  ///Método que nos permite comprobar si el orden de todas las acciones es correcto o no
  ///<br><b>Salida</b><br>
  ///[true] si todas las acciones están en su orden correcto, [false] en caso contrario
  bool _comprobarRespuestas() {
    bool correcto = true;
    setState(() {
      for (int i = 0; i < cartasAcciones.length; i++) {
        cartasAcciones[i].selected = false;
        if (i != cartasAcciones[i].accion.orden) {
          correcto = false;
          cartasAcciones[i].backgroundColor = Colors.red;
        } else
          cartasAcciones[i].backgroundColor = Colors.green;
      }
    });
    if (correcto)
      aciertos += 1;
    else
      fallos += 1;
    return correcto;
  }

  ///Método que nos permite cambiar la pregunta actual
  void _cambiarPregunta() {
    if (situacionRutinaList.isNotEmpty) {
      // si hay preguntas
      // Elimino la pregunta actual de la lista
      situacionRutinaList.removeAt(indiceActual);
      indiceActual = random.nextInt(situacionRutinaList.length);
      _cargarAcciones();
    }
  }

  ///Método que nos permite calcular la altura aproximada del gridview
  double _calcularAltura(double ancho, int cartasFila, double espacioPadding,
      double espacioCartas, int filas) {
    double sol = 0;
    double aux = espacioPadding * 2;
    double aux2 = espacioCartas * (cartasFila - 1);
    double anchoTotal = ancho - aux - aux2;
    double anchoCarta = anchoTotal / cartasFila;
    double altoCarta = anchoCarta / (1 / 1.6);

    sol = altoCarta * filas + espacioCartas * 5;

    return sol;
  }

  ///Método que nos permite intercambiar o marcar una carta seleccionada según sea necesario
  ///<br><b>Parámetros</b><br>
  ///[cartasAccion] Carta que acaba de ser pulsada o seleccionada
  void _cartaPulsada(CartaAccion cartasAccion) {
    cartasAccion.selected = !cartasAccion.selected;
    reproduceVoice = !reproduceVoice;
    setState(() {
      // si la carta actualmente es pulsada
      if (cartasAccion.selected) {
        if (reproduceVoice) _speak(cartasAccion.accion.texto);
        cartasAccion.backgroundColor = Colors.grey;
        // miro si hay otra que haya sido pulsada
        for (int i = 0; i < cartasAcciones.length; i++) {
          // si ha sido pulsada y no es la misma que he pulsado ahora
          if (cartasAcciones[i].selected && cartasAcciones[i] != cartasAccion) {
            // hago el intercambio
            // las marco como deseleccionadas
            cartasAcciones[i].selected = false;
            cartasAccion.selected = false;

            //hago el intercambio
            CartaAccion copia = cartasAccion;
            int pos = cartasAcciones.indexOf(cartasAccion);
            cartasAcciones[pos] = cartasAcciones[i];
            cartasAcciones[i] = copia;

            cartasAcciones[pos].backgroundColor = Colors.transparent;
            cartasAcciones[i].backgroundColor = Colors.transparent;
            return;
          }
        }
      } else {
        cartasAccion.backgroundColor = Colors.transparent;
      }
    });
  }

  ///Método que permite la reproducción por audio de un texto
  ///<br><b>Parámetros</b><br>
  ///[texto] Cadena de texto que queremos reproducir por audio
  Future<void> _speak(String texto) async {
    await flutterTts.setLanguage("es-ES"); // Establecer el idioma a español
    await flutterTts.speak(texto);

    // Establecer el estado como reproduciendo
    setState(() {
      isSpeaking = true;
    });

    // Escuchar los cambios de estado para detectar la finalización de la reproducción
    flutterTts.setCompletionHandler(() {
      // Limpiar el estado cuando la reproducción ha terminado
      setState(() {
        isSpeaking = false;
      });
    });
  }

  ///Método que nos permite pausar o parar la reproducción por audio de texto
  Future<void> _stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    }
  }

  ///Método que nos permite guardar la partida del juego Rutinas
  void saveProgreso() {
    timeFin = DateTime.now();
    Duration duracion = timeFin.difference(timeInicio);

    // Formatear la fecha en el formato deseado
    String formattedFechaFin =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(timeFin);

    Partida partida = new Partida(
        fechaFin: formattedFechaFin,
        duracionSegundos: duracion.inSeconds,
        aciertos: aciertos,
        fallos: fallos,
        jugadorId: jugadorActual.id!);

    insertPartidaRutinas(partida);
  }
}

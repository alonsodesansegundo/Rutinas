import 'dart:math';

import 'package:TresEnUno/db/obj/preguntaSentimiento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../db/obj/jugador.dart';
import '../../db/obj/partida.dart';
import '../../db/obj/partidaSentimientos.dart';
import '../../db/obj/situacion.dart';
import '../../obj/CartaSituacion.dart';
import '../../provider/MyProvider.dart';
import '../../widgets/ExitDialog.dart';
import '../../widgets/ImageTextButton.dart';
import '../../widgets/PreguntaWidget.dart';
import '../common/menuJugador.dart';

Random random = Random(); // para generar numeros aleatorios

class JugarSentimientos extends StatefulWidget {
  @override
  _JugarSentimientos createState() => _JugarSentimientos();
}

class _JugarSentimientos extends State<JugarSentimientos> {
  late FlutterTts flutterTts; // para reproducir audio

  late bool flag, isSpeaking; // bandera para cargar las preguntas solo 1 vez

  late List<PreguntaSentimiento> preguntaSentimientoList; // lista de preguntas

  late List<CartaSituacion>
      cartasSituaciones; // situaciones de la pregunta actual

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

  late ExitDialog exitDialog,
      incorrectDialog,
      correctDialog,
      endGameDialog,
      notSelectedDialog;

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
    preguntaSentimientoList = [];
    cartasSituaciones = [];
    indiceActual = -1;
    aciertos = 0;
    fallos = 0;
    loadProvider = false;
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

    return Scaffold(
      body: SingleChildScrollView(
        physics:
            AlwaysScrollableScrollPhysics(), // Habilita el scroll vertical siempre
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
                        'Sentimientos',
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
                  if (preguntaSentimientoList.isEmpty) {
                    return Text("Cargando...");
                  } else {
                    return Column(
                      children: [
                        PreguntaWidget(
                          enunciado:
                              preguntaSentimientoList[indiceActual].enunciado,
                          isLoading: false,
                          subtextSize: textSize,
                          imgWidth: personajeWidth,
                          personajeImg:
                              preguntaSentimientoList[indiceActual].imagen,
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
                    (cartasSituaciones.length / cartasFila).ceil()),
                child: GridView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // Deshabilita el scroll vertical
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cartasFila,
                    crossAxisSpacing: espacioCartas,
                    mainAxisSpacing: espacioCartas,
                    childAspectRatio: (1 / 1.6),
                  ),
                  itemCount: cartasSituaciones.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _cartaPulsada(cartasSituaciones[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          color: cartasSituaciones[index].backgroundColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Image.memory(
                                  cartasSituaciones[index].situacion.imagen!),
                              width: imgWidth,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: cartasSituaciones[index].backgroundColor,
                              ),
                              padding: EdgeInsets.all(espacioPadding / 3),
                              child: Text(
                                cartasSituaciones[index].situacion.texto,
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
                  if (!_comprobarSelected()) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          _speak("Vaya...");
                          return this.notSelectedDialog;
                        });
                  } else {
                    if (_comprobarRespuestas()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          if (preguntaSentimientoList.length != 1) {
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
                  }
                },
              ),
              SizedBox(height: espacioAlto),
            ],
          ),
        ),
      ),
    );
  }

  // metodo para darle valor a las variables relacionadas con tamaños de fuente, imagenes, etc.
  void _createVariablesSize() {
    Size screenSize = MediaQuery.of(context).size;

    cartasFila = 3;
    ancho = screenSize.width;
    titleSize = screenSize.width * 0.10;
    textSize = screenSize.width * 0.03;
    espacioPadding = screenSize.height * 0.03;
    espacioAlto = screenSize.height * 0.01;
    espacioCartas = screenSize.height * 0.02;
    personajeWidth = screenSize.width / 4;
    imgVolverHeight = screenSize.height / 32;
    imgWidth = screenSize.width / 4;
    imgBtnWidth = screenSize.width / 5;
  }

  // metodo para crear los botones necesarios en los cuadros de dialogos
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
        _cambiarPregunta();
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
                    juego: 'sentimientos',
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
                    juego: 'sentimientos',
                  )),
        );
      },
    );
  }

  // metodo para crear los cuadros de dialogos
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
        content: "Parece que has fallado, ¡pero sigue intentándolo!\n"
            "Te animamos a que lo intentes de nuevo y mejorar.\n"
            "¡Ánimo, tú puedes!\n",
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

    notSelectedDialog = ExitDialog(
        title: 'Vaya...',
        titleSize: titleSize,
        content:
            "Parece que te has olvidado de indicar una respuesta correcta.\n"
            "Recuerda que la respuesta que tengas seleccionada actualmente se pondrá de color gris.\n"
            "¡Te animamos a que lo revises y lo sigas intentando!",
        contentSize: textSize,
        leftImageTextButton: btnSeguirJugando,
        rightImageTextButton: btnSalir);
  }

  // metodo para cargar todas las preguntas
  Future<void> _cargarPreguntas() async {
    if (!flag) {
      flag = true;
      try {
        var myProvider = Provider.of<MyProvider>(context);
        // obtengo las preguntas del grupo correspondiente
        List<PreguntaSentimiento> situaciones =
            await getPreguntasSentimiento(myProvider.grupo.id);
        setState(() {
          preguntaSentimientoList = situaciones; // actualizo la lista
          indiceActual = random
              .nextInt(preguntaSentimientoList.length); // pregunta aleatoria
          _speak(preguntaSentimientoList[indiceActual].enunciado);
          _cargarSituaciones(); // cargo las acciones de la pregunta actual
        });
      } catch (e) {
        // no se debe de producir ningún error al ser una BBDD local
        print("Error al obtener la lista de preguntas sentimientos: $e"); //
      }
    }
  }

  // método para cargar las acciones de la pregunta actual
  Future<void> _cargarSituaciones() async {
    try {
      List<Situacion> situaciones =
          await getSituaciones(preguntaSentimientoList[indiceActual].id ?? -1);
      setState(() {
        situaciones.shuffle(); // desordenar acciones
        // creo las cartas
        cartasSituaciones = situaciones.map((situacion) {
          return CartaSituacion(
            situacion: situacion,
          );
        }).toList();
      });
    } catch (e) {
      // no se debe de producir ningún error al ser una BBDD local
      print("Error al obtener la lista de acciones: $e");
    }
  }

  bool _comprobarSelected() {
    for (int i = 0; i < this.cartasSituaciones.length; i++) {
      if (this.cartasSituaciones[i].selected) return true;
    }
    return false;
  }

  // método para comprobar si las respuestas son correctas o no
  bool _comprobarRespuestas() {
    bool correcto = true;
    for (int i = 0; i < cartasSituaciones.length; i++) {
      if (cartasSituaciones[i].selected &&
          cartasSituaciones[i].situacion.correcta != 1) {
        setState(() {
          fallos += 1;
        });
        return false;
      }
      if (!cartasSituaciones[i].selected &&
          cartasSituaciones[i].situacion.correcta == 1) {
        setState(() {
          fallos += 1;
        });
        return false;
      }
    }
    aciertos += 1;
    return correcto;
  }

  // método para cambiar la pregunta actual
  void _cambiarPregunta() {
    setState(() {
      if (preguntaSentimientoList.isNotEmpty) {
        // si hay preguntas
        // Elimino la pregunta actual de la lista
        preguntaSentimientoList.removeAt(indiceActual);
        indiceActual = random.nextInt(preguntaSentimientoList.length);
        _speak(preguntaSentimientoList[indiceActual].enunciado);
        _cargarSituaciones();
      }
    });
  }

  // metodo para calcular la altura del gridview
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

  // metodo para cuando pulso una carta, y de ser necesario, intercambiar
  void _cartaPulsada(CartaSituacion cartaSituacion) {
    cartaSituacion.selected = !cartaSituacion.selected;
    setState(() {
      // si la carta actualmente es pulsada
      if (cartaSituacion.selected) {
        cartaSituacion.backgroundColor = Colors.grey;
        var myProvider = Provider.of<MyProvider>(context, listen: false);
        if (myProvider.grupo.id == 1) {
          for (int i = 0; i < cartasSituaciones.length; i++) {
            if (cartasSituaciones[i] != cartaSituacion) {
              cartasSituaciones[i].selected = false;
              setState(() {
                cartasSituaciones[i].backgroundColor = Colors.transparent;
              });
            }
          }
        }
      } else
        cartaSituacion.backgroundColor = Colors.transparent;

      //si es atencion temprana solo te dejo tener una carta pulsada
    });
  }

  // método para reproducir un texto por audio
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

  Future<void> _stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() {
        isSpeaking = false;
      });
    }
  }

  // metodo para guardar el progreso o partida
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

    insertPartidaSentimientos(partida);
  }
}
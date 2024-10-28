import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/obj/nivel.dart';
import '../../db/obj/jugador.dart';
import '../../provider/MyProvider.dart';
import '../../widgets/ImageTextButton.dart';
import '../humor/ayudaHumor.dart';
import '../humor/jugarHumor.dart';
import '../rutinas/ayudaRutinas.dart';
import '../rutinas/jugarRutinas.dart';
import '../sentimientos/ayudaSentimientos.dart';
import '../sentimientos/jugarSentimientos.dart';

///Pantalla que se muestra cuando un usuario selecciona un juego para comenzar a jugar
class Home extends StatefulWidget {
  ///Variable que puede tener 3 posibles valores: rutinas, humor o sentimientos. Dependiendo de ello
  ///se mostrarán ciertos textos y seremos redirigidos a distintas pantallas
  final String juego;

  Home({required this.juego});

  @override
  HomeState createState() => HomeState();
}

/// Estado asociado a la pantalla [Home] que gestiona la lógica
/// y la interfaz de usuario de la pantalla
class HomeState extends State<Home> {
  late List<Nivel> nivelesList; // lista de niveles obtenidos de la BBDD
  late String txtnivel; // texto del nivel seleccionado
  late List<bool>
      btnnivelesFlags; // para tener en cuenta que boton ha sido pulsado

  late double titleSize,
      textSize,
      espacioPadding,
      espacioAlto,
      imgWidth,
      imgVolverHomeHeight,
      imgVolverHeight;

  // Datos que se deben de completar para empezar a jugar
  String nombre = "Introduce tu nombre";
  Nivel? selectednivel = null;

  late AlertDialog dialogoCamposIncompletos;

  late bool loadData;

  @override
  void initState() {
    super.initState();
    loadData = false;
    _getniveles();
    nivelesList = [];
    txtnivel = "";
    btnnivelesFlags = [false, false, false];
  }

  @override
  Widget build(BuildContext context) {
    if (!loadData) {
      loadData = true;
      _createVariablesSize();
      _createDialogs();
    }

    var myProvider = Provider.of<MyProvider>(context);

    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(espacioPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.juego == 'rutinas')
                      Text(
                        "Rutinas",
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize,
                        ),
                      ),
                    if (widget.juego == 'humor')
                      Text(
                        "Humor",
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize,
                        ),
                      ),
                    if (widget.juego == 'sentimientos')
                      Text(
                        "Sentimientos",
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize,
                        ),
                      ),
                    ImageTextButton(
                      image: Image.asset('assets/img/botones/home.png',
                          height: imgVolverHomeHeight),
                      text: Text(
                        'Volver',
                        style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                            color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ],
                ),
                SizedBox(height: espacioAlto), // Espacio entre los textos
                // Explicación pantalla
                Text(
                  'Antes de empezar, ¿puedes decirnos tu nombre y a qué nivel perteneces? '
                  'Esto nos va a ayudar a seguir tu progreso. '
                  '¡Muchas gracias!',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: textSize,
                  ),
                ),
                SizedBox(height: espacioAlto), // Espacio entre los textos
                // Fila para el nombre
                Row(
                  children: [
                    Text(
                      'Nombre:',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                    SizedBox(width: espacioPadding),
                    Expanded(
                      child: TextField(
                        onChanged: (text) {
                          this.nombre = text;
                        },
                        decoration: InputDecoration(
                          hintText: 'Introduce tu nombre',
                          hintStyle: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: espacioAlto),
                  ],
                ),
                SizedBox(height: espacioAlto),
                // Fila para el nivel
                Row(
                  children: [
                    Text(
                      'Nivel:',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                    SizedBox(width: espacioPadding * 1.5),
                    Text(
                      txtnivel,
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: espacioAlto),
                // Fila para los botones de seleccionar nivel
                Row(
                  children: nivelesList.isNotEmpty
                      ? nivelesList.asMap().entries.map((entry) {
                          int index = entry.key;
                          Nivel nivel = entry.value;
                          return Row(
                            children: [
                              ImageTextButton(
                                image: Image.asset(
                                  'assets/img/niveles/' +
                                      nivel.nombre.toLowerCase() +
                                      '.png',
                                  width: imgWidth,
                                ),
                                text: Text(
                                  nivel.nombre,
                                  style: TextStyle(
                                    fontFamily: 'ComicNeue',
                                    fontSize: textSize,
                                    color: Colors.black,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectGroup(index);
                                  });
                                },
                                buttonColor: btnnivelesFlags[index]
                                    ? Colors.grey
                                    : Colors.transparent,
                              ),
                            ],
                          );
                        }).toList()
                      : [Center(child: Text('No hay niveles disponibles'))],
                ),
                SizedBox(height: espacioAlto * 2),
                Text(
                  '¿Qué quieres hacer?',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: textSize,
                  ),
                ),
                SizedBox(
                  height: espacioAlto,
                ),
                // Fila para los botones de Jugar, Ayuda y Terapeuta
                Row(
                  children: [
                    ImageTextButton(
                      image: Image.asset('assets/img/botones/jugar.png',
                          width: imgWidth),
                      text: Text(
                        'Jugar',
                        style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                            color: Colors.black),
                      ),
                      onPressed: () async {
                        if (this.nombre.trim() != "" &&
                            this.nombre != "Introduce tu nombre" &&
                            selectednivel != null) {
                          Jugador jugador = new Jugador(
                              nombre: nombre.trim(),
                              nivelId: selectednivel!.id);

                          myProvider.jugador = await insertJugador(jugador);
                          myProvider.nivel = selectednivel!;
                          if (widget.juego == 'rutinas')
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JugarRutinas()),
                            );
                          if (widget.juego == 'humor') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JugarHumor()),
                            );
                          }
                          if (widget.juego == 'sentimientos') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => JugarSentimientos()),
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return dialogoCamposIncompletos;
                            },
                          );
                        }
                      },
                    ),
                    ImageTextButton(
                      image: Image.asset('assets/img/botones/ayuda.png',
                          width: imgWidth),
                      text: Text(
                        'Ir a ayuda',
                        style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize,
                            color: Colors.black),
                      ),
                      onPressed: () {
                        if (widget.juego == 'rutinas')
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AyudaRutinas(origen: 'home')),
                          );
                        if (widget.juego == 'humor')
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AyudaHumor(origen: 'home')),
                          );
                        if (widget.juego == 'sentimientos')
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AyudaSentimientos(origen: 'home')),
                          );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///Método que se utiliza para darle valor a las variables relacionadas con tamaños de fuente, imágenes, etc.
  void _createVariablesSize() {
    Size screenSize = MediaQuery.of(context).size; // tamaño del dispositivo

    titleSize = screenSize.width * 0.10;
    textSize = screenSize.width * 0.03;
    espacioPadding = screenSize.height * 0.03;
    espacioAlto = screenSize.width * 0.03;
    imgWidth = screenSize.width / 3 - espacioPadding * 2;
    imgVolverHeight = screenSize.height / 10;
    imgVolverHomeHeight = screenSize.height / 32;
  }

  ///Método encargado de inicializar los cuadros de dialogo que tendrá la pantalla
  void _createDialogs() {
    // CUADROS DE DIALOGO
    // cuadro de dialogo para cuando quiere jugar pero los datos son incompletos
    dialogoCamposIncompletos = AlertDialog(
      title: Text(
        'Aviso',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize,
        ),
      ),
      content: Text(
        "Por favor, recuerda indicarnos tu nombre y nivel para poder medir tu progreso.\n"
        "Mientras no tengamos esos datos, no podemos dejarte jugar. "
        "\n¡Lo sentimos!",
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Row(
          children: [
            ImageTextButton(
                image: Image.asset('assets/img/botones/volver.png',
                    height: imgVolverHeight),
                text: Text(
                  'Volver',
                  style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: textSize,
                      color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ],
    );
  }

  ///Método que nos permite obtener los niveles con los que cuenta la aplicación y almacenarlos en la variable [nivelesList]
  Future<void> _getniveles() async {
    try {
      List<Nivel> niveles = await getNiveles();
      setState(() {
        nivelesList = niveles;
      });
    } catch (e) {
      print("Error al obtener la lista de niveles: $e");
    }
  }

  ///Método que se encarga de que haya únicamente un [selectednivel], es decir, no puede haber más de un nivel
  ///seleccionado a la vez
  void _selectGroup(int index) {
    btnnivelesFlags[index] = !btnnivelesFlags[index]; // se actualiza su pulsación
    if (btnnivelesFlags[index]) {
      // si está activado
      txtnivel = nivelesList[index].nombre; // se muestra el nombre
      selectednivel = nivelesList[index]; // se actualiza el id seleccionado
      for (int i = 0; i < btnnivelesFlags.length; i++) // pongo los demás a false
        if (index != i) btnnivelesFlags[i] = false;
    } else {
      // si con la pulsación ha sido deseleccionado
      txtnivel = "";
      selectednivel = null;
    }
  }
}

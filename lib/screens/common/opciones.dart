import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../db/obj/nivel.dart';
import '../../db/obj/jugador.dart';
import '../../provider/MyProvider.dart';
import '../../widgets/ExitDialog.dart';
import '../../widgets/ImageTextButton.dart';

///Pantalla de opciones, la cual nos permite cambiar el nombre del jugador o nivel al que pertenecemos sin necesidad de salir del juego actual
class Opciones extends StatefulWidget {
  ///Variable que nos indica cual es el juego actual, el valor debe ser: rutinas, humor o sentimientos. Dependiendo de este valor se mostrarán unos textos u otros
  ///y seremos redirigidos a las pantallas que correspondan
  final String juego;

  Opciones({required this.juego});
  @override
  OpcionesState createState() => OpcionesState();
}

/// Estado asociado a la pantalla [Opciones] que gestiona la lógica
/// y la interfaz de usuario de la pantalla
class OpcionesState extends State<Opciones> {
  late bool loadProvider, loadData;
  late List<Nivel> nivelesList; // lista de niveles obtenidos de la BBDD
  late String txtNivel; // texto del nivel seleccionado
  late List<bool>
      btnNivelsFlags; // para tener en cuenta que boton ha sido pulsado

  late String nombre;

  Nivel? selectedNivel = null;

  late double titleSize,
      textSize,
      espacioPadding,
      espacioAlto,
      imgHeight,
      imgWidth,
      imgVolverHeight,
      espacioConfirmar,
      imgBtnWidth;

  // botones
  late ImageTextButton btnSeguir, btnSalir, btnConfirmar, btnAceptar, btnVolver;

  // cuadros de dialogo
  late ExitDialog exitDialog, confirmDialog, incompletDialog;

  @override
  void initState() {
    super.initState();
    loadData = false;
    loadProvider = false;
    _getNivels();
    nivelesList = [];
    txtNivel = "";
    btnNivelsFlags = [false, false, false];
  }

  @override
  Widget build(BuildContext context) {
    if (!loadData) {
      loadData = true;
      _createVariablesSize();
      _createButtons();
      _createDialogs();
    }

    // si es la primera vez, obtengo datos del provider
    if (!loadProvider) {
      loadProvider = true;
      var myProvider = Provider.of<MyProvider>(context);
      nombre = myProvider.jugador.nombre;
      selectedNivel = myProvider.nivel;
      btnNivelsFlags[selectedNivel!.id - 1] = true;
      txtNivel = selectedNivel!.nombre;
    }

    return Scaffold(
      body: SingleChildScrollView(
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
                      if (widget.juego == 'rutinas')
                        Text(
                          'Rutinas',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: titleSize,
                          ),
                        ),
                      if (widget.juego == 'humor')
                        Text(
                          'Humor',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: titleSize,
                          ),
                        ),
                      if (widget.juego == 'sentimientos')
                        Text(
                          'Sentimientos',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: titleSize,
                          ),
                        ),
                      Text(
                        'Opciones',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize / 2,
                        ),
                      ),
                    ],
                  ),
                  ImageTextButton(
                    image: Image.asset(
                      'assets/img/botones/volver.png',
                      height: imgVolverHeight,
                    ),
                    text: Text(
                      'Volver',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // cuadro de dialogo
                          return exitDialog;
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio entre los textos
              Row(
                children: [
                  if (widget.juego == 'rutinas')
                    Expanded(
                      child: Text(
                        'Aquí puedes cambiar diferentes opciones para el juego \'Rutinas\'.\n'
                        'Estas opciones son tu nombre y el nivel al que perteneces.',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                        ),
                      ),
                    ),
                  if (widget.juego == 'humor')
                    Expanded(
                      child: Text(
                        'Aquí puedes cambiar diferentes opciones para el juego \'Humor\'.\n'
                        'Estas opciones son tu nombre y el nivel al que perteneces.',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                        ),
                      ),
                    ),
                  if (widget.juego == 'sentimientos')
                    Expanded(
                      child: Text(
                        'Aquí puedes cambiar diferentes opciones para el juego \'Sentimientos\'.\n'
                        'Estas opciones son tu nombre y el nivel al que perteneces.',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio
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
                  SizedBox(width: espacioAlto),
                  Expanded(
                    child: TextField(
                      onChanged: (text) {
                        this.nombre = text;
                      },
                      decoration: InputDecoration(
                        hintText: nombre,
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
                  SizedBox(width: espacioAlto + espacioAlto / 1.5),
                  Text(
                    txtNivel,
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
                                width: imgBtnWidth,
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
                              buttonColor: btnNivelsFlags[index]
                                  ? Colors.grey
                                  : Colors.transparent,
                            ),
                          ],
                        );
                      }).toList()
                    : [Center(child: Text('No hay niveles disponibles'))],
              ),
              SizedBox(height: espacioConfirmar * 0.75),
              btnConfirmar,
            ],
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
    imgHeight = screenSize.height / 8;
    imgWidth = screenSize.width / 3 - espacioPadding * 2;
    imgVolverHeight = screenSize.height / 32;
    espacioConfirmar = espacioAlto * 2;
    imgBtnWidth = screenSize.width / 5;
  }

  ///Método encargado de inicializar los cuadros de dialogo que tendrá la pantalla
  void _createDialogs() {
    // CUADROS DE DIALOGO
    // cuadro de dialogo para cuando quiere jugar pero los datos son incompletos
    if (widget.juego == 'rutinas')
      exitDialog = ExitDialog(
          title: 'Aviso',
          titleSize: titleSize,
          content:
              "¿Estás seguro de que deseas salir de las opciones del juego 'Rutinas'?\n"
              "De esta manera los posibles cambios que hayas realizado no se guardarán "
              "y volverás al menú del juego \'Rutinas\'.",
          contentSize: textSize,
          leftImageTextButton: btnSeguir,
          rightImageTextButton: btnSalir);

    if (widget.juego == 'humor')
      exitDialog = ExitDialog(
          title: 'Aviso',
          titleSize: titleSize,
          content:
              "¿Estás seguro de que deseas salir de las opciones del juego 'Humor'?\n"
              "De esta manera los posibles cambios que hayas realizado no se guardarán "
              "y volverás al menú del juego \'Rutinas\'.",
          contentSize: textSize,
          leftImageTextButton: btnSeguir,
          rightImageTextButton: btnSalir);

    if (widget.juego == 'sentimientos')
      exitDialog = ExitDialog(
          title: 'Aviso',
          titleSize: titleSize,
          content:
              "¿Estás seguro de que deseas salir de las opciones del juego 'Sentimientos'?\n"
              "De esta manera los posibles cambios que hayas realizado no se guardarán "
              "y volverás al menú del juego \'Rutinas\'.",
          contentSize: textSize,
          leftImageTextButton: btnSeguir,
          rightImageTextButton: btnSalir);

    // cuadro de dialogo para informar de que se han cambiado las opciones
    if (widget.juego == 'rutinas')
      confirmDialog = ExitDialog(
          title: 'Éxito',
          titleSize: titleSize,
          content:
              "Las opciones para el juego 'Rutinas' han sido actualizados con éxito.\n"
              "¡Muchas gracias por tu interés y colaboración!",
          contentSize: textSize,
          leftImageTextButton: btnAceptar);

    if (widget.juego == 'humor')
      confirmDialog = ExitDialog(
          title: 'Éxito',
          titleSize: titleSize,
          content:
              "Las opciones para el juego 'Humor' han sido actualizados con éxito.\n"
              "¡Muchas gracias por tu interés y colaboración!",
          contentSize: textSize,
          leftImageTextButton: btnAceptar);

    if (widget.juego == 'sentimientos')
      confirmDialog = ExitDialog(
          title: 'Éxito',
          titleSize: titleSize,
          content:
              "Las opciones para el juego 'Sentimientos' han sido actualizados con éxito.\n"
              "¡Muchas gracias por tu interés y colaboración!",
          contentSize: textSize,
          leftImageTextButton: btnAceptar);

    // cuadro de dialogo para cuando los campos son incompletos
    incompletDialog = ExitDialog(
        title: "Aviso",
        titleSize: titleSize,
        content:
            "Por favor, recuerda indicarnos tu nombre y nivel para poder medir tu progreso. "
            "Mientras no tengamos esos datos, no podemos dejarte salir de este menú de opciones. "
            "\n¡Lo sentimos!",
        contentSize: textSize,
        leftImageTextButton: btnVolver);
  }

  ///Método encargado de inicializar los botones que tendrá la pantalla
  void _createButtons() {
    // boton para seguir en opciones
    btnSeguir = ImageTextButton(
      image: Image.asset('assets/img/botones/opciones.png', width: imgBtnWidth),
      text: Text(
        'Seguir en opciones',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // boton para salir de opciones
    btnSalir = ImageTextButton(
      image: Image.asset('assets/img/botones/salir.png', width: imgBtnWidth),
      text: Text(
        'Salir',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // boton para confirmar los cambios
    btnConfirmar = ImageTextButton(
      image: Image.asset(
        'assets/img/botones/fin.png',
        width: imgBtnWidth,
      ),
      text: Text(
        'Confirmar',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () async {
        // si hay un nivel seleccionado
        if (selectedNivel != null && nombre.trim().isNotEmpty) {
          Jugador jugador = Jugador(
            nombre: nombre.trim(),
            nivelId: selectedNivel!.id,
          );

          // inserto el jugador si no existe
          jugador = await insertJugador(jugador);

          //actualizo el provider
          var myProvider = Provider.of<MyProvider>(context, listen: false);
          myProvider.jugador = jugador;
          myProvider.nivel = selectedNivel!;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // cuadro de dialogo opciones actualizadas
              return confirmDialog;
            },
          );
          return;
        }
        // cuadro de dialogo opciones incompletas
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // cuadro de dialogo
            return incompletDialog;
          },
        );
      },
    );

    // boton para aceptar que se han actualizado las opciones
    btnAceptar = ImageTextButton(
      image: Image.asset('assets/img/botones/aceptar.png', width: imgBtnWidth),
      text: Text(
        'Aceptar',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // boton para salir del cuadro de dialogo y seguir en opciones
    btnVolver = ImageTextButton(
        image:
            Image.asset('assets/img/botones/volver.png', height: imgHeight / 2),
        text: Text(
          'Volver',
          style: TextStyle(
              fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
        ),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  ///Método que nos permite obtener los niveles con los que cuenta la aplicación y almacenarlos en la variable [nivelesList]
  Future<void> _getNivels() async {
    try {
      List<Nivel> niveles = await getNiveles();
      setState(() {
        nivelesList = niveles;
      });
    } catch (e) {
      print("Error al obtener la lista de niveles: $e");
    }
  }

  ///Método que se encarga de que haya únicamente un [selectedNivel], es decir, no puede haber más de un nivel
  ///seleccionado a la vez
  void _selectGroup(int index) {
    btnNivelsFlags[index] = !btnNivelsFlags[index]; // se actualiza su pulsación
    if (btnNivelsFlags[index]) {
      // si está activado
      txtNivel = nivelesList[index].nombre; // se muestra el nombre
      selectedNivel = nivelesList[index]; // se actualiza el id seleccionado
      for (int i = 0; i < btnNivelsFlags.length; i++) // pongo los demás a false
        if (index != i) btnNivelsFlags[i] = false;
    } else {
      // si con la pulsación ha sido deseleccionado
      txtNivel = "";
      selectedNivel = null;
    }
  }
}

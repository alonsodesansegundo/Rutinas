import 'package:flutter/material.dart';

import '../../db/obj/nivel.dart';
import '../../db/obj/jugador.dart';
import '../../db/obj/jugadorView.dart';
import '../../obj/JugadoresPaginacion.dart';
import '../../widgets/ImageTextButton.dart';

///Pantalla que nos brinda la posibilidad de buscar un jugador a través de su nombre y/o nivel y poder eliminarlo
class RemovePlayer extends StatefulWidget {
  @override
  RemovePlayerState createState() => RemovePlayerState();
}

/// Estado asociado a la pantalla [RemovePlayer] que gestiona la lógica
/// y la interfaz de usuario de la pantalla
class RemovePlayerState extends State<RemovePlayer> {
  late double titleSize,
      textSize,
      espacioPadding,
      espacioAlto,
      imgHeight,
      widthColumn;
  late bool loadData;
  late int jugadoresPagina, paginaActual;
  late String txtBuscar, txtBuscarAux;
  Nivel? selectedNivel, selectedNivelAux;
  late List<Nivel> nivels;
  List<JugadorView>? jugadores;
  late bool hayMasJugadores;
  late ElevatedButton btnAnterior, btnSiguiente, btnBuscar;
  late AlertDialog removePlayerOk;

  @override
  void initState() {
    super.initState();
    loadData = false;
    jugadoresPagina = 5;
    paginaActual = 1;
    txtBuscar = "";
    txtBuscarAux = "";
    selectedNivel = null;
    selectedNivelAux = null;
    nivels = [];
    _getNivels();
    hayMasJugadores = false;
    _loadJugadores();
  }

  @override
  Widget build(BuildContext context) {
    if (!loadData) {
      loadData = true;
      _createVariablesSize();
      _createButtons();
      _createDialogs();
    }

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rutirse',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: titleSize,
                          ),
                        ),
                        Text(
                          'Eliminar jugador',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: titleSize / 2,
                          ),
                        ),
                      ],
                    ),
                    ImageTextButton(
                      image: Image.asset(
                        'assets/img/botones/home.png',
                        height: imgHeight,
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
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                SizedBox(height: espacioAlto),
                Text(
                  "Como terapeuta tienes la posibilidad de eliminar un jugador, lo que implica que se eliminarán todas sus partidas de todos los juegos. "
                  "Los jugadores aparecen ordenados de más antiguo a más reciente.",
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: textSize,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: espacioAlto),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: espacioPadding / 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey[200],
                        ),
                        child: TextField(
                          onChanged: (text) {
                            this.txtBuscarAux = text;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Introduce el nombre del jugador...',
                            hintStyle: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: textSize * 0.75,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: espacioPadding),
                    btnBuscar
                  ],
                ),
                SizedBox(height: espacioAlto / 2),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: espacioPadding / 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[200],
                      ),
                      child: DropdownButton<Nivel>(
                        hint: Text(
                          'Nivel',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: textSize * 0.75,
                          ),
                        ),
                        value: selectedNivelAux,
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              'Nivel',
                              style: TextStyle(
                                fontFamily: 'ComicNeue',
                                fontSize: textSize * 0.75,
                              ),
                            ),
                          ),
                          ...nivels.map((Nivel nivel) {
                            return DropdownMenuItem<Nivel>(
                              value: nivel,
                              child: Text(
                                nivel.nombre,
                                style: TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: textSize * 0.75,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (Nivel? nivel) {
                          setState(() {
                            if (nivel?.nombre == 'Nivel')
                              selectedNivelAux = null;
                            else
                              selectedNivelAux = nivel;
                            paginaActual = 1;
                            selectedNivel = selectedNivelAux;
                            txtBuscar = txtBuscarAux;
                            _loadJugadores();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: espacioAlto),
                Row(
                  children: [
                    SizedBox(width: espacioPadding / 2),
                    Container(
                      width: widthColumn,
                      child: Text(
                        'Jugador',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: widthColumn,
                      child: Text(
                        'Nivel',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                FutureBuilder<void>(
                  future: getAllJugadoresView(
                      paginaActual, jugadoresPagina, txtBuscar, selectedNivel),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (jugadores != null && jugadores!.isNotEmpty) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: jugadores!.length,
                        itemBuilder: (context, index) {
                          final jugador = jugadores![index];
                          return Container(
                            margin: EdgeInsets.only(bottom: espacioAlto),
                            child: Row(
                              children: [
                                SizedBox(width: espacioPadding / 2),
                                Container(
                                  width: widthColumn,
                                  child: Text(
                                    jugador.jugadorName,
                                    style: TextStyle(
                                      fontFamily: 'ComicNeue',
                                      fontSize: textSize * 0.75,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: widthColumn,
                                  child: Text(
                                    jugador.nivelName,
                                    style: TextStyle(
                                      fontFamily: 'ComicNeue',
                                      fontSize: textSize * 0.75,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Aviso',
                                            style: TextStyle(
                                              fontFamily: 'ComicNeue',
                                              fontSize: titleSize * 0.75,
                                            ),
                                          ),
                                          content: Text(
                                            'Estás a punto de eliminar al jugador ${jugador.jugadorName} del nivel ${jugador.nivelName}.\n'
                                            '¿Estás seguro de ello?',
                                            style: TextStyle(
                                              fontFamily: 'ComicNeue',
                                              fontSize: textSize,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _removePlayer(jugador.id);
                                                    setState(() {
                                                      _loadJugadores();
                                                    });
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return removePlayerOk;
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    'Sí, eliminar',
                                                    style: TextStyle(
                                                      fontFamily: 'ComicNeue',
                                                      fontSize: textSize,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: espacioPadding,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Cancelar',
                                                    style: TextStyle(
                                                      fontFamily: 'ComicNeue',
                                                      fontSize: textSize,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Text(
                        "No hemos encontrado resultados.",
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                          color: Colors.black,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: espacioAlto),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (paginaActual != 1)
                      Row(
                        children: [
                          btnAnterior,
                          SizedBox(width: espacioPadding)
                        ],
                      ),
                    if (hayMasJugadores) btnSiguiente,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///Método que elimina a un jugador a través de su identificador
  ///<br><b>Parámetros</b><br>
  ///[jugadorId] Identificador del jugador que vamos a eliminar
  void _removePlayer(int jugadorId) {
    deletePlayer(jugadorId);
  }

  ///Método que nos permite obtener los nivels con los que cuenta la aplicación y almacenarlos en la variable [nivels]
  Future<void> _getNivels() async {
    try {
      List<Nivel> nivelsList = await getNiveles();
      setState(() {
        nivels = nivelsList;
      });
    } catch (e) {
      print("Error al obtener la lista de nivels: $e");
    }
  }

  ///Método que se utiliza para darle valor a las variables relacionadas con tamaños de fuente, imágenes, etc.
  void _createVariablesSize() {
    Size screenSize = MediaQuery.of(context).size; // Tamaño del dispositivo

    titleSize = screenSize.width * 0.10;
    textSize = screenSize.width * 0.03;
    espacioPadding = screenSize.height * 0.03;
    espacioAlto = screenSize.width * 0.03;
    imgHeight = screenSize.height / 32;
    widthColumn = screenSize.width * 0.4 - 24;
  }

  ///Método encargado de inicializar los botones que tendrá la pantalla
  void _createButtons() {
    btnAnterior = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
      ),
      onPressed: () {
        _previousPage();
      },
      child: Text(
        'Anterior',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.white),
      ),
    );

    btnSiguiente = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
      ),
      onPressed: () {
        _nextPage();
      },
      child: Text(
        'Siguiente',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.white),
      ),
    );

    btnBuscar = ElevatedButton(
      onPressed: () {
        paginaActual = 1;
        selectedNivel = selectedNivelAux;
        txtBuscar = txtBuscarAux;
        FocusScope.of(context).unfocus();
        _loadJugadores();
      },
      child: Text(
        'Buscar',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.white),
      ),
    );
  }

  ///Método encargado de inicializar los cuadros de dialogo que tendrá la pantalla
  void _createDialogs() {
    removePlayerOk = AlertDialog(
      title: Text(
        'Éxito',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'El jugador ha sido eliminado con éxito.\n'
        '¡Muchas gracias por tu colaboración!',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: textSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///Método que nos permite carcar y realizar la búsqueda de jugadores de forma paginada, para ello se tienen en cuenta las variables:
  ///[paginaActual], [jugadoresPagina], [txtBuscar] y [selectedNivel]
  Future<void> _loadJugadores() async {
    JugadoresPaginacion aux = await getAllJugadoresView(
        paginaActual, jugadoresPagina, txtBuscar, selectedNivel);

    setState(() {
      this.jugadores = aux.jugadores;
      this.hayMasJugadores = aux.hayMasJugadores;
    });
  }

  ///Método que nos permite ir a la página anterior
  void _previousPage() {
    if (paginaActual > 1) {
      setState(() {
        paginaActual--;
      });
      _loadJugadores();
    }
  }

  ///Método que nos permite ir a la página siguiente
  void _nextPage() {
    setState(() {
      paginaActual++;
    });
    _loadJugadores();
  }
}

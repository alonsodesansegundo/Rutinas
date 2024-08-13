import 'package:flutter/material.dart';

import '../../db/obj/grupo.dart';
import '../../db/obj/partida.dart';
import '../../db/obj/partidaView.dart';
import '../../obj/PartidasPaginacion.dart';
import '../../widgets/ImageTextButton.dart';

class AllProgressSentimiento extends StatefulWidget {
  @override
  _AllProgressSentimientoState createState() => _AllProgressSentimientoState();
}

class _AllProgressSentimientoState extends State<AllProgressSentimiento> {
  late bool loadPartidas, loadData;

  late double titleSize,
      textSize,
      espacioPadding,
      espacioAlto,
      imgHeight,
      textHeaderSize,
      imgVolverHeight,
      widthFecha,
      widthJugador,
      widthAciertos,
      widthDuracion;

  late int paginaActual, partidasPagina;

  // botones
  late ImageTextButton btnVolver;

  late ElevatedButton btnAnterior, btnSiguiente, btnBuscar, btnRemoveAll;

  // lista de partidas
  List<PartidaView>? partidas;

  // cabeceras de la tabla
  late DataColumn cabeceraFecha,
      cabeceraUsuario,
      cabeceraProgreso,
      cabeceraDuracion;

  Grupo? selectedGrupo, selectedGrupoAux;

  late String txtBuscar, txtBuscarAux;

  late List<Grupo> grupos;

  late bool hayMasPartidas;

  late List<int> partidasToRemove;

  late List<bool> flagCheck;

  late AlertDialog removePartidaOk, removeAll, removeAllOk, notPartidasSelected;

  @override
  void initState() {
    super.initState();
    loadData = false;
    loadPartidas = false;
    selectedGrupo = null;
    selectedGrupoAux = null;
    txtBuscar = "";
    txtBuscarAux = "";
    paginaActual = 1;
    partidasPagina = 4;
    hayMasPartidas = false;
    _loadProgresos();
    grupos = [];
    _getGrupos();
    partidasToRemove = [];
    flagCheck = [];
    partidas = [];
  }

  @override
  Widget build(BuildContext context) {
    if (!loadData) {
      loadData = true;
      _createVariablesSize();
      _createDialogs();
      _createButtons();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sentimientos',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize,
                        ),
                      ),
                      Text(
                        'Todos los progresos',
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio entre los textos
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'En esta pantalla puedes observar los progresos o resultados en el'
                      ' juego \'Sentimientos\' de todos los usuarios. También tienes la posibilidad de eliminar partidas si lo crees necesario.\n'
                      'Dichos resultados están ordenados de más reciente a más antiguo.',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: espacioAlto),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: espacioPadding / 2),
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
                          hintText:
                              'Introduce el usuario que quieres buscar...',
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
                    child: DropdownButton<Grupo>(
                      hint: Text(
                        'Grupo',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize * 0.75,
                        ),
                      ),
                      value: selectedGrupoAux,
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            'Grupo',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: textSize * 0.75,
                            ),
                          ),
                        ),
                        ...grupos.map((Grupo grupo) {
                          return DropdownMenuItem<Grupo>(
                            value: grupo,
                            child: Text(
                              grupo.nombre,
                              style: TextStyle(
                                fontFamily: 'ComicNeue',
                                fontSize: textSize * 0.75,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (Grupo? grupo) {
                        setState(() {
                          if (grupo?.nombre == 'Grupo')
                            selectedGrupoAux = null;
                          else
                            selectedGrupoAux = grupo;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: espacioAlto),
              Row(
                children: [
                  SizedBox(width: espacioPadding / 4),
                  Container(
                    width: widthFecha,
                    child: Text(
                      'Fecha',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textHeaderSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: widthJugador,
                    child: Text(
                      'Jugador\n(grupo)',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textHeaderSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: widthAciertos,
                    child: Text(
                      'Aciertos\n(de X intentos)',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textHeaderSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: widthDuracion,
                    child: Text(
                      'Duración',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textHeaderSize,
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
                future: getAllPartidasView(paginaActual, partidasPagina,
                    txtBuscar, selectedGrupo, 'Ironias'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (partidas != null && partidas!.isNotEmpty) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: partidas!.length,
                      itemBuilder: (context, index) {
                        final partida = partidas![index];
                        flagCheck.add(false);
                        return Container(
                          margin: EdgeInsets.only(bottom: espacioAlto),
                          child: Row(
                            children: [
                              SizedBox(width: espacioPadding / 4),
                              Container(
                                width: widthFecha,
                                child: Text(
                                  _getFecha(partida.fechaFin),
                                  style: TextStyle(
                                    fontFamily: 'ComicNeue',
                                    fontSize: textSize * 0.6,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                width: widthJugador - 12,
                                child: Text(
                                  partida.jugadorName +
                                      "\n(" +
                                      partida.grupoName +
                                      ")",
                                  style: TextStyle(
                                    fontFamily: 'ComicNeue',
                                    fontSize: textSize * 0.6,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Container(
                                width: widthAciertos,
                                child: Text(
                                  partida.aciertos.toString() +
                                      " (de " +
                                      (partida.fallos + partida.aciertos)
                                          .toString() +
                                      ")",
                                  style: TextStyle(
                                    fontFamily: 'ComicNeue',
                                    fontSize: textSize * 0.6,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                width: widthFecha / 2,
                                child: Text(
                                  _getTime(partida.duracionSegundos),
                                  style: TextStyle(
                                    fontFamily: 'ComicNeue',
                                    fontSize: textSize * 0.6,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Checkbox(
                                value: flagCheck[index],
                                onChanged: (newValue) {
                                  setState(() {
                                    flagCheck[index] = !flagCheck[index];
                                    partidasToRemove.add(partida.id!);
                                  });
                                },
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
                                          'Estás a punto de eliminar una partida del usuario ${partida.jugadorName} del grupo ${partida.grupoName}.\n'
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
                                                  setState(() {
                                                    _removePartidaRutinas(
                                                        partida.id!);
                                                    _loadProgresos();
                                                  });
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return removePartidaOk;
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
                      "No hemos encontrado resultados.\n"
                      "¡Ánima a los usuarios a jugar! Así podrás ver cómo progresan.",
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
              if (this.partidas!.isNotEmpty) btnRemoveAll,
              SizedBox(height: espacioAlto),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (paginaActual != 1)
                    Row(
                      children: [btnAnterior, SizedBox(width: espacioPadding)],
                    ),
                  if (hayMasPartidas) btnSiguiente,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getWidthOfText(String text, BuildContext context) {
    final TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'ComicNeue',
        fontSize: textHeaderSize,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width);
    return tp.width;
  }

  void _createVariablesSize() {
    Size screenSize = MediaQuery.of(context).size;

    titleSize = screenSize.width * 0.10;
    textSize = screenSize.width * 0.03;
    espacioPadding = screenSize.height * 0.03;
    espacioAlto = screenSize.width * 0.03;
    imgHeight = screenSize.width / 5;
    imgVolverHeight = screenSize.height / 32;
    textHeaderSize = screenSize.width * 0.019;
    widthFecha = getWidthOfText(
          'Fecha de \nla partida',
          context,
        ) *
        2;
    widthAciertos = getWidthOfText(
          'Aciertos\n(de X intentos)',
          context,
        ) *
        1.5;
    widthDuracion = getWidthOfText(
          'Duración',
          context,
        ) *
        1.5;

    widthJugador = screenSize.width -
        (espacioPadding * 2.5) -
        (widthFecha + widthAciertos + widthDuracion) -
        (48 * 2);
  }

  void _createButtons() {
    btnVolver = ImageTextButton(
      image: Image.asset('assets/img/botones/volver.png', height: imgHeight),
      text: Text(
        'Volver',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    btnAnterior = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
      ),
      onPressed: () {
        flagCheck = [];
        partidasToRemove = [];
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
        flagCheck = [];
        partidasToRemove = [];
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
        selectedGrupo = selectedGrupoAux;
        txtBuscar = txtBuscarAux;
        flagCheck = [];
        partidasToRemove = [];
        FocusScope.of(context).unfocus();
        _loadProgresos();
      },
      child: Text(
        'Buscar',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.white),
      ),
    );

    btnRemoveAll = ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            if (partidasToRemove.length == 0)
              return notPartidasSelected;
            else
              return removeAll;
          },
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
      ),
      child: Text(
        'Eliminar partidas',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.white),
      ),
    );
  }

  // Metodo para crear los cuadros de dialogo necesarios
  void _createDialogs() {
    notPartidasSelected = AlertDialog(
      title: Text(
        'Aviso',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'No hay ninguna partida seleccionada para eliminar. '
        'Debes seleccionar al menos una partida para eliminar.',
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
    removePartidaOk = AlertDialog(
      title: Text(
        'Éxito',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'La partida ha sido eliminada con éxito.\n'
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

    removeAllOk = AlertDialog(
      title: Text(
        'Éxito',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'Las partidas han sido eliminadas con éxito.\n'
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

    removeAll = AlertDialog(
      title: Text(
        'Aviso',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'Estás a punto de eliminar todas las partidas seleccionadas de manera definitiva.\n'
        '¿Estás seguro de ello?',
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
                for (int i = 0; i < partidasToRemove.length; i++)
                  _removePartidaRutinas(partidasToRemove[i]);
                flagCheck = [];
                partidasToRemove = [];
                setState(() {
                  _loadProgresos();
                });
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return removeAllOk;
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
  }

  String _getFecha(String fecha) {
    return fecha.substring(0, 10);
  }

  String _getTime(int duracionSegundos) {
    int horas = duracionSegundos ~/ 3600;
    int minutos = (duracionSegundos % 3600) ~/ 60;
    int segundos = duracionSegundos % 60;

    String tiempoFormateado = '';

    if (horas > 0) {
      tiempoFormateado += '${horas}h ';
      if (minutos <= 0)
        tiempoFormateado += '${minutos.toString().padLeft(2, '0')}min ';
    }

    if (minutos > 0) {
      tiempoFormateado += '${minutos.toString().padLeft(2, '0')}min ';
    }

    tiempoFormateado += '${segundos.toString().padLeft(2, '0')}s';

    return tiempoFormateado;
  }

  // Método para obtener la lista de grupos de la BBDD
  Future<void> _getGrupos() async {
    try {
      List<Grupo> gruposList = await getGrupos();
      setState(() {
        grupos = gruposList;
      });
    } catch (e) {
      print("Error al obtener la lista de grupos: $e");
    }
  }

  Future<void> _loadProgresos() async {
    PartidasPaginacion aux = await getAllPartidasView(
        paginaActual, partidasPagina, txtBuscar, selectedGrupo, 'Sentimientos');

    setState(() {
      this.partidas = aux.partidas;
      this.hayMasPartidas = aux.hayMasPartidas;
    });
  }

  void _previousPage() {
    if (paginaActual > 1) {
      setState(() {
        paginaActual--;
      });
      _loadProgresos();
    }
  }

  void _nextPage() {
    setState(() {
      paginaActual++;
    });
    _loadProgresos();
  }

  void _removePartidaRutinas(int partidaId) {
    deletePartidaById(partidaId);
  }
}

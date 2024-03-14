import 'dart:convert';
import 'dart:io';

import 'package:TresEnUno/db/obj/grupo.dart';
import 'package:TresEnUno/widgets/ArasaacAccionDialog.dart';
import 'package:TresEnUno/widgets/ArasaacPersonajeDialog.dart';
import 'package:TresEnUno/widgets/ElementAccion.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../../widgets/ImageTextButton.dart';

class AddRutina extends StatefulWidget {
  @override
  _AddRutinaState createState() => _AddRutinaState();
}

class _AddRutinaState extends State<AddRutina> {
  double titleSize = 0.0,
      textSize = 0.0,
      espacioPadding = 0.0,
      espacioAlto = 0.0,
      imgVolverHeight = 0.0,
      textSituacionWidth = 0.0,
      btnWidth = 0.0,
      btnHeight = 0.0,
      imgWidth = 0.0;

  late ImageTextButton btnVolver;

  late bool loadGrupos;

  late List<Grupo> grupos;

  Grupo? selectedGrupo; // Variable para almacenar el grupo seleccionado

  late String situacionText, keywords;

  late ElevatedButton btnPersonajeExistente,
      btnGaleria,
      btnArasaac,
      btnEliminarPersonaje;

  late Dialog existPersonajeDialog;

  late ArasaacPersonajeDialog arasaacPersonajeDialog;

  late ArasaacAccionDialog arasaacAccionDialog;

  late AlertDialog incompletedParamsDialog,
      completedParamsDialog,
      noInternetDialog;

  late List<String> personajes;

  late List<ElementAccion> acciones;

  late bool firstLoad;

  late List<int> personajeImage;

  late Color colorSituacion, colorGrupo;

  @override
  void initState() {
    super.initState();
    grupos = [];
    _getGrupos();
    loadGrupos = false;
    situacionText = "";
    keywords = "";
    personajes = [];
    _getExistsPersonajes('assets/img/personajes/');
    firstLoad = false;
    personajeImage = [];
    acciones = [];
    selectedGrupo = null;
    colorSituacion = Colors.transparent;
    colorGrupo = Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    _updateVariablesSize();
    _createButtons();
    _createDialogs();
    if (!firstLoad) {
      firstLoad = true;
      acciones = [
        ElementAccion(
          text1: 'Acción 1*:',
          numberAccion: 1,
          textSize: textSize,
          espacioPadding: espacioPadding,
          espacioAlto: espacioAlto,
          btnWidth: btnWidth,
          btnHeight: btnHeight,
          onPressedGaleria: () => _selectNewActionGallery(0),
          onPressedArasaac: () => _selectNewActionArasaac(0),
          textSituacionWidth: textSituacionWidth * 0.75,
        ),
        ElementAccion(
          text1: 'Acción 2*:',
          numberAccion: 2,
          textSize: textSize,
          espacioPadding: espacioPadding,
          espacioAlto: espacioAlto,
          btnWidth: btnWidth,
          btnHeight: btnHeight,
          onPressedGaleria: () => _selectNewActionGallery(1),
          onPressedArasaac: () => _selectNewActionArasaac(1),
          textSituacionWidth: textSituacionWidth * 0.75,
        ),
      ];
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
                        'Rutinas',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize,
                        ),
                      ),
                      Text(
                        'Añadir rutina',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: titleSize / 2,
                        ),
                      ),
                    ],
                  ),
                  btnVolver,
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio entre los textos
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aquí puedes crear nuevas rutinas para el juego.',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: espacioAlto), // Espacio
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Grupo*:',
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                        ),
                      ),
                      SizedBox(width: espacioPadding),
                      Container(
                        decoration: BoxDecoration(
                          color: colorGrupo,
                        ),
                        child: DropdownButton<Grupo>(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          hint: Text(
                            'Selecciona el grupo',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: textSize,
                            ),
                          ),
                          value: selectedGrupo,
                          items: grupos.map((Grupo grupo) {
                            return DropdownMenuItem<Grupo>(
                              value: grupo,
                              child: Text(
                                grupo.nombre,
                                style: TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: textSize,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Grupo? grupo) {
                            setState(() {
                              selectedGrupo = grupo;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: espacioAlto),
              Text(
                'Situación*:',
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: textSize,
                ),
              ),
              SizedBox(height: espacioAlto / 2),
              Container(
                width: textSituacionWidth,
                decoration: BoxDecoration(
                  color: colorSituacion,
                ),
                child: TextField(
                  onChanged: (text) {
                    this.situacionText = text;
                  },
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              SizedBox(height: espacioAlto), // Espacio entre los textos
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Container(
                    width: espacioPadding * 4.2,
                    child: Text(
                      'Personaje:',
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      btnPersonajeExistente,
                      SizedBox(height: espacioAlto / 3),
                      btnGaleria,
                      SizedBox(height: espacioAlto / 3),
                      btnArasaac,
                      if (personajeImage.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(height: espacioAlto / 3),
                            btnEliminarPersonaje,
                          ],
                        )
                    ],
                  ),
                  SizedBox(width: espacioPadding),
                  if (personajeImage.isNotEmpty)
                    Container(
                      child: Align(
                          alignment: Alignment.center,
                          child: Image.memory(
                            Uint8List.fromList(personajeImage),
                            width: imgWidth,
                          )),
                    ),
                ],
              ),
              SizedBox(height: espacioAlto),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: acciones.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: acciones[index].color),
                        ),
                        child: Row(
                          children: [
                            acciones[index],
                            if (acciones[index].accionImage.isNotEmpty)
                              Row(
                                children: [
                                  SizedBox(width: espacioPadding),
                                  Container(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Image.memory(
                                          Uint8List.fromList(
                                              acciones[index].accionImage),
                                          width: imgWidth,
                                        )),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: espacioAlto * 2),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: _addAccion,
                    child: Text("Añadir acción"),
                  ),
                  SizedBox(width: espacioPadding),
                  if (acciones.length > 2)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: textSize,
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: _removeAccion,
                      child: Text("Eliminar acción"),
                    ),
                ],
              ),
              SizedBox(height: espacioAlto),
              Row(
                children: [
                  const Spacer(), // Agrega un espacio flexible
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(btnWidth, btnHeight),
                      textStyle: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: textSize,
                        color: Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      if (!_completedParams()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return incompletedParamsDialog;
                          },
                        );
                      } else {
                        _addRutina();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return completedParamsDialog;
                          },
                        );
                      }
                    },
                    child: Text("Añadir rutina"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  // Método para obtener todos los path de los personajes
  Future<List<String>> _getExistsPersonajes(String folderPath) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final List<String> imagePaths = manifestMap.keys
        .where((String key) => key.startsWith(folderPath))
        .toList();

    setState(() {
      personajes = imagePaths;
    });

    return imagePaths;
  }

  // Método para darle valor a las variables relacionadas con tamaños de fuente, imagenes, etc.
  void _updateVariablesSize() {
    Size screenSize = MediaQuery.of(context).size; // tamaño del dispositivo

    final isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isHorizontal) {
      titleSize = screenSize.width * 0.08;
      textSize = screenSize.width * 0.02;
      espacioPadding = screenSize.height * 0.06;
      espacioAlto = screenSize.height * 0.03;
      imgVolverHeight = screenSize.height / 10;
      textSituacionWidth = screenSize.width - espacioPadding * 2;
      btnWidth = screenSize.width / 4;
      btnHeight = screenSize.height / 10;
      imgWidth = screenSize.width / 4;
    } else {
      titleSize = screenSize.width * 0.10;
      textSize = screenSize.width * 0.03;
      espacioPadding = screenSize.height * 0.03;
      espacioAlto = screenSize.height * 0.03;
      imgVolverHeight = screenSize.height / 32;
      textSituacionWidth = screenSize.width - espacioPadding * 2;
      btnWidth = screenSize.width / 3;
      btnHeight = screenSize.height / 15;
      imgWidth = screenSize.width / 4;
    }
  }

  // Método para crear los botones necesarios
  void _createButtons() {
    // boton para dar volver a la pantalla principal de rutinas
    btnVolver = ImageTextButton(
      image:
          Image.asset('assets/img/botones/home.png', height: imgVolverHeight),
      text: Text(
        'Volver',
        style: TextStyle(
            fontFamily: 'ComicNeue', fontSize: textSize, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    btnPersonajeExistente = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
        textStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
          color: Colors.blue,
        ),
      ),
      child: Text(
        'Personaje\n '
        'existente',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return existPersonajeDialog;
          },
        );
      },
    );

    btnGaleria = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
      ),
      child: Text(
        'Nuevo personaje\n'
        '(desde galería)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () {
        _selectNewPersonajeGallery();
      },
    );

    btnArasaac = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight),
      ),
      child: Text(
        'Nuevo personaje\n'
        '(desde ARASAAC)',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      onPressed: () async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return noInternetDialog;
            },
          );
        } else if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return arasaacPersonajeDialog;
            },
          );
        }
      },
    );

    btnEliminarPersonaje = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(btnWidth, btnHeight / 2),
      ),
      child: Text(
        'Eliminar personaje',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize * 0.75,
        ),
      ),
      onPressed: () {
        setState(() {
          personajeImage = [];
        });
      },
    );
  }

  // Metodo para crear los cuadros de dialogo necesarios
  void _createDialogs() {
    // cuadro de dialogo para escoger un personaje ya existente
    existPersonajeDialog = Dialog(
      child: Column(
        children: [
          SizedBox(height: espacioAlto),
          Center(
            child: Text(
              'Escoge un personaje',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: textSize,
              ),
            ),
          ),
          SizedBox(height: espacioAlto),
          Expanded(
            child: ListView(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: espacioAlto * 2,
                    mainAxisSpacing: espacioAlto * 2,
                  ),
                  itemCount: personajes.length,
                  itemBuilder: (BuildContext context, int index) {
                    String imagePath = personajes[index];
                    return GestureDetector(
                      onTap: () {
                        _selectExistPersonaje(context, imagePath);
                      },
                      child: Image.asset(imagePath),
                    );
                  },
                ),
                SizedBox(height: espacioAlto * 2),
              ],
            ),
          ),
          SizedBox(height: espacioAlto),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(btnWidth / 2, btnHeight),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'ComicNeue',
                fontSize: textSize,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: espacioAlto),
        ],
      ),
    );

    // cuadro de dialogo para escoger un personaje de arasaac
    arasaacPersonajeDialog = ArasaacPersonajeDialog(
      espacioAlto: espacioAlto,
      espacioPadding: espacioPadding,
      btnWidth: btnWidth,
      btnHeigth: btnHeight,
      imgWidth: imgWidth,
      onPersonajeArasaacChanged: (newValue) async {
        final response = await http.get(Uri.parse(newValue));
        List<int> bytes = response.bodyBytes;
        setState(() {
          personajeImage = bytes;
        });
      },
    );

    // cuadro de dialogo para cuando no se han completado todos los campos obligatorios
    incompletedParamsDialog = AlertDialog(
      title: Text(
        'Error',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'No has completado todos los campos obligatorios para poder añadir una '
        'nueva rutina, revísalo e inténtalo de nuevo.',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
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
        )
      ],
    );

    // cuadro de dialogo para cuando rutina añadida con éxito
    completedParamsDialog = AlertDialog(
      title: Text(
        '¡Fántastico!',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'La rutina se ha sido añadida con éxito. Agradecemos tu colaboración, y los jugadores seguro que todavía más!',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
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
        )
      ],
    );

    // cuadro de diálogo para cuando no hay conexión a internet
    noInternetDialog = AlertDialog(
      title: Text(
        'Problema',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: titleSize * 0.75,
        ),
      ),
      content: Text(
        'Hemos detectado que no tienes conexión a internet, y para realizar esta acción es necesario.\nPor favor, inténtalo de nuevo o más tarde.',
        style: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: textSize,
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
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
        )
      ],
    );
  }

  // Método para cuando selecciono un personaje ya existente
  Future<void> _selectExistPersonaje(
      BuildContext context, String imagePath) async {
    ByteData imageData = await rootBundle.load(imagePath);
    List<int> bytes = imageData.buffer.asUint8List();

    setState(() {
      personajeImage = bytes;
    });
    Navigator.of(context).pop();
  }

  // Método para seleccionar un nuevo personaje desde la galería
  Future<void> _selectNewPersonajeGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image!.path);
      List<int> bytes = await imageFile.readAsBytes();

      setState(() {
        personajeImage = bytes;
      });
    }
  }

  // Método para seleccionar una nueva imagen de accion desde la galeria
  Future<void> _selectNewActionGallery(int index) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image!.path);
      List<int> bytes = await imageFile.readAsBytes();

      setState(() {
        acciones[index].accionImage = bytes;
      });
    }
  }

  // Método para seleccionar una nueva imagen de accion desde ARASAAC
  Future<void> _selectNewActionArasaac(int index) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return noInternetDialog;
        },
      );
    } else if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      ArasaacAccionDialog aux = ArasaacAccionDialog(
        espacioAlto: espacioAlto,
        espacioPadding: espacioPadding,
        btnWidth: btnWidth,
        btnHeigth: btnHeight,
        imgWidth: imgWidth,
        onAccionArasaacChanged: (newValue) async {
          final response = await http.get(Uri.parse(newValue));
          List<int> bytes = response.bodyBytes;
          setState(() {
            acciones[index].accionImage = bytes;
          });
        },
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return aux;
        },
      );
    }
  }

  // método para añadir un nuevo ElementAccion
  void _addAccion() {
    setState(() {
      String accionText = 'Acción ' + (acciones.length + 1).toString();
      if (selectedGrupo != null && selectedGrupo!.nombre == "Adolescencia")
        accionText += ": ";
      else
        accionText += "*:";

      acciones.add(ElementAccion(
        text1: accionText,
        numberAccion: acciones.length + 1,
        textSize: textSize,
        espacioPadding: espacioPadding,
        espacioAlto: espacioAlto,
        btnWidth: btnWidth,
        btnHeight: btnHeight,
        textSituacionWidth: textSituacionWidth,
        onPressedGaleria: () => _selectNewActionGallery(acciones.length),
        onPressedArasaac: () => _selectNewActionArasaac(acciones.length),
      ));
    });
  }

  // método para eliminar el ultimo ElementAccion
  void _removeAccion() {
    setState(() {
      acciones.removeLast();
    });
  }

  // Método para comprobar que los parametros obligatorios están completos
  bool _completedParams() {
    bool correct = true;
    // compruebo que todos los parametros obligatorios están completos
    if (selectedGrupo == null) {
      correct = false;
      setState(() {
        colorGrupo = Colors.redAccent;
      });
    } else
      colorGrupo = Colors.transparent;

    if (situacionText.isEmpty) {
      correct = false;
      setState(() {
        colorSituacion = Colors.redAccent;
      });
    } else
      colorSituacion = Colors.transparent;

    for (int i = 0; i < acciones.length; i++) {
      if (acciones[i].accionImage.isEmpty ||
          (acciones[i].accionText.isEmpty &&
              selectedGrupo?.nombre != "Adolescencia") ||
          acciones[i].accionText.characters.length > 24) {
        correct = false;
        setState(() {
          acciones[i].color = Colors.redAccent;
        });
      } else
        acciones[i].color = Colors.transparent;
    }
    return correct;
  }

  // Método para añadir una pregunta y sus acciones
  Future<void> _addRutina() async {
    int preguntaId = await _addPregunta();
    _addAcciones(preguntaId);
  }

  // Método para añadir una pregunta a la BBDD
  Future<int> _addPregunta() async {
    int preguntaId;
    Database db = await openDatabase('rutinas.db');

    if (personajeImage.isNotEmpty) {
      // Obtén los bytes de la imagen
      preguntaId = await db.rawInsert(
        'INSERT INTO pregunta (enunciado, personajeImg, grupoId) VALUES (?,?,?)',
        [situacionText, Uint8List.fromList(personajeImage), selectedGrupo!.id],
      );
    } else {
      preguntaId = await db.rawInsert(
        'INSERT INTO pregunta (enunciado, grupoId) VALUES (?,?)',
        [situacionText, selectedGrupo!.id],
      );
    }
    return preguntaId;
  }

  Future<void> _addAcciones(int preguntaId) async {
    print("GRUPO --> " + selectedGrupo!.nombre);
    Database db = await openDatabase('rutinas.db');
    for (int i = 0; i < acciones.length; i++) {
      if (selectedGrupo!.nombre != "Adolescencia")
        await db.rawInsert(
          'INSERT INTO accion (texto, orden, imagen, preguntaId) VALUES (?,?,?,?)',
          [
            acciones[i].accionText,
            i,
            Uint8List.fromList(acciones[i].accionImage),
            preguntaId
          ],
        );
      else
        await db.rawInsert(
          'INSERT INTO accion (texto, orden, imagen, preguntaId) VALUES (?,?,?,?)',
          ["", i, Uint8List.fromList(acciones[i].accionImage), preguntaId],
        );
    }
  }
}
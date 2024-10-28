import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///Widget que consiste en un conjunto de widgets necesarios para la creación de una respuesta a la hora de crear una nueva pregunta
///para el juego Sentimientos
class ElementRespuestaSentimientos extends StatefulWidget {
  int? id;
  String text1;
  bool isCorrect;
  double textSize;
  double espacioPadding;
  double espacioAlto;
  double btnWidth;
  double btnHeight;
  double imgWidth;
  final Function() onPressedGaleria;
  final Function() onPressedArasaac;
  String respuestaText;
  List<int> respuestaImage;
  Color color;
  final TextEditingController accionTextController = TextEditingController();
  bool flagDificil;
  bool showPregunta;

  ///Constructor de la clase ElementRespuestaSentimientos
  ElementRespuestaSentimientos({
    this.id = -1,
    required this.text1,
    required this.isCorrect,
    required this.textSize,
    required this.espacioPadding,
    required this.espacioAlto,
    required this.btnWidth,
    required this.btnHeight,
    required this.imgWidth,
    required this.onPressedGaleria,
    required this.onPressedArasaac,
    this.respuestaText = "",
    this.respuestaImage = const [],
    this.color = Colors.transparent,
    this.flagDificil = false,
    required this.showPregunta,
  });

  @override
  _ElementRespuestaSentimientosState createState() =>
      _ElementRespuestaSentimientosState();
}

/// Estado asociado al widget [ElementRespuestaSentimientos] que gestiona la lógica
/// y la interfaz de usuario del widget
class _ElementRespuestaSentimientosState
    extends State<ElementRespuestaSentimientos> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (!widget.flagDificil)
              Row(
                children: [
                  Column(
                    children: [
                      if (!widget.flagDificil && widget.isCorrect)
                        Container(
                          width: widget.espacioPadding,
                          child: Text(
                            widget.text1 + "\ncorrecta*:",
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: widget.textSize,
                            ),
                          ),
                        ),
                      if (!widget.flagDificil && !widget.isCorrect)
                        Container(
                          width: widget.espacioPadding,
                          child: Text(
                            widget.text1 + "\nincorrecta*:",
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: widget.textSize,
                            ),
                          ),
                        ),
                      Container(
                        width: widget.espacioPadding,
                        child: Text(
                          "(máx. 30 caracteres)",
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: widget.textSize * 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: widget.btnWidth * 1.75,
                    height: widget.textSize * 4.5,
                    child: TextField(
                      controller:
                          TextEditingController(text: widget.respuestaText),
                      onChanged: (text) {
                        widget.respuestaText = text;
                      },
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: widget.textSize,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        SizedBox(height: widget.espacioAlto / 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (widget.flagDificil && widget.isCorrect)
              Container(
                width: widget.espacioPadding,
                child: Text(
                  'Imagen \nrespuesta\ncorrecta*:',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: widget.textSize,
                  ),
                ),
              ),
            if (widget.flagDificil && !widget.isCorrect)
              Container(
                width: widget.espacioPadding,
                child: Text(
                  'Imagen \nrespuesta\nincorrecta*:',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: widget.textSize,
                  ),
                ),
              ),
            if (!widget.flagDificil)
              Container(
                width: widget.espacioPadding,
                child: Text(
                  'Imagen \nrespuesta*:',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: widget.textSize,
                  ),
                ),
              ),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(widget.btnWidth, widget.btnHeight),
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  child: Text(
                    'Imagen\n(desde galería)',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: widget.textSize,
                    ),
                  ),
                  onPressed: widget.onPressedGaleria,
                ),
                SizedBox(height: widget.espacioAlto / 3),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    minimumSize: Size(widget.btnWidth, widget.btnHeight),
                  ),
                  child: Text(
                    'Imagen\n(desde ARASAAC)',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: widget.textSize,
                    ),
                  ),
                  onPressed: widget.onPressedArasaac,
                ),
              ],
            ),
            if (widget.respuestaImage.isNotEmpty)
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: widget.espacioAlto,
                      ),
                      Container(
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.memory(
                            Uint8List.fromList(widget.respuestaImage),
                            width: widget.imgWidth,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
          ],
        ),
        if (widget.showPregunta)
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent, // Color del borde verde
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(height: widget.espacioAlto),
                Text(
                  '¿Es correcta?*',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: widget.textSize,
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: widget.isCorrect,
                          onChanged: (bool? newValue) {
                            setState(() {
                              widget.isCorrect = !widget.isCorrect;
                            });
                          },
                        ),
                        Text(
                          'Sí, si es correcta',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: widget.textSize * 0.75,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: !widget.isCorrect,
                          onChanged: (bool? newValue) {
                            setState(() {
                              widget.isCorrect = !widget.isCorrect;
                            });
                          },
                        ),
                        Text(
                          'No, es incorrecta',
                          style: TextStyle(
                            fontFamily: 'ComicNeue',
                            fontSize: widget.textSize * 0.75,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

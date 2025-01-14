import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../obj/Pictograma.dart';
import '../obj/PictogramasPaginacion.dart';

///Widget que consiste en un cuadro de diálogo para seleccionar un pictograma como imagen haciendo uso de la API de ARASAAC
class ArasaacImageDialog extends StatefulWidget {
  double espacioAlto;
  double espacioPadding;
  double btnWidth;
  double btnHeigth;
  double imgWidth;
  final Function(String) onImageArasaacChanged; // Nuevo Callback

  ///Constructor de la clase ArasaacImageDialog
  ArasaacImageDialog({
    required this.espacioAlto,
    required this.espacioPadding,
    required this.btnWidth,
    required this.btnHeigth,
    required this.imgWidth,
    required this.onImageArasaacChanged, // Incluir el nuevo callback
  });

  @override
  _ArasaacImageDialogState createState() => _ArasaacImageDialogState();
}

/// Estado asociado al widget [ArasaacImageDialog] que gestiona la lógica
/// y la interfaz de usuario del cuadro de diálogo para seleccionar pictogramas.
class _ArasaacImageDialogState extends State<ArasaacImageDialog> {
  PictogramasPaginacion pictogramas =
      PictogramasPaginacion(listaPictogramas: [], elementosPorPagina: 15);
  String keywords = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: widget.espacioAlto),
            const Center(
              child: Text(
                'Busca una imagen desde ARASAAC',
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: widget.espacioAlto),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      onChanged: (text) {
                        setState(() {
                          keywords = text;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Ingresa tu búsqueda...',
                        hintStyle: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(widget.btnWidth * 0.75, widget.btnHeigth * 0.75),
                  ),
                  child: const Text(
                    'Buscar',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () async {
                    await _getPictogramas(keywords);
                    FocusScope.of(context).unfocus();
                  },
                ),
                SizedBox(width: widget.espacioPadding),
              ],
            ),
            SizedBox(height: widget.espacioAlto),
            if (pictogramas.listaPictogramas.isEmpty)
              const Text(
                "Sin resultados",
                style: TextStyle(
                  fontFamily: 'ComicNeue',
                  fontSize: 18,
                ),
              ),
            SizedBox(height: widget.espacioAlto),
            if (pictogramas.listaPictogramas.isNotEmpty)
              Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    crossAxisSpacing: widget.espacioAlto,
                    mainAxisSpacing: widget.espacioAlto,
                    children: pictogramas
                        .obtenerPictogramasPaginaActual()
                        .map((pictograma) {
                      return GestureDetector(
                        onTap: () {
                          // Llamar al callback para notificar cambios
                          widget.onImageArasaacChanged(pictograma.imagen);
                          Navigator.of(context).pop();
                        },
                        child: Image.network(
                          pictograma.imagen,
                          width: widget.imgWidth,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: widget.espacioAlto),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (pictogramas.paginaActual > 1)
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(widget.btnWidth * 0.75,
                                    widget.btnHeigth * 0.75),
                              ),
                              child: const Text(
                                'Anterior',
                                style: TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  pictogramas.irAPaginaAnterior();
                                });
                                _scrollToTop();
                              },
                            ),
                            SizedBox(width: widget.espacioPadding),
                          ],
                        ),
                      if (pictogramas.hayMasPaginas())
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(widget.btnWidth * 0.75,
                                widget.btnHeigth * 0.75),
                          ),
                          child: const Text(
                            'Siguiente',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              pictogramas.irAPaginaSiguiente();
                            });
                            _scrollToTop();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: widget.espacioAlto),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize:
                        Size(widget.btnWidth * 0.75, widget.btnHeigth * 0.75),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: widget.espacioAlto),
          ],
        ),
      ),
    );
  }

  ///Método que nos permite desplazarnos a la parte superior del cuadro de dialogo
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  ///Método que nos permite realizar una búsqueda de pictogramas a través de una API de ARASAAC a través de palabras clave
  ///<br><b>Parámetros</b><br>
  ///[keywords] Palabras clave con las que queremos realizar la búsqueda
  Future<void> _getPictogramas(String keywords) async {
    final response = await http.get(Uri.parse(
        'https://api.arasaac.org/v1/pictograms/es/search/' + keywords));

    pictogramas.paginaActual = 1;
    if (response.statusCode == 200) {
      // La solicitud fue exitosa, puedes procesar los datos aquí
      List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      List<Pictograma> nuevosPictogramas = [];
      for (int i = 0; i < data.length; i++) {
        Pictograma aux = Pictograma(
            nombre: data[i]['keywords'][0]['keyword'],
            imagen: 'https://static.arasaac.org/pictograms/' +
                data[i]['_id'].toString() +
                '/' +
                data[i]['_id'].toString() +
                '_2500.png');
        nuevosPictogramas.add(aux);
      }
      setState(() {
        pictogramas.listaPictogramas = nuevosPictogramas;
        pictogramas.paginaActual = 1;
      });
    } else {
      // Hubo un error en la solicitud
      setState(() {
        pictogramas.listaPictogramas = [];
        pictogramas.paginaActual = 1;
      });
      print('Error en la solicitud: ${response.statusCode}');
    }
    print("LONGITUD: " + pictogramas.listaPictogramas.length.toString());
  }
}

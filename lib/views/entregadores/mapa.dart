import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  LatLng pontoInicio = LatLng(-20.465200, -45.425750);
  LatLng pontoFim = LatLng(-20.466636, -45.427500);

  List<LatLng> _pontosDaRota = [];

  Future<void> _buscarRota() async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${pontoInicio.longitude},${pontoInicio.latitude};'
      '${pontoFim.longitude},${pontoFim.latitude}'
      '?overview=full&geometries=geojson',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        setState(() {
          // Converte a resposta da API em uma lista de coordenadas LatLng que o Flutter entende
          _pontosDaRota = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
        });
      }
    } catch (e) {
      print("Erro ao buscar rota: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: pontoInicio,
        initialZoom: 17,
        maxZoom: 100,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        if (_pontosDaRota.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _pontosDaRota,
                color: Color(0xFF6C4CF1),
                strokeWidth: 5.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: pontoInicio,
              width: 40,
              height: 40,
              child: Image.asset('assets/imagens/icone.png'),
            ),
            Marker(
              point: pontoFim,
              width: 40,
              height: 40,
              child: Icon(
                Icons.location_on,
                color: Color(0xFF6C4CF1),
                size: 35,
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          child: Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.widthOf(context),
            height: MediaQuery.heightOf(context) * .1,
            child: ElevatedButton(
              onPressed: _buscarRota,
              child: Text('Traçar Rota'),
            ),
          ),
        ),
      ],
    );
  }
}

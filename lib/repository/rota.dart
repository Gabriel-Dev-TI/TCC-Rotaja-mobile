import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

Future<List<LatLng>?> buscarRota(
  BuildContext context,
  Endereco origem,
  Endereco destino,
) async {
  try {
    if (origem.latitude == null ||
        origem.longitude == null ||
        destino.latitude == null ||
        destino.longitude == null) {
      throw Exception("Coordenadas de origem ou destino incompletas.");
    }

    // OSRM aceita: longitude,latitude
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origem.longitude},${origem.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson',
    );

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final dados = json.decode(resposta.body);
      final List cordenadas = dados['routes'][0]['geometry']['coordinates'];

      // GeoJSON retorna [longitude, latitude] -> convertemos para LatLng(latitude, longitude)
      return cordenadas
          .map((cord) => LatLng(cord[1].toDouble(), cord[0].toDouble()))
          .toList();
    } else {
      throw Exception("Falha ao traçar rota no servidor de mapas.");
    }
  } catch (e) {
    if (context.mounted) {
      mostraSnackBar.show(context, e.toString().replaceAll('Exception: ', ''), true);
    }
    return null;
  }
}
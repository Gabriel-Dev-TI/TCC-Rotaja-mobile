import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rotaja/model/entregador.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/widgets/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

Future<String> cadastraEntregador(Entregador entregador) async {
  try {
    final resposta = await Api().post('/entregadores', entregador.toJson());

    if (resposta.statusCode == 201 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', dados['token']);
      await prefs.setString('usuario', jsonEncode(dados['usuario']));
      await prefs.setString('cargo', 'entregador');

      return "Entregador cadastrado com sucesso";

    } else if (resposta.statusCode == 422 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      return dados['mensagem'];

    } else {
      return "Erro ao consultar servidor.";
    }
  } catch (e) {
    return "Falha ao conectar com o servidor. Verifique sua conexão.";
  }
}

Future<double> carregarGanhos() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');

    if (usuarioJson == null) return 0;

    final dados = jsonDecode(usuarioJson);
    final valor = dados['total_ganhos'];
    if (valor == null) return 0;

    return double.tryParse(valor.toString()) ?? 0;
}

Future<double> carregarGanhosAPI() async {
    try {
      final client = Api();
      final resposta = await client.get('/ganhos');

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
        // Se retornou os ganhos atualizados salva localmente tambem

        // Encontra os dados salvos
        final prefs = await SharedPreferences.getInstance();
        final usuarioJson = prefs.getString('usuario');
        final jsonBody = jsonDecode(resposta.body);

        if (usuarioJson != null){
        final dados = jsonDecode(usuarioJson);

        // Salva o novo ganho
        dados['total_ganhos'] = jsonBody['ganhos'];
        final usuarioAtualizado = jsonEncode(dados);
        prefs.setString('usuario', usuarioAtualizado);
        }

        // Retorna o ganho
        return double.tryParse(jsonBody['ganhos']) ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
}

  Future<List<Entregas>?> getEntregasDisponiveis() async {
    try {
      final client = Api();
      final resposta = await client.get('/entregas');

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
        final jsonBody = jsonDecode(resposta.body);
        final List lista = jsonBody['dados'] ?? [];

        return lista.map((item) => Entregas.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> verificaPermissao (BuildContext context) async{
    // Verificar e pedir permissão ANTES de checar o serviço
  LocationPermission permissao = await Geolocator.checkPermission();
  if (permissao == LocationPermission.denied) {
    permissao = await Geolocator.requestPermission();
  }

  if (permissao == LocationPermission.deniedForever) {
    mostraSnackBar.show(context, 'Localização bloqueada. Ative nas configurações do app.', true);
    return false;
  }

  if (permissao != LocationPermission.whileInUse &&
      permissao != LocationPermission.always) {
      mostraSnackBar.show(context, 'Permissão de localização negada.', true);
    
    return false;
  }

  // Agora checar se o serviço está ativo (depois da permissão)
  bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
  if (!servicoAtivo) {
    mostraSnackBar.show(context, 'Ative a localização no dispositivo.', true);
    return false;
  }
  return true;

  }

  Future<Map<String,dynamic>?> rotaEntregador (LatLng posicao,LatLng pontoInicio,String mapboxToken)async{
    try {
      final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${posicao.longitude},${posicao.latitude};'
        '${pontoInicio!.longitude},${pontoInicio!.latitude}'
        '?geometries=geojson&overview=full&steps=false'
        '&access_token=$mapboxToken',
      );

      final request = await http.get(url);
      if (request.statusCode != 200) return null;

      final dados = jsonDecode(request.body);

      if (dados['code'] != 'Ok' ||
          dados['routes'] == null ||
          (dados['routes'] as List).isEmpty) {
        return null;
      }

       final rota = dados['routes'][0];
       final listaRota = (rota['geometry']['coordinates'] as List)
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();
      final distancia = (rota['distance'] as num).toDouble();
      final duracao =  (rota['duration'] as num).toDouble();

      return {
        'rota':listaRota,
        'distancia':distancia,
        'duracao':duracao,
      };
          
    } catch (e) {
    return null;
    }
}
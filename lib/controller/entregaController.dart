import 'dart:convert';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:http/http.dart' as http;

Future<List<Entregas>?> getHistorico() async {
  try {
    final client = Api();
    final resposta = await client.get('/historico');

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final jsonBody = jsonDecode(resposta.body);

      // Trata se o Laravel retornar dentro de 'dados' ou se vier a lista direta
      final List listData = jsonBody is Map<String, dynamic> 
          ? (jsonBody['dados'] ?? jsonBody['data'] ?? []) 
          : jsonBody;

      return listData.map((item) {
        return Entregas.fromJson(item);
      }).toList();
    }
    return null;
  } catch (e) {
    print('Erro ao carregar histórico: $e');
    return null;
  }
}

Future<String> cadastraEntrega(Entregas entrega) async {
  try {
    final resposta = await Api().post('/entregas', entrega.toJson());

    if (resposta.statusCode == 201 && resposta.body.isNotEmpty) {

      return 'Entrega cadastrada com sucesso!';
    } else if (resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      return dados['mensagem'];
    } else {
      return "Erro ao consultar servidor.";
    }
  } catch (e) {
    return 'Falha ao conectar com o servidor. Verifique sua conexão.';
  }
}

Future<Entregas?> getEntregaId(dynamic id) async {
  try {
    final client = Api();
    // Ajustada a interpolação para '/entregas/$id'
    final resposta = await client.get('/entregas/$id');

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final jsonBody = jsonDecode(resposta.body);
      return Entregas.fromJson(jsonBody['dados']);
    }
    return null;
  } catch (e) {
    print('Erro ao buscar entrega por ID: $e');
    return null;
  }
}

Future<Entregas?> calculaRota(Entregas entrega) async {
  if (entrega.origem?.latitude == null ||
      entrega.origem?.longitude == null ||
      entrega.destino?.latitude == null ||
      entrega.destino?.longitude == null) {
    return null;
  }

  try {
    final longitudeOrigem = entrega.origem!.longitude!;
    final latitudeOrigem = entrega.origem!.latitude!;

    final longitudeDestino = entrega.destino!.longitude!;
    final latitudeDestino = entrega.destino!.latitude!;

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$longitudeOrigem,$latitudeOrigem;'
      '$longitudeDestino,$latitudeDestino'
      '?overview=false',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return null;
    }

    final dados = jsonDecode(response.body);

    if (dados['code'] != 'Ok') {
      return null;
    }

    final rota = dados['routes'][0];

    // Distância vem em metros
    final distanciaMetros =
        (rota['distance'] as num).toDouble();

    // Converte para quilômetros
    final distanciaKm = distanciaMetros / 1000;

    // Duração vem em segundos
    final duracaoSegundos =
        (rota['duration'] as num).toDouble();

    // Converte para minutos
    final tempoMinutos =
        (duracaoSegundos / 60).ceil();

    // Coloca os valores no objeto da entrega
    entrega.distancia = distanciaKm;
    entrega.tempoEstimado = tempoMinutos;

    return entrega;
  } catch (e) {
    print('Erro ao calcular rota: $e');
    return null;
  }
}
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

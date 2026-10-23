import 'dart:convert';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';

Future<List<Entregas>?> getHistorico() async {
  try {
    final resposta = await Api().get('/historico');

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final jsonBody = jsonDecode(resposta.body);
      // Pega a lista de json
      final List lista = jsonBody['dados'] ?? [];

      //Converte o json em map
      return lista.map((item) => Entregas.fromJson(item)).toList();
    }
    return null;
  } catch (e) {
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
    return null;
  }
}

Future<Entregas> buscarEntrega(int id) async {
  final client = Api();
  final resposta = await client.get('/entregas/$id');
  if (resposta.statusCode == 200) {
    final body = jsonDecode(resposta.body);
    return Entregas.fromJson(body['dados']);
  }
  throw Exception('Erro');
}

Future<String> cancelarEntrega(Entregas entrega) async {
  try {
    final client = Api();
    final resposta = await client.put(
      '/entregas/${entrega.id}',
      entrega.toJson(),
    );
    if (resposta.statusCode == 200) {
      return 'Entrega cancelada.';
    } else {
      final body = jsonDecode(resposta.body);
      return body['mensagem'] ?? 'Erro ao cancelar a entrega.';
    }
  } catch (e) {
    return 'Erro ao cancelar a entrega.';
  }
}

Future<Entregas?> mudarStatus(Status novoStatus,int id, {String? observacao,}) async {
  try {
    final body = <String, dynamic>{'status': novoStatus.name};
    if (observacao != null && observacao.isNotEmpty) {
      body['observacoes'] = observacao;
    }

    final resposta = await Api().put('/entregas/${id}', body);

    if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
      final data = jsonDecode(resposta.body);
      return Entregas.fromJson(data['dados']);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

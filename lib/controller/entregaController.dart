import 'dart:convert';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';

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
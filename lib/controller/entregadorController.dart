import 'dart:convert';

import 'package:rotaja/model/entregador.dart';
import 'package:rotaja/repository/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> cadastraEntregador(Entregador entregador) async {
  try {
    final resposta = await Api().post('/entregadores', entregador.toJson());

    if (resposta.statusCode == 201 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', dados['token']);
      await prefs.setString('usuario', dados['usuario']);
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

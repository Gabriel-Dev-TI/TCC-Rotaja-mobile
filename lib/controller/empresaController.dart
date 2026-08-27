import 'dart:convert';

import 'package:rotaja/model/empresa.dart';
import 'package:rotaja/repository/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> cadastraEmpresa(Empresa empresa) async {
  try {
    final resposta = await Api().post('/empresas', empresa.toJson());

    if (resposta.statusCode == 201 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', dados['token']);
      await prefs.setString('usuario', jsonEncode(dados['usuario']));
      await prefs.setString('cargo', 'empresa');
      
      final List<dynamic>? listaJson = dados['usuario']['empresa']['enderecos'];
      await prefs.setString('enderecos', jsonEncode(listaJson));

      return 'Empresa cadastrada com sucesso!';
    } else if (resposta.statusCode == 422 && resposta.body.isNotEmpty) {
      final dados = jsonDecode(resposta.body);
      return dados['mensagem'];
    } else {
      return "Erro ao consultar servidor.";
    }
  } catch (e) {
    return 'Falha ao conectar com o servidor. Verifique sua conexão.';
  }
}

import 'dart:convert';
import 'package:rotaja/model/entregador.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

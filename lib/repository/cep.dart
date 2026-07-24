import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rotaja/model/endereco.dart';

class CepService {
  Future<Endereco?> buscarEndereco(String cep) async {
    // Remove caracteres não numéricos
    String cepLimpo = cep.replaceAll(RegExp(r'\D'), '');

    if (cepLimpo.length != 8) return null;

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
      );

      if (response.statusCode == 200) {
        final resposta = json.decode(response.body);

        if (resposta['erro'] == true)
          return null; // A api pode dar erro mesmo com codigo 200

        return Endereco(
          logradouro: resposta['logradouro'] ?? '',
          numero: '',
          bairro: resposta['bairro'] ?? '',
          cep: resposta['cep'] ?? '',
          cidade: resposta['localidade'] ?? '',
          estado: resposta['estado'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Erro na requisição: $e');
      return null;
    }
  }
}

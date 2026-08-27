import 'dart:convert';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/repository/cordenadas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

Future<void> salvarSharedPreferences(Endereco endereco) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? enderecosJson = prefs.getString('enderecos');
  List<Endereco> listaEnderecos = [];

  if (enderecosJson != null && enderecosJson.isNotEmpty) {
    try {
      List<dynamic> lista = jsonDecode(enderecosJson);
      listaEnderecos = lista
          .map((item) => Endereco.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      listaEnderecos = [];
    }
  }

  // Remove duplicados caso o mesmo endereço tenha sido adicionado previamente sem ID
  listaEnderecos.removeWhere((item) =>
      (item.id != null && item.id == endereco.id) ||
      (item.logradouro == endereco.logradouro &&
          item.numero == endereco.numero &&
          item.cep == endereco.cep));

  listaEnderecos.add(endereco);

  final listJson = listaEnderecos.map((e) => e.toJson()).toList();
  await prefs.setString('enderecos', jsonEncode(listJson));
}

Future<List<Endereco>> listarSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? enderecosJson = prefs.getString('enderecos');
  List<Endereco> listaEnderecos = [];

  if (enderecosJson != null && enderecosJson.isNotEmpty) {
    try {
      List<dynamic> lista = jsonDecode(enderecosJson);
      listaEnderecos = lista
          .map((item) => Endereco.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      listaEnderecos = [];
    }
  }

  return listaEnderecos;
}

Future<String> cadastrarEndereco(Endereco endereco) async {
  try {
    final conversao = Cordenadas();
    LatLng? cordenadas = await conversao.converteEmCordenadas(endereco);

    if (cordenadas != null) {
      endereco.latitude = cordenadas.latitude;
      endereco.longitude = cordenadas.longitude;

      final resposta = await Api().post('/enderecos', endereco.toJson());
      
      if (resposta.statusCode == 201 || resposta.statusCode == 200) {
        final body = jsonDecode(resposta.body);
        // Recebe a versão salva no MySQL já com o ID retornado pelo Laravel
        Endereco enderecoSalvo = Endereco.fromJson(body['dados']);

        // Salva no SharedPreferences
        await salvarSharedPreferences(enderecoSalvo);

        return 'Endereço salvo com sucesso!';
      } else {
        return "Erro ao salvar endereço.";
      }
    } else {
      return 'Endereço inválido.';
    }
  } catch (e) {
    return e.toString();
  }
}
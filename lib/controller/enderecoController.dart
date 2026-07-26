import 'dart:convert';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/repository/cordenadas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

Future<void> salvarSharedPreferences(Endereco endereco) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //pega os enderecos do sharedPreferences
  String? enderecosJson = prefs.getString('enderecos');

  //lista para os enderecos maps
  List<Map<String, dynamic>> listaEnderecos = [];

  //Transforma os enderecos de json para uma lista de maps
  if (enderecosJson != null && enderecosJson.isNotEmpty) {
    try {
      List<dynamic> lista = jsonDecode(enderecosJson);

      listaEnderecos = lista
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e) {
      listaEnderecos = [];
    }
  }

  listaEnderecos.add(endereco.toJson());

  await prefs.setString('enderecos', jsonEncode(listaEnderecos));
}

Future<List<Endereco>> listarSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //pega os enderecos do sharedPreference
  String? enderecosJson = prefs.getString('enderecos');

  //lista para os enderecos
  List<Endereco> listaEnderecos = [];

  //Transforma os enderecos de json para uma lista
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
    //Se for possivel converter o endereco em cordenadas é um endereço valido
    final conversao = Cordenadas();
    LatLng? cordenadas = await conversao.converteEmCordenadas(endereco);

    if (cordenadas != null) {
      
      endereco.latitude = cordenadas.latitude;
      endereco.longitude = cordenadas.longitude;

      // Salva no SharedPreferences
      await salvarSharedPreferences(endereco);

      return 'Endereço salvo com sucesso!';
      /*

      final resposta = await Api().post('/enderecos', endereco.toJson());
        if (resposta.statusCode == 201) {
        endereco = Endereco.fromJson(jsonDecode(resposta.body)['endereco']);
      } else {
        return "Erro ao salvar endereço.";
      }*/
      
    } else {
      return 'Endereço inválido.';
    }
  } catch (e) {
    return e.toString();
  }
}

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

  Future<void> removerSharedPreferences(Endereco endereco) async {
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
        
      listaEnderecos.removeWhere((item) =>(item.id != null && item.id == endereco.id));

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

  // Ordena para que o endereço proprio seja sempre o primeiro da lista
  listaEnderecos.sort((a, b) {
  if (a.tipoEndereco == TipoEndereco.proprio) return -1;
  if (b.tipoEndereco == TipoEndereco.proprio) return 1;
  return 0;
  });

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

        if (enderecoSalvo.tipoEndereco == TipoEndereco.proprio) {
          await sincronizarEnderecoProprioNoUsuario(enderecoSalvo);
        }   

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


Future<String> editarEndereco(Endereco endereco) async {
  try {
    final conversao = Cordenadas();
    LatLng? cordenadas = await conversao.converteEmCordenadas(endereco);

    if (cordenadas != null) {

      endereco.latitude = cordenadas.latitude;
      endereco.longitude = cordenadas.longitude;

      final resposta = await Api().put("/enderecos/${endereco.id}", endereco.toJson());
      
      if (resposta.statusCode == 200) {
        final body = jsonDecode(resposta.body);
        Endereco enderecoSalvo = Endereco.fromJson(body['dados']);
        await removerSharedPreferences(endereco);
        await salvarSharedPreferences(enderecoSalvo);

        if (enderecoSalvo.tipoEndereco == TipoEndereco.proprio) {
          await sincronizarEnderecoProprioNoUsuario(enderecoSalvo);
        }   

        return 'Endereço salvo com sucesso!';
      } else {
        final body = jsonDecode(resposta.body);
        return body['mensagem'] ?? 'Erro ao atualizar endereço';
      }
    } else {
      return 'Endereço inválido.';
    }
  } catch (e) {
    return e.toString();
  }
}


Future<String> removeEndereco(Endereco endereco) async {
  try {
      final resposta = await Api().delete("/enderecos/${endereco.id}");
      
      if (resposta.statusCode == 200) {
        await removerSharedPreferences(endereco);
        return 'Endereço removido com sucesso!';
      } else {
        return "Erro ao remover endereço.";
      }
  } catch (e) {
    return e.toString();
  }
}

Future<void> sincronizarEnderecoProprioNoUsuario(Endereco endereco) async {
  final prefs = await SharedPreferences.getInstance();
  final usuarioJson = prefs.getString('usuario');
  if (usuarioJson == null) return;

  final dados = jsonDecode(usuarioJson);
  final empresa = dados['empresa'];
  if (empresa == null) return;

  final List<dynamic> enderecos = empresa['enderecos'] ?? [];

  bool encontrado = false;
  for (int i = 0; i < enderecos.length; i++) {
    if (enderecos[i]['tipo'] == 'proprio') {  
      enderecos[i] = endereco.toJson();
      enderecos[i]['tipo'] = 'proprio';  
      encontrado = true;
      break;
    }
  }

  if (!encontrado) {
    final novo = endereco.toJson();
    novo['tipo'] = 'proprio';
    enderecos.add(novo);
  }

  empresa['enderecos'] = enderecos;
  dados['empresa'] = empresa;
  await prefs.setString('usuario', jsonEncode(dados));
}      
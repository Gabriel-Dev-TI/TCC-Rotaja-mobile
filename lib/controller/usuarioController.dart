

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/model/usuario.dart';
import 'package:rotaja/repository/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> fazLogin ({required TextEditingController email, required TextEditingController senha,required final cargo}) async{

    try {
      final resposta = await Api().post('/login', {
        'email': email.text.trim(),
        'senha': senha.text.trim(),
      });

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
         final dados = jsonDecode(resposta.body);

        // Valida se o cargo retornado bate com a tela atual
        if (dados['usuario']['cargo'] != cargo) {
          return "Sua conta não tem permissão como $cargo";
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', dados['token']);
        await prefs.setString('cargo', dados['usuario']['cargo']);
        await prefs.setString('usuario', jsonEncode(dados['usuario']));

        if(dados['usuario']['cargo'] == 'empresa'){
          final List<dynamic>? listaJson = dados['usuario']['empresa']['enderecos'];

          if (listaJson != null && listaJson.isNotEmpty) {
            await prefs.setString('enderecos', jsonEncode(listaJson));
          }

        }

        return "Login realizado com sucesso";
          
        
      } else if(resposta.statusCode == 401 && resposta.body.isNotEmpty) {
        final dados = jsonDecode(resposta.body);
        return dados['mensagem'];
      }
      else {
        return "Erro ao consultar servidor. ${resposta.statusCode}";
        
      }
    } catch (e) {
      return"Falha ao conectar com o servidor. Verifique sua conexão.";
      }
  

}

Future<void> fazLogout () async{
  await Api().get('/logout');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();      
}

Future<Map<String, dynamic>?> carregaDados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario');

      if (usuarioJson == null || usuarioJson.isEmpty) return null;

      final dados = jsonDecode(usuarioJson);

      final Map<String, dynamic> resultado = {
        'cargo': dados['cargo'],
        'nome': dados['nome'],
        'email': dados['email'],
        'telefone': dados['telefone'],
        'criado_em': dados['data_registro'],
        'cpf': null,
        'cnpj': null,
        'tipo_veiculo': null,
        'endereco': null,
      };

      if (dados['cargo'] == 'empresa') {
        final empresa = dados['empresa'];
        if (empresa != null) {
          resultado['cnpj'] = empresa['cnpj'];
          final List<dynamic>? enderecos = empresa['enderecos'];
          if (enderecos != null && enderecos.isNotEmpty) {
            final enderecoProprio = enderecos.firstWhere(
              (e) => e['tipo'] == 'proprio',
              orElse: () => <String, dynamic>{},
            );
            if (enderecoProprio.isNotEmpty) {
              resultado['endereco'] =
                  '${enderecoProprio['logradouro']}, ${enderecoProprio['numero']}';
            }
          }
        }
      }

      if (dados['cargo'] == 'entregador') {
        final entregador = dados['entregador'];
        if (entregador != null) {
          resultado['cpf'] = entregador['cpf'];
          resultado['tipo_veiculo'] = entregador['tipo_veiculo'];
        }
      }

      return resultado;
    } catch (e) {
      return null;
    }
  }

  
  Future<String> salvarUsuario(Usuario user) async {
    
    if (user.nome.isEmpty || user.email.isEmpty || user.telefone.isEmpty) {
      return 'Preencha todos os campos.';
    }

    try {
      final client = Api();
      final resposta = await client.put('/perfil', {
        'nome': user.nome,
        'email': user.email,
        'telefone': user.telefone,
      });

      if (resposta.statusCode == 200) {
        // Atualiza SharedPreferences local
        final prefs = await SharedPreferences.getInstance();
        final usuarioJson = prefs.getString('usuario');
        if (usuarioJson != null) {
          final dados = jsonDecode(usuarioJson);
          dados['nome'] = user.nome;
          dados['email'] = user.email;
          dados['telefone'] = user.telefone;
          await prefs.setString('usuario', jsonEncode(dados));
        }

        return 'Dados atualizados com sucesso!';
        
      } else {
        final body = jsonDecode(resposta.body);
        return body['mensagem'] ?? 'Erro ao salvar.';
        
      }
    } catch (e) {
      return 'Erro ao atualizar perfil';
   }
}
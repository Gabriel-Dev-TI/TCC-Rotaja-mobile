

import 'dart:convert';
import 'package:flutter/material.dart';
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
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', dados['token']);
        await prefs.setString('cargo', dados['usuario']['cargo']);

        // Valida se o cargo retornado bate com a tela atual
        if (dados['usuario']['cargo'] != cargo) {
          return "Sua conta não tem permissão como $cargo";
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
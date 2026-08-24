import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/repository/api.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    redirecionamento();
  }

  Future<void> redirecionamento() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? cargo = prefs.getString('cargo');
    bool? existeToken = prefs.getString('token') != null;

    if (existeToken && cargo != null) {
      await atualizaDados();
      Navigator.pushReplacementNamed(context,'/${cargo}');
      
    } else {
      Navigator.pushReplacementNamed(context, '/escolha');
    }
  }

  Future<bool> atualizaDados() async {
    try {
      //Busca os dados atualizados do banco de dados
      final resposta = await Api().get('/verifica-dados');

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {

        final dados = jsonDecode(resposta.body);
        final prefs = await SharedPreferences.getInstance();
        final usuario = jsonEncode(dados['dados']);

        await prefs.setString('usuario', usuario);

        if(dados['dados']['cargo'] == 'empresa'){
      
        //Salva o endereco da empresa
        salvarSharedPreferences(
          Endereco(
            logradouro: dados['dados']['endereco']['logradouro'],
            numero: dados['dados']['endereco']['numero'],
            bairro: dados['dados']['endereco']['bairro'],
            cep: dados['dados']['endereco']['cep'],
            cidade: dados['dados']['endereco']['cidade'],
            estado: dados['dados']['endereco']['estado'],
            
          ),
        );

        return true;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/imagens/logo.png',
          width: MediaQuery.sizeOf(context).width * .5,
          height: MediaQuery.sizeOf(context).height * .3,
        ),
        
      ),
    );
  }
}

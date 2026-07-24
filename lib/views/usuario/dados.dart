import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';

class Dados extends StatefulWidget {
  const Dados({super.key});

  @override
  State<Dados> createState() => _DadosState();
}

class _DadosState extends State<Dados> {
  late Future<Map<String, dynamic>?> _dadosFuture;

  @override
  void initState() {
    super.initState();
    //A requisicao ocorre so uma vez
    _dadosFuture = carregaDados();
  }

  Future<Map<String, dynamic>?> carregaDados() async {
    try {
      Api client = Api();
      final request = await client.get('/meu-perfil');

      if (request.statusCode == 200 && request.body.isNotEmpty) {
        final body = jsonDecode(request.body);
        final dados = body['dados'];

        if (dados != null) {
          return {
            'nome': dados['nome']?.toString() ?? 'Não informado',
            'email': dados['email']?.toString() ?? 'Não informado',
            'telefone': dados['telefone']?.toString() ?? 'Não informado',
            'documento': dados['documento']?.toString() ?? 'Não informado',
            'criado_em': dados['criado_em']?.toString() ?? 'Não informado',
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados da Conta')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _dadosFuture,
        builder: (context, snapshot) {

          // Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AnimacaoCarregando();
          }

          // Erro ou sem dados
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return AnimacaoErro();
          }

          final dados = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text("Nome"),
                subtitle: Text(dados['nome']),
                leading: const Icon(Icons.person),
              ),
              const Divider(),
              ListTile(
                title: const Text("E-mail"),
                subtitle: Text(dados['email']),
                leading: const Icon(Icons.email),
              ),
              const Divider(),
              ListTile(
                title: const Text("Senha"),
                subtitle: Text("******"),
                leading: const Icon(Icons.lock_outline_rounded),
                trailing: const Icon(Icons.edit),
              ),
              const Divider(),
              ListTile(
                title: Text(dados['documento'].toString().length == 11 ? 'CPF' : 'CNPJ'),
                subtitle: Text(dados['documento']),
                leading: const Icon(Icons.badge_outlined),
              ),
              const Divider(),
              ListTile(
                title: Text('Telefone'),
                subtitle: Text(dados['telefone']),
                leading: const Icon(Icons.phone),
              ),
              const Divider(),
              ListTile(
                title: const Text("Data de Registro"),
                subtitle: Text(dados['criado_em']),
                leading: const Icon(Icons.calendar_today),
              ),
              
            ],
          );
        },
      ),
    );
  }
}
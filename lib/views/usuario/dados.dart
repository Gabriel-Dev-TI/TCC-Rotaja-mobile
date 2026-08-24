import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _dadosFuture = carregaDados();
  }

  Future<Map<String, dynamic>?> carregaDados() async {
    final prefs = await SharedPreferences.getInstance();

    final usuarioJson = prefs.getString('usuario');

    if (usuarioJson == null || usuarioJson.isEmpty) {
      return null;
    }
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

        final endereco = empresa['endereco'];

        if (endereco != null) {
          resultado['endereco'] =
              '${endereco['logradouro']}, ${endereco['numero']}';
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
  }

  Widget linha({
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.60),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor.isEmpty ? 'Não informado' : valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge
          ),
            const SizedBox(height: 11),
            Divider(
              height: 1,
              color: Theme.of(context)
                  .dividerColor
                  .withValues(alpha: 0.35),
            ),
          
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dados da Conta',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return AnimacaoCarregando();
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return AnimacaoErro();
          }

          final dados = snapshot.data!;
          final bool empresa = dados['cargo'] == 'empresa';

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // NOME
                    Text(
                      dados['nome'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge
                    ),

                    const SizedBox(height: 2),

                    Text(
                      empresa ? 'Empresa' : 'Entregador',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),

                    const SizedBox(height: 20),

                    linha(
                      titulo: 'E-mail',
                      valor: dados['email'] ?? '',
                    ),

                    linha(
                      titulo: 'Telefone',
                      valor: dados['telefone'] ?? '',
                    ),

                    linha(
                      titulo: empresa ? 'CNPJ' : 'CPF',
                      valor: empresa
                          ? dados['cnpj'] ?? ''
                          : dados['cpf'] ?? '',
                    ),

                    linha(
                      titulo: 'Senha',
                      valor: '••••••••',
                    ),

                    linha(
                      titulo: 'Data de registro',
                      valor: dados['criado_em'] ?? '',
                    ),

                    if (empresa)
                      linha(
                        titulo: 'Endereço',
                        valor: dados['endereco'] ?? '',
                      ),
                    if (!empresa)
                      linha(
                        titulo: 'Tipo de veículo',
                        valor:
                            dados['tipo_veiculo'] ?? '',
                      ),

                   ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
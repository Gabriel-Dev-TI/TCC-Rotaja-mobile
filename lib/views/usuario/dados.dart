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
    try {
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
          final List<dynamic>? enderecos = empresa['enderecos'];

          if (enderecos != null && enderecos.isNotEmpty) {
            final enderecoProprio = enderecos.firstWhere(
              (e) => e['tipo'] == 'proprio',
              orElse: () => null,
            );

            if (enderecoProprio != null) {
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
      debugPrint('Erro ao carregar dados do usuário: $e');
      return null;
    }
  }

  Widget _buildItemInfo({
    required IconData icone,
    required String titulo,
    required String valor,
    bool isUltimo = false,
  }) {
    final cores = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cores.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icone,
                  color: cores.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: tema.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valor.isEmpty ? 'Não informado' : valor,
                      style: tema.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isUltimo)
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.15),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dados da Conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AnimacaoCarregando();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const AnimacaoErro();
          }

          final dados = snapshot.data!;
          final bool isEmpresa = dados['cargo'] == 'empresa';
          final String nome = dados['nome'] ?? 'Usuário';

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: cores.primary.withOpacity(0.15),
                            child: Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: cores.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nome,
                            textAlign: TextAlign.center,
                            style: tema.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cores.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isEmpresa ? 'Empresa' : 'Entregador',
                              style: TextStyle(
                                color: cores.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildItemInfo(
                            icone: Icons.email_outlined,
                            titulo: 'E-mail',
                            valor: dados['email'] ?? '',
                          ),
                          _buildItemInfo(
                            icone: Icons.phone_outlined,
                            titulo: 'Telefone',
                            valor: dados['telefone'] ?? '',
                          ),
                          _buildItemInfo(
                            icone: isEmpresa
                                ? Icons.business_outlined
                                : Icons.badge_outlined,
                            titulo: isEmpresa ? 'CNPJ' : 'CPF',
                            valor: isEmpresa
                                ? (dados['cnpj'] ?? '')
                                : (dados['cpf'] ?? ''),
                          ),
                          if (isEmpresa)
                            _buildItemInfo(
                              icone: Icons.location_on_outlined,
                              titulo: 'Endereço',
                              valor: dados['endereco'] ?? '',
                            ),
                          if (!isEmpresa)
                            _buildItemInfo(
                              icone: Icons.two_wheeler_outlined,
                              titulo: 'Tipo de veículo',
                              valor: dados['tipo_veiculo'] ?? '',
                            ),
                          _buildItemInfo(
                            icone: Icons.lock_outline,
                            titulo: 'Senha',
                            valor: '••••••••',
                          ),
                          _buildItemInfo(
                            icone: Icons.calendar_today_outlined,
                            titulo: 'Data de registro',
                            valor: dados['criado_em'] ?? '',
                            isUltimo: true,
                          ),
                        ],
                      ),
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
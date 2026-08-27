import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/widgets/card_button.dart';
import 'package:rotaja/views/widgets/status.dart';

class Painel extends StatefulWidget {
  const Painel({super.key});

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  late Future<List<Entregas>?> _entregasAndamento;

  @override
  void initState() {
    super.initState();
    _entregasAndamento = _getEntregasAndamento();
  }

  Future<List<Entregas>?> _getEntregasAndamento() async {
    try {
      final client = Api();
      final resposta = await client.get('/entregas');

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
        final jsonBody = jsonDecode(resposta.body);

        final List lista = jsonBody['dados'] ?? [];

        return lista.map((item) => Entregas.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar entregas: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text('Olá, Empresa!', style: tema.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'O que você precisa entregar hoje?',
              style: tema.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            CardButton(
              funcao: () => Navigator.pushNamed(context, "/entregaCadastro"),
              titulo: 'Nova Entrega',
              subtitulo: 'Solicitar um entregador',
              icone: Icon(Icons.add_location_alt_outlined),
            ),

            const SizedBox(height: 32),

            Text('Entregas em andamento', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),

            FutureBuilder(
              future: _getEntregasAndamento(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AnimacaoCarregando();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: tema.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: tema.colorScheme.outline),
                    ),
                    child: Center(
                      child: Text(
                        'Nenhuma entrega recente',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }
                final listaEntregas = snapshot.data!;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: listaEntregas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entrega = listaEntregas[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/produto',
                          arguments: entrega,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entrega.empresa!.nome.isNotEmpty
                                            ? entrega.empresa!.nome
                                            : 'Entrega #${entrega.id ?? '---'}',
                                        style: tema.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${entrega.origem!.bairro}  =>  ${entrega.destino!.bairro}',
                                        style: tema.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: .spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    converteStatus(status: entrega.status!,),
                                    Text(
                                      'R\$ ${entrega.preco!.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF7B33F4),
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

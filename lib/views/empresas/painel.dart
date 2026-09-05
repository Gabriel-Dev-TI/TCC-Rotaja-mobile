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
      physics: const BouncingScrollPhysics(),
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
              icone: const Icon(Icons.add_location_alt_outlined),
            ),

            const SizedBox(height: 32),

            Text('Entregas em andamento', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),

            FutureBuilder<List<Entregas>?>(
              future: _entregasAndamento,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AnimacaoCarregando();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 50, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhuma entrega no momento.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }


                final listaEntregas = snapshot.data!;

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: listaEntregas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entrega = listaEntregas[index];

                    final String nomeExibicao =
                        (entrega.empresa?.nome != null && entrega.empresa!.nome!.isNotEmpty)
                            ? entrega.empresa!.nome!
                            : 'Entrega #${entrega.id ?? '---'}';

                    final String bairroOrigem =
                        entrega.origem?.bairro ?? 'Origem N/A';
                    final String bairroDestino =
                        entrega.destino?.bairro ?? 'Destino N/A';

                    final String precoFormatado = entrega.preco != null
                        ? 'R\$ ${entrega.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'R\$ 0,00';

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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeExibicao,
                                    style: tema.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          const Icon(
                                            Icons.radio_button_checked,
                                            color: Colors.deepPurple,
                                            size: 20,
                                          ),
                                          Container(
                                            width: 2,
                                            height: 30,
                                            color: Colors.grey.shade300,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Ponto de Coleta',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                                  entrega.origem!.bairro,
                                                  style: tema.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Column(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Ponto de Entrega',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                                  entrega.destino!.bairro,
                                                  style: tema.textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            
                                          
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (entrega.status != null)
                                  converteStatus(status: entrega.status!),
                                const SizedBox(height: 50),
                                Text(
                                  precoFormatado,
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
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
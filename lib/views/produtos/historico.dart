import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/widgets/status.dart';

class Historico extends StatefulWidget {
  const Historico({super.key});

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  late Future<List<Entregas>?> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _historicoFuture = getHistorico();
  }

  Future<List<Entregas>?> getHistorico() async {
    try {
      final resposta = await Api().get('/historico');

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
        final jsonBody = jsonDecode(resposta.body);

        final List lista = jsonBody['dados'] ?? [];

        return lista.map((item) => Entregas.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
      return null;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 4.0),
            child: Text('Histórico de Pedidos', style: tema.titleLarge),
          ),
          Expanded(
            child: FutureBuilder<List<Entregas>?>(
              future: _historicoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AnimacaoCarregando();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 64),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma entrega encontrada.',
                          style: tema.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final historico = snapshot.data!;

                return ListView.builder(
                  itemCount: historico.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final entrega = historico[index];

                    return InkWell(
                      onTap: (){
                        Navigator.pushNamed(context, '/produto', arguments: entrega);
                      },
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: .stretch,
                            children: [
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(
                                    'Pedido #${entrega.id}',
                                    style: tema.titleMedium,
                                  ),
                      
                                  converteStatus(status: entrega.status!),
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(
                                    '${entrega.data ?? 'Data'} às ${entrega.hora ?? 'Hora'}',
                                    style: tema.bodySmall,
                                  ),
                                  Text(
                                    'R\$ ${entrega.preco.toString()}',
                                    style: tema.titleMedium!.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

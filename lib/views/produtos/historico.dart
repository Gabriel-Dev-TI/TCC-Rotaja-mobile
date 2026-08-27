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

        //Converte o json em map
        return lista.map((item) => Entregas.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
      return null;
    }
  }

  void _atualizarHistorico() {
    setState(() {
      _historicoFuture = getHistorico();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    'Histórico de Pedidos',
                    style: tema.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Entregas>?>(
                  future: _historicoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const AnimacaoCarregando();
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cores.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.history_toggle_off_rounded,
                                size: 56,
                                color: cores.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma entrega encontrada',
                              style: tema.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Seus pedidos aparecerão aqui.',
                              textAlign: TextAlign.center,
                              style: tema.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final historico = snapshot.data!;

                    return RefreshIndicator(
                      onRefresh: () async => _atualizarHistorico(),
                      child: ListView.separated(
                        itemCount: historico.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final entrega = historico[index];
                          return _buildHistoricoCard(
                              context, tema, cores, entrega);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricoCard(
    BuildContext context,
    TextTheme tema,
    ColorScheme cores,
    Entregas entrega,
  ) {
    final valorFormatado = entrega.preco != null
        ? 'R\$ ${entrega.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'R\$ --';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/produto', arguments: entrega);
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cores.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_shipping_outlined,
                              color: cores.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entrega.nomeProduto ??
                                      'Pedido #${entrega.id ?? '---'}',
                                  style: tema.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (entrega.nomeProduto != null)
                                  Text(
                                    '#${entrega.id}',
                                    style: tema.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (entrega.status != null)
                      converteStatus(status: entrega.status!),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          '${entrega.data ?? '--/--'} ${entrega.hora != null ? 'às ${entrega.hora}' : ''}',
                          style: tema.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      valorFormatado,
                      style: tema.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cores.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';

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
      final client = Api();
      final resposta = await client.get('/historico');

      if (resposta.statusCode == 200 && resposta.body.isNotEmpty) {
        final jsonBody = jsonDecode(resposta.body);

        final List listData = jsonBody is Map<String, dynamic>
            ? (jsonBody['dados'] ?? jsonBody['data'] ?? [])
            : jsonBody;

        return listData.map((item) => Entregas.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
      return null;
    }
  }

  Widget _buildStatusBadge(Status status) {
    Color bg;
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case Status.pendente:
        bg = const Color(0xFFFFF7ED);
        color = Colors.orange;
        icon = Icons.schedule_rounded;
        label = 'Pendente';
        break;
      case Status.em_transito:
        bg = const Color(0xFFEFF6FF);
        color = Colors.blue;
        icon = Icons.local_shipping_outlined;
        label = 'Em Trânsito';
        break;
      case Status.concluido:
        bg = const Color(0xFFE8F5E9);
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'Concluído';
        break;
      case Status.cancelado:
        bg = const Color(0xFFFFEBEE);
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
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
            child: Text(
              'Histórico de Pedidos',
              style: tema.titleLarge,
            ),
          ),
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
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma entrega encontrada.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
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

                    final dataFormatada =
                        '${entrega.criadoEm.day.toString().padLeft(2, '0')}/${entrega.criadoEm.month.toString().padLeft(2, '0')}/${entrega.criadoEm.year} • ${entrega.criadoEm.hour.toString().padLeft(2, '0')}:${entrega.criadoEm.minute.toString().padLeft(2, '0')}';

                    // Formatação amigável do texto da rota
                    final origemTexto = entrega.origem.logradouro.isNotEmpty
                        ? entrega.origem.logradouro
                        : (entrega.origem.bairro.isNotEmpty
                            ? entrega.origem.bairro
                            : 'Origem');

                    final destinoTexto = entrega.destino.logradouro.isNotEmpty
                        ? entrega.destino.logradouro
                        : (entrega.destino.bairro.isNotEmpty
                            ? entrega.destino.bairro
                            : 'Destino');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/produto',
                            arguments: entrega,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Linha 1: ID do Pedido e Badge de Status
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x157B33F4),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '#${entrega.id ?? '---'}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7B33F4),
                                        ),
                                      ),
                                    ),
                                    _buildStatusBadge(entrega.status),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Linha 2: Origem / Destino
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '$origemTexto ➔ $destinoTexto',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                Divider(
                                  color: Colors.grey.shade100,
                                  height: 1,
                                ),
                                const SizedBox(height: 12),

                                // Linha 3: Data e Preço (com proteção contra overflow)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              dataFormatada,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'R\$ ${entrega.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF090D16),
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
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';

class Produto extends StatefulWidget {
  const Produto({super.key});

  @override
  State<Produto> createState() => _ProdutoState();
}

class _ProdutoState extends State<Produto> {
  // Cores do App RotaJá
  static const primaryColor = Color(0xFF7B33F4); // Corrigido valor Hex
  static const darkColor = Color(0xFF090D16);

  // Auxiliar para Badge de Status
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
        label = 'Entregue';
        break;
      case Status.cancelado:
        bg = const Color(0xFFFFEBEE);
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
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
    // Recebe o Objeto de Entrega passado via Navigator
    final entrega = ModalRoute.of(context)!.settings.arguments as Entregas;

    // Formatação da data
    final dataFormatada =
        '${entrega.criadoEm.day.toString().padLeft(2, '0')}/${entrega.criadoEm.month.toString().padLeft(2, '0')}/${entrega.criadoEm.year} • ${entrega.criadoEm.hour.toString().padLeft(2, '0')}:${entrega.criadoEm.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Pedido #${entrega.id ?? '---'}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: darkColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Dinâmico e Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(entrega.status),
                Text(
                  dataFormatada,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Percurso do Pedido
            const Text(
              'Percurso do Pedido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 12),

            // Card Timeline (Coleta e Entrega Dinâmicos)
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Ponto de Coleta (Origem)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.radio_button_checked, color: primaryColor, size: 20),
                            Container(
                              width: 2,
                              height: 60,
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
                                style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entrega.empresa.nome.isNotEmpty ? entrega.empresa.nome : 'Empresa Responsável',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entrega.origem.logradouro}, ${entrega.origem.numero} - ${entrega.origem.bairro}, ${entrega.origem.cidade}/${entrega.origem.estado}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Ponto de Entrega (Destino)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          children: [
                            Icon(Icons.location_on, color: Colors.redAccent, size: 22),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ponto de Entrega',
                                style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entrega.destino.logradouro}, ${entrega.destino.numero} - ${entrega.destino.bairro}, ${entrega.destino.cidade}/${entrega.destino.estado}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                              if (entrega.destino.complemento != null && entrega.destino.complemento!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Comp: ${entrega.destino.complemento}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Resumo Financeiro
            const Text(
              'Resumo Financeiro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dimensões', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        Text('${entrega.largura} x ${entrega.altura} cm', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkColor)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor Total',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkColor),
                        ),
                        Text(
                          'R\$ ${entrega.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (entrega.observacoes != null && entrega.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Observações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    entrega.observacoes!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
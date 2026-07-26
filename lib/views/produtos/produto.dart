import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/views/widgets/status.dart';

class Produto extends StatefulWidget {
  const Produto({super.key});

  @override
  State<Produto> createState() => _ProdutoState();
}

class _ProdutoState extends State<Produto> {
  static const primaryColor = Color(0xFF7B33F4);
  static const darkColor = Color(0xFF090D16);

  @override
  Widget build(BuildContext context) {
    // Recebe o Objeto de Entrega passado via Navigator
    final entrega = ModalRoute.of(context)!.settings.arguments as Entregas;

    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${entrega.id}', style: tema.titleLarge),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data: ${entrega.data ?? 'Data'} às ${entrega.hora ?? 'Hora'}',
                  style: tema.bodySmall,
                ),
                converteStatus(status: entrega.status!),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Percurso do Pedido',
              style: tema.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                            const Icon(
                              Icons.radio_button_checked,
                              color: primaryColor,
                              size: 20,
                            ),
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Empresa Responsável',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${entrega.origem.logradouro}, ${entrega.origem.numero} - ${entrega.origem.bairro}, ${entrega.origem.cidade}/${entrega.origem.estado}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
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
                                '${entrega.destino.logradouro}, ${entrega.destino.numero} - ${entrega.destino.bairro}, ${entrega.destino.cidade}/${entrega.destino.estado}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (entrega.destino.complemento != null &&
                                  entrega.destino.complemento!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Comp: ${entrega.destino.complemento}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
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
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dimensões',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${entrega.largura} x ${entrega.altura} cm',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                        Text(
                          'R\$ ${entrega.preco?.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (entrega.observacoes != null &&
                entrega.observacoes!.isNotEmpty) ...[
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    entrega.observacoes!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

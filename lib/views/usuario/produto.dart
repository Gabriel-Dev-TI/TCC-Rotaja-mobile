import 'package:flutter/material.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';
import 'package:rotaja/views/widgets/snackbar.dart';
import 'package:rotaja/views/widgets/status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Produto extends StatefulWidget {
  const Produto({super.key});

  @override
  State<Produto> createState() => _ProdutoState();
}

class _ProdutoState extends State<Produto> {

  late Future<Entregas> _entregaFuture;
  String _cargo = '';
  bool _iniciado = false;

  @override
  void initState() {
    super.initState();
    _carregarCargo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // o didChangeDependencies diferente do initState executa varias vezes
    // Por isso precisa verificar se ja foi inicado a busca
    /// No initState não da para pegar o id passado pelo navigator
    if (!_iniciado) {
      _iniciado = true;
      final id = ModalRoute.of(context)!.settings.arguments as int;
      _entregaFuture = buscarEntrega(id);
    }
  }

  Future<void> _carregarCargo() async {
    final prefs = await SharedPreferences.getInstance();
    final cargo = prefs.getString('cargo') ?? '';
    if (mounted) setState(() => _cargo = cargo);
  }

  void _confirmarCancelamento(Entregas entrega) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Entrega'),
        content: const Text('Tem certeza que deseja cancelar esta entrega?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              String resposta = await cancelarEntrega(entrega);
              bool erro = true;
              if (resposta == 'Entrega cancelada.'){
                erro = false;
              }
              if(!erro){
              Navigator.pop(ctx);
              }
              mostraSnackBar.show(context, resposta, erro);
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Entrega',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Entregas>(
        future: _entregaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const AnimacaoCarregando();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return AnimacaoErro();
          }

          final entrega = snapshot.data!;

          final String nomeProduto = entrega.nomeProduto ?? 'Produto';
          final String precoFormatado = entrega.preco != null
              ? 'R\$ ${entrega.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
              : 'R\$ 0,00';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nomeProduto,
                                  style: tema.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${entrega.data ?? '—'} às ${entrega.hora ?? '—'}',
                                  style: tema.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (entrega.status != null)
                            converteStatus(status: entrega.status!),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        precoFormatado,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cor.primary
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Percurso do Pedido',
                        style: tema.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.radio_button_checked,
                                      color: cor.primary,
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
                                      Text(
                                        'Ponto de Coleta',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cor.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (entrega.origem != null)
                                        Text(
                                          '${entrega.origem!.logradouro}, ${entrega.origem!.numero} • ${entrega.origem!.bairro}',
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
                                      if (entrega.destino != null)
                                        Text(
                                          '${entrega.destino!.logradouro}, ${entrega.destino!.numero} • ${entrega.destino!.bairro}',
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

                      const SizedBox(height: 20),

                      Text(
                        'Resumo do Pedido',
                        style: tema.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _metricaItem(
                                    Icons.straighten,
                                    'Dimensões',
                                    '${entrega.largura?.toStringAsFixed(0)}×${entrega.altura?.toStringAsFixed(0)}×${entrega.comprimento?.toStringAsFixed(0)} cm',
                                  ),
                                ),
                                Expanded(
                                  child: _metricaItem(
                                    Icons.scale,
                                    'Peso',
                                    '${entrega.peso?.toStringAsFixed(1)} kg',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _metricaItem(
                                    Icons.route,
                                    'Distância',
                                    entrega.distancia != null
                                        ? '${entrega.distancia!.toStringAsFixed(1)} km'
                                        : '—',
                                  ),
                                ),
                                Expanded(
                                  child: _metricaItem(
                                    Icons.timer,
                                    'Tempo',
                                    entrega.tempoEstimado != null
                                        ? '${entrega.tempoEstimado} min'
                                        : '—',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (entrega.descricao != null &&
                          entrega.descricao!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Descrição',
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            entrega.descricao!,
                            style: tema.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],

                      if (entrega.observacoes != null &&
                          entrega.observacoes!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Observações',
                          style: tema.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            entrega.observacoes!,
                            style: tema.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],

                      if (_cargo == 'empresa' &&
                          entrega.status == Status.pendente) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => _confirmarCancelamento(entrega),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar Entrega',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricaItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}   
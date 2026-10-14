import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';
import 'package:rotaja/views/widgets/status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Produto extends StatefulWidget {
  const Produto({super.key});

  @override
  State<Produto> createState() => _ProdutoState();
}

class _ProdutoState extends State<Produto> {
  static const primaryColor = Color(0xFF7B33F4);

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
    if (!_iniciado) {
      _iniciado = true;
      final id = ModalRoute.of(context)!.settings.arguments as int;
      _entregaFuture = _buscarEntrega(id);
    }
  }

  Future<Entregas> _buscarEntrega(int id) async {
    final client = Api();
    final resposta = await client.get('/entregas/$id');
    if (resposta.statusCode == 200) {
      final body = jsonDecode(resposta.body);
      return Entregas.fromJson(body['dados']);
    }
    throw Exception('Erro');
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
              try {
                final client = Api();
                final resposta = await client.put('/entregas/${entrega.id}', entrega.toJson());
                if (resposta.statusCode == 200) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entrega cancelada.')));
                    Navigator.pop(context);
                  }
                } else {
                  final body = jsonDecode(resposta.body);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(body['mensagem'] ?? 'Erro.')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')));
              }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Entrega',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
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
                              color: Colors.black.withOpacity(0.05),
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
                              color: Colors.black.withOpacity(0.05),
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
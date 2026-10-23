import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';
import 'package:rotaja/views/widgets/status.dart';
import 'package:rotaja/controller/empresaController.dart';

class Painel extends StatefulWidget {
  const Painel({super.key});

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  late Future<List<Entregas>?> _entregasAndamento;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _entregasAndamento = getEntregasAndamento();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _entregasAndamento = getEntregasAndamento();
      });
    });
  }

  @override
  void dispose() {
     _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: Padding(
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

            ElevatedButton(onPressed:() => Navigator.pushNamed(context, "/entregaCadastro"), child:Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Entrega',
                        style: tema.textTheme.titleMedium?.copyWith(
                          color: Colors.white, 
                        ),
                      ),
                      const SizedBox(height: 4),
                        Text(
                          'Solicitar um entregador',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: Colors.white70, 
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:const Icon(Icons.add_location_alt_outlined),
                    
                  ),
              ],
              ),
            )),

            const SizedBox(height: 32),
            Text('Entregas em andamento', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<List<Entregas>?>(
                future: _entregasAndamento,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: AnimacaoCarregando());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                      return AnimacaoErro();
                    }

                  if (snapshot.data!.isEmpty) {
                    return Center(
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
                    );
                  }

                  final listaEntregas = snapshot.data!;

                  return RefreshIndicator(
                      onRefresh: () async {
                    setState(() {
                       _entregasAndamento = getEntregasAndamento();
                    });},
                      child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: listaEntregas.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cores = Theme.of(context).colorScheme;

                      final entrega = listaEntregas[index];

                      final String nomeExibicao =
                          (entrega.empresa?.nome != null &&
                                  entrega.empresa!.nome!.isNotEmpty)
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
                            arguments: entrega.id,
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
                                color: Colors.black.withValues(alpha: 0.05),
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
                                      style: tema.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.radio_button_checked,
                                              color: cores.primary,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ponto de Coleta',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: cores.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                bairroOrigem,
                                                style: tema.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                         Column(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: cores.error,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ponto de Entrega',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: cores.error,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                bairroDestino,
                                                style: tema.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (entrega.status != null)
                                    converteStatus(status: entrega.status!),
                                  const SizedBox(height: 50),
                                  Text(
                                    precoFormatado,
                                    style:  TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: cores.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                   ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}   
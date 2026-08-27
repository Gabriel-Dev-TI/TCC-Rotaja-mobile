import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/widgets/card_button.dart';

class Painel extends StatefulWidget {
  const Painel({super.key});

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  late Future<List<Entregas>?> _entregasDisponiveisFuture;

  @override
  void initState() {
    super.initState();
    _entregasDisponiveisFuture = _getEntregasDisponiveis();
  }

  Future<List<Entregas>?> _getEntregasDisponiveis() async {
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
    final tema = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, Entregador!',
              style: tema.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pronto para fazer entregas?',
              style: tema.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            CardButton(
              funcao: () {},
              titulo: 'Ganhos',
              subtitulo: 'R\$ 0,00',
              icone: const Icon(Icons.attach_money),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entregas disponíveis',
                  style: tema.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _entregasDisponiveisFuture = _getEntregasDisponiveis();
                    });
                  },
                  child: Text(
                    'Atualizar',
                    style: TextStyle(
                      color: cores.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Entregas>?>(
              future: _entregasDisponiveisFuture,
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
                    return _buildEntregaCard(tema, cores, entrega);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntregaCard(
      TextTheme tema, ColorScheme cores, Entregas entrega) {
    final nomeEmpresa = (entrega.empresa != null &&
            entrega.empresa!.nome != null &&
            entrega.empresa!.nome!.isNotEmpty)
        ? entrega.empresa!.nome!
        : 'Entrega #${entrega.id ?? '---'}';

    final valorFormatado = entrega.preco != null
        ? 'R\$ ${entrega.preco!.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'R\$ 0,00';

    final distanciaFormatada = entrega.distancia != null
        ? '${entrega.distancia!.toStringAsFixed(1)} km'
        : null;

    final bairroOrigem = entrega.origem?.bairro ?? 'Origem não informada';
    final bairroDestino = entrega.destino?.bairro ?? 'Destino não informado';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (entrega.id != null) {
            Navigator.pushNamed(
              context,
              '/mapa',
              arguments: entrega.id,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cores.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: cores.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nomeEmpresa,
                            style: tema.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    valorFormatado,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cores.primary,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, size: 10, color: cores.primary),
                      Container(
                        width: 2,
                        height: 16,
                        color: Colors.grey.shade300,
                      ),
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bairroOrigem,
                          style: tema.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bairroDestino,
                          style: tema.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (distanciaFormatada != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        distanciaFormatada,
                        style: tema.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cores.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aceitar Entrega',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';

class Painel extends StatefulWidget {
  const Painel({super.key});

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  late Future<List<Entregas>?> _entregasDisponiveisFuture;
  bool _disponivel = true;

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

        return lista
            .map((item) => Entregas.fromJson(item))
            .toList();
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
              'Olá, Entregador! 👋',
              style: tema.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Pronto para fazer entregas?',
              style: tema.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status atual',
                                style: tema.titleSmall?.copyWith(color: Colors.grey[600]),
                              ),
                              Switch(
                                value: _disponivel,
                                onChanged: (val) {
                                  setState(() {
                                    _disponivel = val;
                                  });
                                },
                                activeTrackColor: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _disponivel ? 'Disponível' : 'Indisponível',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _disponivel ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                           ( _disponivel
                                ? 'Você está visível para receber novas rotas.'
                                : 'Ative o status para aceitar novos pedidos.'),
                            style: tema.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/imagens/entregador.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
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
                    style: TextStyle(color: cores.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Entregas>?>(
              future: _entregasDisponiveisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AnimacaoCarregando();
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 50, color: Colors.grey[400]),
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: listaEntregas.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
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

  Widget _buildEntregaCard(TextTheme tema, ColorScheme cores, Entregas entrega) {
    
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/mapa',
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
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child:
         Column(
           children: [
             Row(
              children: [
                 
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrega.empresa!.nome.isNotEmpty
                            ? entrega.empresa!.nome
                            : 'Entrega #${entrega.id ?? '---'}',
                        style: tema.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entrega.origem.bairro} => ${entrega.destino.bairro}',
                        style: tema.bodySmall?.copyWith(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${entrega.preco!.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B33F4),
                      ),
                      
                    ),
                    Text(
                      '',
                      style: tema.bodySmall?.copyWith(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
                     ),
                     SizedBox(height: 10,),
                     SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(onPressed: (){}, child: Text('Aceitar Entrega')))
           ],
         ),
      ),
    );
  }
}
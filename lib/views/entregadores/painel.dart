import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/controller/entregadorController.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/widgets/snackbar.dart';


class Painel extends StatefulWidget {
  const Painel({super.key});

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  late Future<List<Entregas>?> _entregasDisponiveisFuture;
  Timer? _timer;
  double _totalGanhos = 0;
  bool buscandoGanho = false;

  @override
  initState(){
    super.initState();
    // Busca no banco de dados as entregas disponiveis
    _entregasDisponiveisFuture = getEntregasDisponiveis();

    // Caso esteja sem internet busca os ganhos salvos no shared
    carregaGanhosLocal();

    // Busca na API os ganhos atualizados
    _carregarGanhos();

    //Coloca um timer de 30 segundo para repetir a requisição de entregas
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _entregasDisponiveisFuture = getEntregasDisponiveis();
        });
      }
    });
  }
  Future<void> carregaGanhosLocal() async{
    _totalGanhos = await carregarGanhos();
  }

  Future<void> _carregarGanhos() async {
  if (buscandoGanho) return;
  setState(() => buscandoGanho = true);
  
  final ganhos = await carregarGanhosAPI();
  if (mounted) {
    setState(() {
      _totalGanhos = ganhos;
      buscandoGanho = false;
    });
  }
  setState(() => buscandoGanho = false);
}

 aceitarEntrega(int id) async{
  final entrega = await mudarStatus(Status.aceita, id);
  if(entrega == null){
    mostraSnackBar.show(context, 'Não foi possível aceitar a entrega', true);
  }
  else{
    setState(() {_entregasDisponiveisFuture = getEntregasDisponiveis();});
    mostraSnackBar.show(context, 'Entrega aceita.', false);
  }

 }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
            ElevatedButton(onPressed: _carregarGanhos, child:Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ganhos',
                        style: tema.titleMedium?.copyWith(
                          color: Colors.white, 
                        ),
                      ),
                      const SizedBox(height: 4),
                        Text(buscandoGanho ? 'Atualizando Saldo...':
                          'R\$ ${_totalGanhos.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: tema.bodySmall?.copyWith(
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
                    child:const Icon(Icons.attach_money),
                    
                  ),
              ],
              ),
            )),
            const SizedBox(height: 32),
            Text(
                  'Entregas disponíveis',
                  style: tema.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
            const SizedBox(height: 12),
            FutureBuilder<List<Entregas>?>(
              future: _entregasDisponiveisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AnimacaoCarregando();
                }
                if (snapshot.hasError || snapshot.data == null) {
                 return AnimacaoErro();
                 
                }

              final listaEntregas = snapshot.data!;

                if (listaEntregas.isEmpty) {
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
                return RefreshIndicator(
                      onRefresh: () async {
                    setState(() {
                      _entregasDisponiveisFuture = getEntregasDisponiveis();
                    });},
                      child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: listaEntregas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entrega = listaEntregas[index];
                    return _buildEntregaCard(tema, cores, entrega);
                  },
                ));
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

    final botaoTexto = (entrega.status == Status.aceita || entrega.status == Status.em_transito) ? 'Vizualizar rota' : 'Aceitar entrega';

    return  InkWell(
        onTap: () {
          if (entrega.id != null) {
            Navigator.pushNamed(
              context,
              '/produto',
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
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
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
                            color: cores.primary.withValues(alpha: 0.15),
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
                  onPressed: () {
                    if(entrega.status == Status.pendente){
                      setState(() {
                        aceitarEntrega(entrega.id!);
                      });
                    }else{
                    Navigator.pushNamed(context,'/mapa',);}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cores.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:Text(
                    botaoTexto,
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
    );
  }
}
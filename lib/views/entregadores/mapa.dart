import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/rota.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  LatLng? pontoInicio;
  LatLng? pontoFim;
  List<LatLng> pontosDaRota = [];
  bool carregando = true;
  bool inicializado = false;
  String? mensagemErro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!inicializado) {
      inicializado = true;
      carregarDadosERota();
    }
  }

  Future<void> carregarDadosERota() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    final id = ModalRoute.of(context)?.settings.arguments;

    if (id == null) {
      setState(() {
        carregando = false;
        mensagemErro = 'ID da entrega não informado.';
      });
      return;
    }

    final entrega = await getEntregaId(id);

    if (entrega == null) {
      setState(() {
        carregando = false;
        mensagemErro = 'Entrega não encontrada no servidor.';
      });
      return;
    }

    // Verifica se os endereços possuem latitude e longitude preenchidos
    if (entrega.origem!.latitude == null ||
        entrega.origem!.longitude == null ||
        entrega.destino!.latitude == null ||
        entrega.destino!.longitude == null) {
      setState(() {
        carregando = false;
        mensagemErro =
            'Os endereços desta entrega não possuem coordenadas cadastradas (Latitude e Longitude).';
      });
      return;
    }

    List<LatLng>? coordenadas = await buscarRota(
      context,
      entrega.origem!,
      entrega.destino!,
    );

    if (coordenadas == null || coordenadas.isEmpty) {
      setState(() {
        carregando = false;
        mensagemErro = 'Não foi possível calcular a rota entre os pontos.';
      });
      return;
    }

    if (mounted) {
      setState(() {
        carregando = false;
        pontosDaRota = coordenadas;
        pontoInicio = LatLng(
          entrega.origem!.latitude!,
          entrega.origem!.longitude!,
        );
        pontoFim = LatLng(
          entrega.destino!.latitude!,
          entrega.destino!.longitude!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota da Entrega'),
        backgroundColor: tema.colorScheme.primary,
        foregroundColor: tema.colorScheme.surface,
      ),
      body: Builder(
        builder: (context) {
          if (carregando) {
            return const Center(child: AnimacaoCarregando());
          }

          if (mensagemErro != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_outlined,
                        size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text(
                      mensagemErro!,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                key: ValueKey(
                    '${pontoInicio?.latitude}_${pontosDaRota.length}'),
                options: MapOptions(
                  initialCenter: pontoInicio ?? const LatLng(0, 0),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  if (pontosDaRota.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: pontosDaRota,
                          color: tema.colorScheme.primary,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                  if (pontoInicio != null && pontoFim != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pontoInicio!,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: tema.colorScheme.primary,
                            size: 35,
                          ),
                        ),
                        Marker(
                          point: pontoFim!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.flag,
                            color: Colors.red,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Concluir Visualização'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
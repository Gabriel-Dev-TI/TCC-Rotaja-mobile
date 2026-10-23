import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:rotaja/controller/entregaController.dart';
import 'package:rotaja/model/entregas.dart';
import 'package:rotaja/repository/rota.dart';
import 'package:rotaja/views/animacoes/animacao_entregador.dart';
import 'package:rotaja/views/widgets/snackbar.dart';
import 'package:rotaja/views/widgets/status.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  late String _mapboxToken;
  LatLng? pontoInicio;
  LatLng? pontoFim;
  LatLng? posicaoEntregador;
  final _distance = const Distance();   

  final MapController _mapController = MapController();

  List<LatLng> rotaEntregadorOrigem = [];
  List<LatLng> rotaOrigemDestino = [];

  // Calculando rota e buscando dados da entrega
  bool carregando = true;

  // é true se a rota ja foi calculada
  bool inicializado = false;

  // Está atualizando o status da entrega
  bool processando = false;

  bool _recalculando = false;
  String? mensagemErro;
  Entregas? _entrega;
  bool _infoExpandida = true;

  double distanciaEntregadorOrigem = 0;
  double tempoEntregadorOrigem = 0;
  double distanciaOrigemDestino = 0;
  double tempoOrigemDestino = 0;

  StreamSubscription<Position>? _subscricaoLocalizacao;
  LatLng? _ultimaPosicaoRota;

  // Calcula a distancia a cada 50m
  static const double _distanciaMinimaRecalculo = 50;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!inicializado) {
      inicializado = true;
      carregarDadosERota();
    }
  }

  @override
  void dispose() {
    _subscricaoLocalizacao?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> carregarDadosERota() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });
     _iniciarGeolocalizacao();
    final dados = await carregarDados();

    if (dados == null) {
      setState(() {
        carregando = false;
        mensagemErro = 'Não foi possível calcular a rota';
      });
      return;
    }

    if (!mounted) return;
    
      final coords = (dados['rota']['geometry']['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      setState(() {
        carregando = false;
        _entrega = Entregas.fromJson(dados['entrega']);

        rotaOrigemDestino = coords;
        distanciaOrigemDestino = (dados['rota']['distance'] as num).toDouble();
        tempoOrigemDestino = (dados['rota']['duration'] as num).toDouble();
        _mapboxToken = dados['token'];

        pontoInicio = LatLng(
          _entrega!.origem!.latitude!,
          _entrega!.origem!.longitude!,
        );
        pontoFim = LatLng(
          _entrega!.destino!.latitude!,
          _entrega!.destino!.longitude!,
        );
      });
  }

  Future<void> _iniciarGeolocalizacao() async {
  // 1. Verificar e pedir permissão ANTES de checar o serviço
  LocationPermission permissao = await Geolocator.checkPermission();
  if (permissao == LocationPermission.denied) {
    permissao = await Geolocator.requestPermission();
  }

  if (permissao == LocationPermission.deniedForever) {
    if (mounted) {
      mostraSnackBar.show(context, 'Localização bloqueada. Ative nas configurações do app.', true);
    }
    return;
  }

  if (permissao != LocationPermission.whileInUse &&
      permissao != LocationPermission.always) {
    if (mounted) {
      mostraSnackBar.show(context, 'Permissão de localização negada.', true);
    }
    return;
  }

  // 2. Agora checar se o serviço está ativo (depois da permissão)
  bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
  if (!servicoAtivo) {
    if (mounted) {
      mostraSnackBar.show(context, 'Ative a localização no dispositivo.', true);
    }
    return;
  }

  // 3. Posição inicial
  try {
    final posicaoInicial = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    _aoMover(posicaoInicial);
  } catch (e) {
    debugPrint('Erro ao obter posição inicial: $e');
  }

  _subscricaoLocalizacao = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).listen(_aoMover, onError: (e) {
    debugPrint('Erro geolocalização: $e');
  });
  }   
  void _aoMover(Position posicao) {
    final novaPosicao = LatLng(posicao.latitude, posicao.longitude);

    if (!mounted) return;

    setState(() {
      posicaoEntregador = novaPosicao;
    });

    if (_ultimaPosicaoRota == null) {
      _ultimaPosicaoRota = novaPosicao;
      _calcularRotaEntregadorOrigem(novaPosicao);
      return;
    }

    final distanciaMovida = _distance(
      _ultimaPosicaoRota!,
      novaPosicao,
    );   

    if (distanciaMovida >= _distanciaMinimaRecalculo) {
      _ultimaPosicaoRota = novaPosicao;
      _calcularRotaEntregadorOrigem(novaPosicao);
    }
  }

  Future<void> _calcularRotaEntregadorOrigem(LatLng posicao) async {
    if (pontoInicio == null || _mapboxToken.isEmpty) return;
    if (_recalculando) return;

    setState(() => _recalculando = true);

    try {
      final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${posicao.longitude},${posicao.latitude};'
        '${pontoInicio!.longitude},${pontoInicio!.latitude}'
        '?geometries=geojson&overview=full&steps=false'
        '&access_token=$_mapboxToken',
      );

      final request = await http.get(url);
      if (request.statusCode != 200) return;

      final dados = jsonDecode(request.body);

      if (dados['code'] != 'Ok' ||
          dados['routes'] == null ||
          (dados['routes'] as List).isEmpty) {
        return;
      }

      final rota = dados['routes'][0];
      final lista = (rota['geometry']['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      if (!mounted) return;
      setState(() {
        rotaEntregadorOrigem = lista;
        distanciaEntregadorOrigem = (rota['distance'] as num).toDouble();
        tempoEntregadorOrigem = (rota['duration'] as num).toDouble();
      });

      _enquadrarRota();
    } catch (e) {
      debugPrint('Erro rota entregador→origem: $e');
    } finally {
      if (mounted) {
        setState(() => _recalculando = false);
      }
    }
  }

  void _enquadrarRota() {
    final todos = <LatLng>[
      if (pontoInicio != null) pontoInicio!,
      if (pontoFim != null) pontoFim!,
      if (posicaoEntregador != null) posicaoEntregador!,
      ...rotaOrigemDestino,
      ...rotaEntregadorOrigem,
    ];
    if (todos.isEmpty) return;
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: todos,
        padding: const EdgeInsets.fromLTRB(40, 80, 40, 260),
      ),
    );
  }

  String _formatarTempo(double segundos) {
    final minutos = (segundos / 60).ceil();
    if (minutos >= 60) {
      final horas = minutos ~/ 60;
      final restantes = minutos % 60;
      return '${horas}h ${restantes}min';
    }
    return '$minutos min';
  }

  String _formatarDistancia(double metros) {
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _mudarStatus(Status novoStatus, {String? observacao}) async {
  if (processando || _entrega == null) return;
  setState(() => processando = true);

  try {
    final entrega = await mudarStatus(novoStatus, _entrega!.id!, observacao: observacao);
    if (entrega == null) {
      mostraSnackBar.show(context, 'Erro ao atualizar', true);
    } else {
      if (entrega?.status != Status.em_transito) {
        Navigator.pushNamedAndRemoveUntil(context, '/entregador', (route) => false);
      }
      mostraSnackBar.show(context, 'Entrega atualizada', false);
    }
  } catch (e) {
    mostraSnackBar.show(context, 'Erro ao atualizar', true);
  } finally {
    if (mounted) setState(() => processando = false);
  }
}   
  
  void _abrirDialogObservacao() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enviar Observação'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escreva sua observação...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.dispose();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final obs = controller.text.trim();
              Navigator.pop(ctx);
              controller.dispose();
              if (obs.isNotEmpty && _entrega != null && _entrega!.status != null) {
                _mudarStatus(_entrega!.status!, observacao: obs);
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _confirmarAcao(String titulo, String mensagem, Status novoStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mudarStatus(novoStatus);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota da Entrega'),
        backgroundColor: cores.primary,
        foregroundColor: cores.surface,
      ),
      body: Builder(
        builder: (context) {
          if (carregando) {
            return AnimacaoEntregador();
          }

          if (mensagemErro != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: 64, color: cores.primary),
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
                key: const ValueKey('mapa_rota'),
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pontoInicio ?? const LatLng(-20.471, -45.420),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken',
                    maxZoom: 20,
                  ),

                  if (rotaEntregadorOrigem.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: rotaEntregadorOrigem,
                          color: cores.primary,
                          strokeWidth: 6.0,
                        ),
                      ],
                    ),

                  if (rotaOrigemDestino.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: rotaOrigemDestino,
                          color: Color.fromARGB(255, 149, 128, 241),
                          strokeWidth: 6.0,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      if (pontoInicio != null)
                        Marker(
                          point: pontoInicio!,
                          width: 44,
                          height: 44,
                          child: _buildMarcador(
                            icon: Icons.apartment,
                            corFundo:cores.primary,
                          ),
                        ),
                      if (pontoFim != null)
                        Marker(
                          point: pontoFim!,
                          width: 44,
                          height: 44,
                          child: _buildMarcador(
                            icon: Icons.home_work,
                            corFundo: cores.primary,
                          ),
                        ),
                      if (posicaoEntregador != null)
                        Marker(
                          point: posicaoEntregador!,
                          width: 44,
                          height: 44,
                          child: _buildMarcador(
                            icon: Icons.local_shipping,
                            corFundo: cores.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildPainelInferior(cores),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarcador({required IconData icon, required Color corFundo}) {
    return Container(
      decoration: BoxDecoration(
        color: corFundo,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 25),
    );
  }

  Widget _buildPainelInferior(ColorScheme cores) {
    final entrega = _entrega;

    if (entrega == null) {
      return const Center(child: Text('Dados indisponíveis'));
    }   

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => _infoExpandida = !_infoExpandida),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              if (_infoExpandida) ...[
                _buildInfoProduto(entrega, cores),
                const SizedBox(height: 12),
                _buildDistanciaTempo(cores),
                const SizedBox(height: 12),
              ],

              _buildBotoesAcao(entrega.status!, cores),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanciaTempo(ColorScheme cores) {
    final distanciaTotal = distanciaEntregadorOrigem + distanciaOrigemDestino;
    final tempoTotal = tempoEntregadorOrigem + tempoOrigemDestino;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              'Distância',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              distanciaTotal > 0
                  ? _formatarDistancia(distanciaTotal)
                  : 'Calculando...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Container(
          width: 1,
          height: 32,
          color: Colors.grey.withValues(alpha:0.2),
        ),
        Column(
          children: [
            Text(
              'Tempo',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              tempoTotal > 0
                  ? _formatarTempo(tempoTotal)
                  : 'Calculando...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoProduto(Entregas entrega, ColorScheme cores) {
    final tema = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cores.primary.withValues(alpha:0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withValues(alpha:0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entrega.nomeProduto ?? 'Produto',
                  style: tema.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'R\$ ${entrega.preco?.toStringAsFixed(2)}',
                style: tema.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cores.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          converteStatus(status: entrega.status!),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.apartment, size: 16, color: Color(0xFF8C6CFF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Retirada: ${entrega.origem?.logradouro ?? ""}, '
                  '${entrega.origem?.numero ?? ""} - '
                  '${entrega.origem?.bairro ?? ""}, '
                  '${entrega.origem?.cidade ?? ""}',
                  style: tema.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.home_work, size: 16, color: Color(0xFFB8A5FF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Destino: ${entrega.destino?.logradouro ?? ""}, '
                  '${entrega.destino?.numero ?? ""} - '
                  '${entrega.destino?.bairro ?? ""}, '
                  '${entrega.destino?.cidade ?? ""}',
                  style: tema.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesAcao(Status status, ColorScheme cores) {
    if (processando) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _mudarStatus(Status.concluido),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Concluir',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _abrirDialogObservacao,
                  label: const Icon(Icons.message_outlined),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarAcao(
                    'Cancelar Entrega',
                    'Tem certeza que deseja cancelar?',
                    Status.cancelado,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  label: const Icon(Icons.cancel_outlined),
                ),
              ),
            ),
          ],
        );

  }
}
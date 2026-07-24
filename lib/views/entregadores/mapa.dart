import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Endereco? enderecoInicio;
  Endereco? enderecoFinal;

  String? idSelecionadoInicio;
  String? idSelecionadoFinal;

  // Coordenadas iniciais temporárias (apenas enquanto não há rota)
  LatLng pontoInicio = const LatLng(-23.55052, -46.633308);
  LatLng pontoFim = const LatLng(-23.55552, -46.635308);

  List<LatLng> _pontosDaRota = [];
  bool _carregandoRota = false;

  Future<void> _buscarRota() async {
    if (enderecoInicio == null || enderecoFinal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione os dois endereços primeiro!')),
      );
      return;
    }

    // Validação extra: Garante que os objetos selecionados possuem coordenadas válidas guardadas
    if (enderecoInicio!.latitude == null || enderecoInicio!.longitude == null ||
        enderecoFinal!.latitude == null || enderecoFinal!.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Um dos endereços selecionados não possui coordenadas salvas.')),
      );
      return;
    }

    setState(() {
      _carregandoRota = true;
    });

    try {
      // Pega direto as propriedades salvas no objeto, sem recalcular por API externa!
      final pInicio = LatLng(enderecoInicio!.latitude!, enderecoInicio!.longitude!);
      final pFim = LatLng(enderecoFinal!.latitude!, enderecoFinal!.longitude!);

      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${pInicio.longitude},${pInicio.latitude};'
        '${pFim.longitude},${pFim.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        setState(() {
          pontoInicio = pInicio;
          pontoFim = pFim;
          _pontosDaRota = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();
          _carregandoRota = false;
        });
      } else {
        throw Exception("Falha ao traçar rota no servidor de mapas.");
      }
    } catch (e) {
      setState(() => _carregandoRota = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camada 1: O Mapa ocupando o fundo
        FlutterMap(
          // O ValueKey reconstrói e move o foco do mapa automaticamente para o ponto de origem da rota
          key: ValueKey('${pontoInicio.latitude}_${_pontosDaRota.length}'),
          options: MapOptions(
            initialCenter: pontoInicio, 
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            if (_pontosDaRota.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _pontosDaRota,
                    color: const Color(0x7B33F4), // Roxo RotaJá
                    strokeWidth: 5.0,
                  ),
                ],
              ),
            if (_pontosDaRota.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: pontoInicio,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Color(0x7B33F4), size: 35),
                  ),
                  Marker(
                    point: pontoFim,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Color(0xFF0012FF), size: 35),
                  ),
                ],
              ),
          ],
        ),

        // Camada 2: Seletores de Endereço no Topo
        Positioned(
          top: 40,
          left: 15,
          right: 15,
          child: FutureBuilder<List<Endereco>>(
            future: listarSharedPreferences(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text("Nenhum endereço cadastrado.", style: TextStyle(color: Color(0xFF475569))),
                );
              }

              List<Endereco> listaDeEnderecos = snapshot.data!;

              return Card( 
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dropdown 1: Origem
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Ponto de Partida",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: idSelecionadoInicio,
                        hint: const Text("Escolha a origem"),
                        isExpanded: true,
                        items: listaDeEnderecos.map((endereco) {
                          String idUnico = "${endereco.cep}_${endereco.numero}";
                          return DropdownMenuItem<String>(
                            value: idUnico,
                            child: Text("${endereco.logradouro}, ${endereco.numero}"),
                          );
                        }).toList(),
                        onChanged: (String? novoId) {
                          setState(() {
                            idSelecionadoInicio = novoId;
                            enderecoInicio = listaDeEnderecos.firstWhere(
                              (e) => "${e.cep}_${e.numero}" == novoId
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Dropdown 2: Destino
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Destino Final",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: idSelecionadoFinal,
                        hint: const Text("Escolha o destino"),
                        isExpanded: true,
                        items: listaDeEnderecos.map((endereco) {
                          String idUnico = "${endereco.cep}_${endereco.numero}";
                          return DropdownMenuItem<String>(
                            value: idUnico,
                            child: Text("${endereco.logradouro}, ${endereco.numero}"),
                          );
                        }).toList(),
                        onChanged: (String? novoId) {
                          setState(() {
                            idSelecionadoFinal = novoId;
                            enderecoFinal = listaDeEnderecos.firstWhere(
                              (e) => "${e.cep}_${e.numero}" == novoId
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Camada 3: Botão de Ação na parte Inferior
        Positioned(
          bottom: 20,
          left: 15,
          right: 15,
          child: SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF090D16), 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _carregandoRota ? null : _buscarRota,
              icon: _carregandoRota 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.navigation),
              label: Text(_carregandoRota ? 'Calculando Rota...' : 'Traçar Rota'),
            ),
          ),
        ),
      ],
    );
  }
}
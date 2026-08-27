import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:rotaja/model/endereco.dart';

class Cordenadas {
  Future<LatLng?> converteEmCordenadas(Endereco endereco) async {
  try {
    // Formata o endereço completo
    final enderecoCompleto = '${endereco.logradouro} ${endereco.numero}, ${endereco.bairro}, ${endereco.cidade}, ${endereco.estado}';

    final url = Uri.parse(
      'https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?'
      'SingleLine=${Uri.encodeComponent(enderecoCompleto)}'
      '&maxLocations=5'
      '&outFields=*'
      '&f=json',
    );

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      // O ArcGIS retorna uma lista de endereços parecidos
      final Map<String, dynamic> dados = json.decode(resposta.body);
      final List<dynamic> candidatos = dados['candidates'] ?? [];

      // Verificamos somente os endereços com score alto e que realmente tenham o número informado
      for (final candidato in candidatos) {
        final score = (candidato['attributes']?['Score'] ?? 0).toDouble();
        final tipoEndereco = candidato['attributes']?['Addr_type'] ?? '';
        final numeroEncontrado = (candidato['attributes']?['AddNum'] ?? '').toString().trim();
        final numeroInformado = endereco.numero.trim();

        /* 
          O campo [Addr_type] pode retornar:
          PointAddress: Localizou exatamente o endereço
          StreetAddressExt: Localizou a rua
        */

        if (score >= 90 &&
            numeroEncontrado == numeroInformado &&
            (tipoEndereco == 'PointAddress' || tipoEndereco == 'StreetAddressExt')) {
          final lat = (candidato['location']?['y'] ?? 0).toDouble();
          final lon = (candidato['location']?['x'] ?? 0).toDouble();
          return LatLng(lat, lon);
        }
      }
    }

    return null;
  } catch (e) {
    print('Erro ao buscar as coordenadas: $e');
    return null;
  }
}   
}

import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:rotaja/model/endereco.dart';

class Cordenadas {
  Future<LatLng?> converteEmCordenadas(Endereco endereco) async {
    try {
      //Formata os caracteres
      final logradouroEncoded = Uri.encodeComponent(endereco.logradouro);
      final numeroEncoded = Uri.encodeComponent(endereco.numero);
      final bairroEncoded = Uri.encodeComponent(endereco.bairro);
      final cidadeEncoded = Uri.encodeComponent(endereco.cidade);
      final estadoEncoded = Uri.encodeComponent(endereco.estado);

      final dadosNaOrdem ='$logradouroEncoded,$numeroEncoded,$bairroEncoded,$cidadeEncoded-$estadoEncoded';
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$dadosNaOrdem',);

      //A api so aceita com headers
      final response = await http.get(url,headers: {'User-Agent': 'Rotaja/1.0', 'Accept-Language': 'pt-BR'},);

      if (response.statusCode == 200) {

        final List<dynamic> dados = json.decode(response.body);

        if (dados.isNotEmpty) {
          final double lat = double.parse(dados[0]['lat'].toString());
          final double lon = double.parse(dados[0]['lon'].toString());
          return LatLng(lat, lon);
        }

      }

      //Se não conseguir as cordenadas pelo endereço, pega só pelo cep

      // Remove caracteres não numéricos
       String cep = endereco.cep.replaceAll(RegExp(r'\D'), '');

      //Pega as cordenadas so pelo cep
      final urlAwesome = Uri.parse('https://cep.awesomeapi.com.br/json/$cep');

      final resposta = await http.get(urlAwesome);

      if (resposta.statusCode == 200) {
        final Map<String, dynamic> dados = json.decode(resposta.body);

        if (dados.containsKey('lat') && dados.containsKey('lng')) {
          final double lat = double.parse(dados['lat'].toString());
          final double lon = double.parse(dados['lng'].toString());

          return LatLng(lat, lon);
          
        }
      }

      

      return null;
    } catch (e) {
      print("Erro ao buscar as cordenadas: $e");
      return null;
    }
  }
}

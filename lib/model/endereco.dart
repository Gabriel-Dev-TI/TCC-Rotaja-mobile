class Endereco {
  int? id;
  String logradouro;
  String numero;
  String bairro;
  String cidade;
  String estado;
  String cep;
  String? complemento;
  double? latitude;
  double? longitude;

  Endereco({
    this.id,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cep,
    required this.cidade,
    this.complemento,
    required this.estado,
    this.latitude,
    this.longitude,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      id:json['id'],
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      cep: json['cep'] ?? '',
      complemento: json['complemento'] ,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude']) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude']) : null,
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'logradouro': logradouro,
    'numero': numero,
    'bairro': bairro,
    'cidade': cidade,
    'estado': estado,
    'cep': cep,
    'complemento': complemento,
    'latitude' : latitude,
    'longitude' : longitude,
  };
}   
}

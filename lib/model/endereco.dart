enum TipoEndereco { proprio, entrega}

class Endereco {
  int? id;
  int? empresaId;
  TipoEndereco? tipoEndereco;
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
    this.empresaId,
    this.tipoEndereco,
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
      empresaId: json['empresa_id'],
      tipoEndereco: TipoEndereco.values.firstWhere((e) => e.name == json['tipo'],orElse: () => TipoEndereco.entrega,),
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
      'empresa_id': empresaId,
      'tipo': tipoEndereco?.name,
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

  // Essencial para o Dropdown saber qual item é igual a qual
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Endereco &&
          runtimeType == other.runtimeType &&
          (id != null && other.id != null
              ? id == other.id
              : logradouro == other.logradouro &&
                  numero == other.numero &&
                  cep == other.cep);

  @override
  int get hashCode => id != null 
      ? id.hashCode 
      : Object.hash(logradouro, numero, cep);
  
}

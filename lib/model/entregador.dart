import 'package:rotaja/model/usuario.dart';

enum TipoVeiculo { carro, moto, bike, caminhao, outro }

class Entregador extends Usuario {
  String cpf;
  TipoVeiculo tipoVeiculo;
  bool disponivel;

  Entregador({
    super.id,
    required super.telefone,
    required super.nome,
    required super.email,
    required super.senha,
    required super.cargo,
    super.criadoEm,
    required this.cpf,
    required this.tipoVeiculo,
    this.disponivel = false,
  });

  factory Entregador.fromJson(Map<String, dynamic> json) {
    return Entregador(
      id: json['id'],
      telefone: json['telefone'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      cargo: Cargo.values.firstWhere(
        (e) => e.name == json['cargo'],
        orElse: () => Cargo.entregador,
      ),
      cpf: json['cpf'] ?? '',
      tipoVeiculo: TipoVeiculo.values.firstWhere(
        (e) => e.name == json['tipo_veiculo'],
        orElse: () => TipoVeiculo.outro,
      ),

      disponivel:json['disponivel'] == 'true',

      criadoEm: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telefone': telefone,
      'nome': nome,
      'email': email,
      'senha': senha,
      'cargo': cargo.name,
      'created_at': criadoEm?.toIso8601String(),
      'cpf': cpf,
      'tipo_veiculo': tipoVeiculo.name,
      'disponivel': disponivel,
    };
  }
}

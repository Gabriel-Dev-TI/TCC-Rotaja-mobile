import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/usuario.dart';

class Empresa extends Usuario {
  String cnpj;
  Endereco? endereco;

  Empresa({
    super.id,
    required super.telefone,
    required super.nome,
    required super.email,
    required super.senha,
    required super.cargo,
    super.criadoEm,
    required this.cnpj,
    this.endereco,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      senha: json['senha'] ?? '',
      cargo: Cargo.values.firstWhere((e) => e.name == json['cargo'],orElse: () => Cargo.empresa,),
      criadoEm: json['created_at'] ?? json['data_registro'],
      cnpj: json['cnpj'] ?? '',
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] != null ? Endereco.fromJson(json['endereco']): null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'cargo': cargo.name,
      'cnpj': cnpj,
      'telefone': telefone,
      'endereco': endereco?.toJson(),
    };
  }
}

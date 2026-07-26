import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:rotaja/controller/entregadorController.dart';
import 'package:rotaja/model/entregador.dart';
import 'package:rotaja/model/usuario.dart';
import 'package:rotaja/views/animacoes/animacao_carregandoBtn.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class EntregadorCadastro extends StatefulWidget {
  const EntregadorCadastro({super.key});

  @override
  State<EntregadorCadastro> createState() => _EntregadorCadastroState();
}

class _EntregadorCadastroState extends State<EntregadorCadastro> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();

  TipoVeiculo? _tipoVeiculoSelecionado;
  bool senhaObscure = true;
  bool isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  String formatarNomeVeiculo(TipoVeiculo tipo) {
    switch (tipo) {
      case TipoVeiculo.carro:
        return 'Carro';
      case TipoVeiculo.moto:
        return 'Moto';
      case TipoVeiculo.bike:
        return 'Bicicleta';
      case TipoVeiculo.caminhao:
        return 'Caminhão';
      case TipoVeiculo.outro:
        return 'Outro';
    }
  }

  void cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final entregador = Entregador(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      senha: _senhaController.text,
      cpf: _cpfController.text.trim(),
      tipoVeiculo: _tipoVeiculoSelecionado!,
      cargo: Cargo.entregador,
    );

    String resposta = await cadastraEntregador(entregador);

    if (resposta == "Entregador cadastrado com sucesso") {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/entregador',
        (route) => false,
      );
      mostraSnackBar.show(context, resposta, false);
    } else {
      mostraSnackBar.show(context, resposta, true);
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final primaryColor = tema.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: tema.colorScheme.surface),
        title: Text(
          'Cadastro de Entregador',
          style: tema.textTheme.titleLarge!.copyWith(
            color: tema.colorScheme.surface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.badge_outlined, size: 60, color: primaryColor),
                const SizedBox(height: 10),
                Text(
                  'Crie sua conta',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  'Preencha seus dados para começar a realizar entregas.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(height: 10),

                Card(
                  color: tema.colorScheme.surface,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            label: Text('Nome Completo'),
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o seu nome completo';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            label: Text('E-mail'),
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o seu e-mail';
                            }
                            if (!EmailValidator.validate(value.trim())) {
                              return 'Digite um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _senhaController,
                          obscureText: senhaObscure,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  senhaObscure = !senhaObscure;
                                });
                              },
                              icon: Icon(
                                senhaObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: tema.colorScheme.tertiary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a sua senha';
                            }
                            if (value.length < 6) {
                              return 'A senha deve possuir no mínimo 6 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefoneController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            label: Text('Telefone'),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o telefone';
                            }
                            final RegExp regex = RegExp(
                              r'^\+?(?:\d{2})?\s?\(?\d{2}\)?\s?9\d{4}-?\d{4}$',
                            );
                            if (!regex.hasMatch(value)) {
                              return 'Telefone inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            label: Text('CPF'),
                            prefixIcon: Icon(Icons.subtitles_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o seu CPF';
                            }
                            if (value.trim().length != 11) {
                              return 'Digite um CPF válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<TipoVeiculo>(
                          decoration: InputDecoration(
                            label: Text('Tipo de Veículo'),
                            prefixIcon: Icon(Icons.motorcycle),
                          ),
                          hint: Text(
                            'Selecione um veículo',
                            style: tema.textTheme.bodyMedium,
                          ),
                          items: TipoVeiculo.values.map((TipoVeiculo item) {
                            return DropdownMenuItem<TipoVeiculo>(
                              value: item,
                              child: Text(
                                formatarNomeVeiculo(item),
                                style: tema.textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (TipoVeiculo? novoValor) {
                            setState(() {
                              _tipoVeiculoSelecionado = novoValor;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione um tipo de veículo';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : cadastrar,
                    child: isLoading
                        ? AnimacaoCarregandoBtn()
                        : Text(
                            'Cadastrar',
                            style: tema.textTheme.bodyLarge!.copyWith(
                              color: tema.colorScheme.surface,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

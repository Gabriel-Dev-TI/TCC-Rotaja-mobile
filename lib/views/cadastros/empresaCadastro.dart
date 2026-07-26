import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:rotaja/controller/empresaController.dart';
import 'package:rotaja/model/empresa.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/model/usuario.dart';
import 'package:rotaja/views/animacoes/animacao_carregandoBtn.dart';
import 'package:rotaja/views/widgets/dropdownitems.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class EmpresaCadastro extends StatefulWidget {
  const EmpresaCadastro({super.key});

  @override
  State<EmpresaCadastro> createState() => _EmpresaCadastroState();
}

class _EmpresaCadastroState extends State<EmpresaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _telefoneController = TextEditingController();

  Endereco? _enderecoController;
  bool senhaObscure = true;
  bool isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_enderecoController == null) {
      mostraSnackBar.show(
        context,
        'Selecione ou cadastre um endereço para a empresa.',
        true,
      );
      return;
    }

    setState(() => isLoading = true);

    Empresa empresa = Empresa(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text.trim(),
      senha: _senhaController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      endereco: _enderecoController,
      cargo: Cargo.empresa,
    );

    String resposta = await cadastraEmpresa(empresa);
    bool cadastroFalhou = resposta != 'Empresa cadastrada com sucesso!';
    if (!cadastroFalhou) {
      Navigator.pushNamedAndRemoveUntil(context, '/empresa', (route) => false);
    }
    mostraSnackBar.show(context, resposta, cadastroFalhou);

    setState(() => isLoading = false);
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
          'Cadastro de Empresa',
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
                  'Preencha seus dados para começar\na realizar entregas.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(height: 10),

                Card(
                  color: tema.colorScheme.onSecondary,
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
                              return 'Informe o nome completo';
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
                          controller: _cnpjController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            label: Text('CNPJ'),
                            prefixIcon: Icon(Icons.subtitles_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o seu CNPJ';
                            }
                            if (value.trim().length != 14) {
                              return 'Digite um CNPJ válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        DropDownEndereco(
                          enderecoSelecionado: _enderecoController,
                          label: 'da Empresa',
                          icon: const Icon(Icons.location_on_outlined),
                          onChanged: (novoEndereco) {
                            setState(() {
                              _enderecoController = novoEndereco;
                            });
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

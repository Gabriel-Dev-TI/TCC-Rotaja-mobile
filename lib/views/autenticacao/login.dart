import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:rotaja/controller/usuarioController.dart';
import 'package:rotaja/views/animacoes/animacao_carregandoBtn.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class Login extends StatefulWidget {
  final String cargo;

  const Login({super.key, required this.cargo});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaObscure = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String resposta = await fazLogin(
      email: _emailController,
      senha: _senhaController,
      cargo: widget.cargo,
    );

    if (resposta == "Login realizado com sucesso") {
      Navigator.pushReplacementNamed(context, '/${widget.cargo}');
      mostraSnackBar.show(context, resposta, false);
    } else {
      mostraSnackBar.show(context, resposta, true);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final primaryColor = tema.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * .2,
                    height: MediaQuery.sizeOf(context).height * .2,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: primaryColor, blurRadius: 5),
                      ],
                    ),
                    child: Image.asset(
                      'assets/imagens/${widget.cargo}Login.png',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo(a)!',
                    style: tema.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acesse sua conta para gerenciar\nsuas entregas com facilidade.',
                    style: tema.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'seuemail@exemplo.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
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
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _senhaController,
                    obscureText: _senhaObscure,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _senhaObscure = !_senhaObscure;
                          });
                        },
                        icon: Icon(
                          _senhaObscure
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
                      if (value.length < 8) {
                        return 'A senha deve possuir no mínimo 8 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : fazerLogin,
                      child: isLoading
                          ? AnimacaoCarregandoBtn()
                          : Text(
                              'Entrar',
                              style: tema.textTheme.bodyLarge!.copyWith(
                                color: tema.colorScheme.surface,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/${widget.cargo}Cadastro');
                    },
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    child: const Text('Ainda não tem uma conta? Cadastre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

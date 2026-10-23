import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rotaja/controller/usuarioController.dart';
import 'package:rotaja/model/usuario.dart';
import 'package:rotaja/repository/api.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';
import 'package:rotaja/views/animacoes/animacao_erro.dart';
import 'package:rotaja/views/widgets/snackbar.dart';

class Dados extends StatefulWidget {
  const Dados({super.key});

  @override
  State<Dados> createState() => _DadosState();
}

class _DadosState extends State<Dados> {
  late Future<Map<String, dynamic>?> _dadosFuture;
  bool editando = false;
  bool salvando = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  final maskTel = MaskTextInputFormatter(mask: "(##) #####-####",filter: {"#": RegExp(r'[0-9]')},);


  @override
  void initState() {
    super.initState();
    _dadosFuture = carregaDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }


  void _preencherControllers(Map<String, dynamic> dados) {
    _nomeController.text = dados['nome'] ?? '';
    _emailController.text = dados['email'] ?? '';
    _telefoneController.text = dados['telefone'] ?? '';
  }

  Future<void> salvar () async {
    final user = Usuario(telefone: _telefoneController.text.trim(), nome: _nomeController.text.trim(), email: _emailController.text.trim(), senha: '', cargo: Cargo.administrador);
    setState(() => salvando = true);
    String resposta = await salvarUsuario(user);
    bool erro = resposta != 'Dados atualizados com sucesso!';
    if (!mounted) {return;}
    mostraSnackBar.show(context, resposta, erro);
     setState(() {
        editando = false;
        salvando = false;
      _dadosFuture = carregaDados();
    });
    
  }
  


  void _abrirDialogSenha() {
    final _senhaAtual = TextEditingController();
    final _novaSenha = TextEditingController();
    final _confirmarSenha = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _senhaAtual,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _novaSenha,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmarSenha,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _senhaAtual.dispose();
              _novaSenha.dispose();
              _confirmarSenha.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_novaSenha.text != _confirmarSenha.text) {
                mostraSnackBar.show(context, 'As senhas não conferem', true);
                return;
              }
              if (_novaSenha.text.length < 8) {
                mostraSnackBar.show(context, 'A nova senha deve ter no mínimo 8 caracteres', true);
                return;
              }

              try {
                final client = Api();
                final resposta = await client.put('/atualizar-senha', {
                  'senha_atual': _senhaAtual.text,
                  'nova_senha': _novaSenha.text,
                  'nova_senha_confirmation': _confirmarSenha.text,
                });

                _senhaAtual.dispose();
                _novaSenha.dispose();
                _confirmarSenha.dispose();

                if (resposta.statusCode == 200) {
                  if (mounted) {
                    Navigator.pop(ctx);
                    mostraSnackBar.show(context, 'Senha alterada com sucesso!', false);
                  }
                } else {
                  final body = jsonDecode(resposta.body);
                  if (mounted) {
                    mostraSnackBar.show(context, body['mensagem'] ?? 'Erro ao alterar senha.', true);
                  }
                }
              } catch (e) {
                _senhaAtual.dispose();
                _novaSenha.dispose();
                _confirmarSenha.dispose();
                if (mounted) {
                  mostraSnackBar.show(context, 'Erro: $e', true);
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfo({
    required IconData icone,
    required String titulo,
    required String valor,
    bool isUltimo = false,
    bool editavel = false,
    TextEditingController? controller,
    TextInputType? keyboard,
    bool isTelefone = false,
  }) {
    final cores = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cores.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cores.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: tema.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    if (editavel && editando && controller != null && !isTelefone)
                      TextFormField(
                        controller: controller,
                        keyboardType: keyboard,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      )
                    else if (editavel && editando && controller != null && isTelefone)
                          TextFormField(
                        controller: controller,
                        keyboardType: keyboard,
                        inputFormatters: [maskTel],
                        
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      )
                    else if (editavel && editando && controller == null)
                      TextButton(
                        onPressed: _abrirDialogSenha,
                        child: const Text('Alterar senha'),
                      )
                    else
                      Text(
                        valor.isEmpty ? 'Não informado' : valor,
                        style: tema.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isUltimo)
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (editando)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => setState(() => editando = false),
                icon: Icon(Icons.cancel, color: cores.primary, size: 20),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: salvando
                  ? null
                  : () {
                      if (editando) {
                        salvar();
                      } else {
                        setState(() => editando = true);
                      }
                    },
              icon: salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      editando ? Icons.save : Icons.edit,
                      color: cores.primary,
                      size: 20,
                    ),
            ),
          ),
        ],
        title: const Text('Dados da Conta', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AnimacaoCarregando();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const AnimacaoErro();
          }

          final dados = snapshot.data!;
          final bool isEmpresa = dados['cargo'] == 'empresa';
          final String nome = dados['nome'] ?? 'Usuário';

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_nomeController.text.isEmpty) {
              _preencherControllers(dados);
            }
          });

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: cores.primary.withValues(alpha: 0.15),
                            child: Text(
                              nome[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: cores.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (editando)
                            IntrinsicWidth(
                              child: TextField(
                                controller: _nomeController,
                                textAlign: TextAlign.center,
                                style: tema.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
                              nome,
                              textAlign: TextAlign.center,
                              style: tema.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cores.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isEmpresa ? 'Empresa' : 'Entregador',
                              style: TextStyle(
                                color: cores.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildItemInfo(
                            icone: Icons.email_outlined,
                            titulo: 'E-mail',
                            valor: dados['email'] ?? '',
                            editavel: true,
                            controller: _emailController,
                            keyboard: TextInputType.emailAddress,
                          ),
                          _buildItemInfo(
                            icone: Icons.phone_outlined,
                            titulo: 'Telefone',
                            valor: dados['telefone'] ?? '',
                            editavel: true,
                            controller: _telefoneController,
                            keyboard: TextInputType.phone,
                          ),
                          _buildItemInfo(
                            icone: isEmpresa
                                ? Icons.business_outlined
                                : Icons.badge_outlined,
                            titulo: isEmpresa ? 'CNPJ' : 'CPF',
                            valor: isEmpresa
                                ? (dados['cnpj'] ?? '')
                                : (dados['cpf'] ?? ''),
                          ),
                          if (isEmpresa)
                            _buildItemInfo(
                              icone: Icons.location_on_outlined,
                              titulo: 'Endereço',
                              valor: dados['endereco'] ?? '',
                            ),
                          if (!isEmpresa)
                            _buildItemInfo(
                              icone: Icons.two_wheeler_outlined,
                              titulo: 'Tipo de veículo',
                              valor: dados['tipo_veiculo'] ?? '',
                            ),
                          _buildItemInfo(
                            icone: Icons.lock_outline,
                            titulo: 'Senha',
                            valor: '••••••••',
                            editavel: true,
                          ),
                          _buildItemInfo(
                            icone: Icons.calendar_today_outlined,
                            titulo: 'Data de registro',
                            valor: dados['criado_em'] ?? '',
                            isUltimo: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}   
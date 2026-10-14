import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/cadastros/enderecoCadastro.dart';
import 'package:rotaja/views/animacoes/animacao_carregando.dart';

class ListaEnderecos extends StatefulWidget {
  const ListaEnderecos({super.key});

  @override
  State<ListaEnderecos> createState() => _ListaEnderecosState();
}

class _ListaEnderecosState extends State<ListaEnderecos> {
  late Future<List<Endereco>> _enderecosFuture;

  @override
  void initState() {
    super.initState();
    _enderecosFuture = listarSharedPreferences();
  }

  void _abrirEdicao(Endereco endereco) {
    showDialog<Endereco>(
      context: context,
      builder: (context) => EnderecoCadastro(
        salvarNaApi: true,
        enderecoParaEditar: endereco,
      ),
    ).then((_) {
      setState(() {
        _enderecosFuture = listarSharedPreferences();
      });
    });
  }

  void _confirmarExclusao(Endereco endereco) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Endereço'),
        content: Text(
            'Deseja excluir "${endereco.logradouro}, ${endereco.numero}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await removeEndereco(endereco);
              Navigator.pop(ctx);
              setState(() {
                _enderecosFuture = listarSharedPreferences();
              });
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Endereços',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog<Endereco>(
            context: context,
            builder: (context) => EnderecoCadastro(salvarNaApi: true),
          );
          setState(() {
            _enderecosFuture = listarSharedPreferences();
          });
        },
        backgroundColor: cores.primary,
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        label: const Text(
          'Novo Endereço',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Endereco>>(
        future: _enderecosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AnimacaoCarregando();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cores.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_off_outlined,
                        size: 64,
                        color: cores.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Nenhum endereço cadastrado',
                      style: tema.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre novos locais para facilitar a criação de entregas e rotas.',
                      textAlign: TextAlign.center,
                      style: tema.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final lista = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: lista.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final endereco = lista[index];
              return _buildEnderecoCard(context, tema, cores, endereco);
            },
          );
        },
      ),
    );
  }

  Widget _buildEnderecoCard(
    BuildContext context,
    TextTheme tema,
    ColorScheme cores,
    Endereco endereco,
  ) {
    final bool ehProprio = endereco.tipoEndereco == TipoEndereco.proprio;   

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ehProprio
            ? cores.primary.withOpacity(0.04)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ehProprio
              ? cores.primary.withOpacity(0.4)
              : Colors.grey.withOpacity(0.15),
          width: ehProprio ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ehProprio
                  ? cores.primary.withOpacity(0.15)
                  : cores.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ehProprio ? Icons.business_rounded : Icons.location_on_outlined,
              color: cores.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ehProprio)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cores.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Endereço da Empresa',
                      style: tema.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: cores.primary,
                      ),
                    ),
                  ),
                Text(
                  '${endereco.logradouro}, Nº ${endereco.numero}',
                  style: tema.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (endereco.complemento != null &&
                    endereco.complemento!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Comp: ${endereco.complemento}',
                    style: tema.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${endereco.bairro} • ${endereco.cidade} - ${endereco.estado}',
                  style: tema.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'CEP: ${endereco.cep}',
                        style: tema.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => _abrirEdicao(endereco),
                icon: Icon(Icons.edit, size: 20, color: cores.primary),
                tooltip: 'Editar',
              ),
              if (!ehProprio)
              IconButton(
                onPressed: () => _confirmarExclusao(endereco),
                icon:
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                tooltip: 'Excluir',
              ),
            ],
          ),
        ],
      ),
    );
  }
}   
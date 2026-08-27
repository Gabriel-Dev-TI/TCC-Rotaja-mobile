import 'package:flutter/material.dart';
import 'package:rotaja/controller/enderecoController.dart';
import 'package:rotaja/model/endereco.dart';
import 'package:rotaja/views/cadastros/enderecoCadastro.dart';

class DropDownEndereco extends StatefulWidget {
  final Endereco? enderecoSelecionado;
  final String label;
  final Widget icon;
  final ValueChanged<Endereco?> onChanged;
  final bool salvarNaApi;

  const DropDownEndereco({
    super.key,
    required this.enderecoSelecionado,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.salvarNaApi = true,
  });

  @override
  State<DropDownEndereco> createState() => _DropDownEnderecoState();
}

class _DropDownEnderecoState extends State<DropDownEndereco> {
  List<Endereco> _listaEnderecos = [];

  @override
  void initState() {
    super.initState();
    carregarEnderecos();
  }

  Future<void> carregarEnderecos() async {
    final enderecos = await listarSharedPreferences();
    if (mounted) {
      setState(() => _listaEnderecos = enderecos);
    }
  }

 Future<void> abrirCadastroEndereco() async {
  final Endereco? enderecoNovo = await showDialog<Endereco>(
    context: context,
    builder: (context) => EnderecoCadastro(
      salvarNaApi: widget.salvarNaApi,
    ),
  );

  if (enderecoNovo != null) {
    if (!widget.salvarNaApi) {
      // No cadastro inicial: adiciona direto na lista em memória sem recarregar do SharedPreferences
      setState(() {
        _listaEnderecos.add(enderecoNovo);
      });
    } else {
      // No fluxo normal: recarrega a lista do SharedPreferences
      await carregarEnderecos();
    }

    if (mounted) {
      widget.onChanged(enderecoNovo);
    }
  }
}

  List<DropdownMenuItem<dynamic>> listaDropdownItems() {
    final List<DropdownMenuItem<dynamic>> lista = [
      DropdownMenuItem<dynamic>(
        value: 'CADASTRAR',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Cadastrar endereço',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    ];

    for (var endereco in _listaEnderecos) {
      lista.add(
        DropdownMenuItem<dynamic>(
          value: endereco,
          child: Text(
            '${endereco.logradouro}, ${endereco.numero}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return lista;
  }

  @override
Widget build(BuildContext context) {
  Endereco? selectedValue;

  if (widget.enderecoSelecionado != null && _listaEnderecos.isNotEmpty) {
    try {
      selectedValue = _listaEnderecos.firstWhere(
        (e) => e == widget.enderecoSelecionado,
      );
    } catch (_) {
      selectedValue = null;
    }
  }

  // Gera uma chave única usando id, cep ou logradouro + número
  final String keyString = selectedValue != null
      ? '${selectedValue.id}_${selectedValue.cep}_${selectedValue.logradouro}_${selectedValue.numero}'
      : 'sem_selecao';

  return DropdownButtonFormField<dynamic>(
    key: ValueKey(keyString),
    initialValue: selectedValue,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: 'Endereço ${widget.label}',
      prefixIcon: widget.icon,
    ),
    hint: Text(
      'Cadastre um endereço',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    items: listaDropdownItems(),
    onChanged: (dynamic novoValor) {
      if (novoValor == 'CADASTRAR') {
        abrirCadastroEndereco();
      } else if (novoValor is Endereco) {
        widget.onChanged(novoValor);
      }
    },
    validator: (value) {
      if (widget.enderecoSelecionado == null) {
        return 'Selecione ou cadastre um endereço';
      }
      return null;
    },
  );
}
}
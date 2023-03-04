import 'package:app_anotacoes/helper/anotacao_helper.dart';
import 'package:app_anotacoes/model/anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _decricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = <Anotacao>[];

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoAtualizarSalvar = '';
    if (anotacao == null) {
      _titleController.text = "";
      _decricaoController.text = "";
      textoAtualizarSalvar = "Salvar";
    } else {
      _titleController.text = anotacao.titulo.toString();
      _decricaoController.text = anotacao.descricao.toString();
      textoAtualizarSalvar = "Atualizar";
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$textoAtualizarSalvar Anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                      label: Text("Título"), hintText: "Didite o titulo"),
                ),
                TextField(
                  controller: _decricaoController,
                  decoration: const InputDecoration(
                      label: Text("Descrição"), hintText: "Digite a descrição"),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              ElevatedButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(textoAtualizarSalvar)),
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao> listaTemporaria = <Anotacao>[];
    for (var nota in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(nota);
      listaTemporaria.add(anotacao);
    }
    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = <Anotacao>[];
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _titleController.text;
    String decricao = _decricaoController.text;
    if (anotacaoSelecionada == null) {
      Anotacao anotacao = Anotacao(titulo, decricao, DateTime.now().toString());
      await _db.salvarAnotacao(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = decricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      await _db.atualizarAnotacao(anotacaoSelecionada);
    }
    _titleController.clear();
    _decricaoController.clear();
    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting('pt_br');
    // var formatador = DateFormat("dd/MM/y H:m:s");
    var formatador = DateFormat.yMd('pt_BR');
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Anotações!"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, index) {
                    final anotacao = _anotacoes[index];
                    return Card(
                      child: ListTile(
                        title: Text(anotacao.titulo.toString()),
                        subtitle: Text(
                            "${_formatarData(anotacao.data.toString())} - ${anotacao.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  _exibirTelaCadastro(anotacao: anotacao);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.edit, color: Colors.green),
                                )),
                            GestureDetector(
                                onTap: () {
                                  dynamic id = anotacao.id;
                                  _removerAnotacao(id);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: Icon(Icons.remove_circle,
                                      color: Colors.red),
                                ))
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreen,
          focusColor: Colors.white,
          child: const Icon(Icons.add),
          onPressed: () {
            _exibirTelaCadastro();
          }),
    );
  }
}

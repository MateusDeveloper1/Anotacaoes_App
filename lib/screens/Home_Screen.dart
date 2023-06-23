import 'package:anotacoes/helper/AnotacaoHelper.dart';
import 'package:anotacoes/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = <Anotacao>[];
  bool displayNotes = false;

  // mostrar anotação
  void _displayRecord({Anotacao? anotacao}) {
    String textSaveUpdate = "";

    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      textSaveUpdate = "Salvar";
    } else {
      _tituloController.text = anotacao.title;
      _descricaoController.text = anotacao.description;
      textSaveUpdate = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$textSaveUpdate Anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Título",
                  hintText: "Digite título",
                ),
              ),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  hintText: "Digite a descrição",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text(textSaveUpdate),
              onPressed: () {
                if (_descricaoController.text.isEmpty) {
                  Navigator.pop(context);
                } else {
                  _saveUpdateAnnotation(anotacaoSelecionada: anotacao);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  //Alerta o usuario se realmente deseja apagar a anotação
  void _alert(int anotacao) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Deseja apagar?",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text(
                "Sim",
                style: TextStyle(color: Color.fromARGB(255, 240, 99, 99)),
              ),
              onPressed: () {
                _removeAnnotation(anotacao);
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text("Não", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // recuperar anotações
  void _recoverNotes() async {
    List anotacoesRecuperadas = await _db.retrieveNotes();
    List<Anotacao> listaTemporaria = <Anotacao>[];

    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
  }

  //salvar anotação atualizada
  void _saveUpdateAnnotation({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      Anotacao anotacao = Anotacao(
        title: titulo,
        description: descricao,
        date: DateTime.now().toString(),
      ); //Salvar
      await _db.saveAnnotation(anotacao);
    } else {
      //Atualizar
      anotacaoSelecionada.title = titulo;
      anotacaoSelecionada.description = descricao;
      anotacaoSelecionada.date = DateTime.now().toString();
      await _db.updateAnnotation(anotacaoSelecionada);
    }

    _tituloController.clear();
    _descricaoController.clear();
    _recoverNotes();
  }

  String _formateDate(String data) {
    initializeDateFormatting("pt_BR");

    var formatador = DateFormat("d/MM/y");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

  //remover anotação
  void _removeAnnotation(int id) async {
    await _db.removeAnnotation(id);

    _recoverNotes();
  }

  @override
  void initState() {
    super.initState();
    _recoverNotes();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Minhas Anotações",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen,
        elevation: 6,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _anotacoes.length,
              itemBuilder: (context, index) {
                final anotacao = _anotacoes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Card(
                    child: ListTile(
                      title: Text(anotacao.title),
                      subtitle: Text(
                          "${_formateDate(anotacao.date)} - ${anotacao.description}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _displayRecord(
                                  anotacao:
                                      anotacao); //exibir cadastro de anotações
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _alert(anotacao.id!);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          _displayRecord(); //exibir cadastro
        },
      ),
    );
  }
}

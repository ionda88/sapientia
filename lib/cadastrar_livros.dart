import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sapientia/entities/livro.dart';

class CadastarLivros extends StatefulWidget {
  @override
  _CadastarLivrosState createState() => _CadastarLivrosState();
}

class _CadastarLivrosState extends State<CadastarLivros> {
  CollectionReference livros = FirebaseFirestore.instance.collection('livros');

  TextEditingController tituloController = TextEditingController();
  TextEditingController autorController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  TextEditingController generoController = TextEditingController();
  TextEditingController anoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // drawer: Drawer(child: ListView(children: [
      //
      // ],)),
      appBar: AppBar(title: Text("Cadastro de Livros"), centerTitle: true, actions: [          IconButton(
          onPressed: () {
            salvarNovoLivro();
          },
          icon: Icon(Icons.save))],),
      body: Column(children: <Widget>[
        input("Titulo", tituloController),
        input("Autor", autorController),
        input("Ano", anoController),
        input("Gênero", generoController),
        input("Descrição", descricaoController),
        input("URL capa", urlController),
        //Center(child: Container(color: Colors.green, child: TextButton(child: Text("Salvar", style: TextStyle(color: Colors.white),), onPressed: (){salvarNovoLivro();},)))
      ]),
    );
  }

  Future<void> refresh() async {
    setState(() {
      // tamanhoLista = 150;
      // listaProdutos = blocHome.buscarTodosProdutosFormacaoPrecoDB(
      //     filtroProdutoController.text,
      //     cdEstado,
      //     tamanhoLista,
      //     cdCampoFiltro,
      //     tipoFiltro, pedidoSelecionado);
      // if (_scrollController.hasClients) {
      //   _scrollController.animateTo(0,
      //       duration: const Duration(milliseconds: 500),
      //       curve: Curves.fastOutSlowIn);
      // }
    });
    return;
  }

  Widget input(String titulo, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onSubmitted: (value) {
          controller.text = value;
          refresh();
        },
        controller: controller,
        decoration: InputDecoration(
            labelText: titulo,
            //prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
                icon: Icon(Icons.close,
                    color: controller.text.isNotEmpty
                        ? Colors.grey
                        : Colors.transparent),
                onPressed: () {
                  controller.clear();
                  refresh();
                }),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))),
      ),
    );
  }

  void salvarNovoLivro() {
    Livro livro = Livro("", autorController.text, urlController.text, tituloController.text, anoController.text, generoController.text, descricaoController.text, 0, 0,"");

    livros.add(livro.toMap()).then((value) {print("Sucesso!"); Navigator.of(context).pop();})
        .catchError((error) => print("Failed to add livro: $error"));
  }
}


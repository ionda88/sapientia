import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sapientia/cadastrar_livros.dart';
import 'package:sapientia/entities/livro.dart';
import 'package:sapientia/entities/user.dart';

class MeusLivros extends StatefulWidget {
  final String userid;

  const MeusLivros({Key? key, required this.userid})
      : super(key: key);
  @override
  _MeusLivrosState createState() => _MeusLivrosState();
}

class _MeusLivrosState extends State<MeusLivros> {
  bool filtrar = false;
  Livro? livroSelecionado;
  User? userSelecionado;

  TextEditingController filtroLivrosController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _livrosStream =
    FirebaseFirestore.instance.collection('livros').where("userid", isEqualTo: widget.userid).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Livros"),
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        if (filtrar)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: (value) {
                filtroLivrosController.text = value;
                refresh();
              },
              controller: filtroLivrosController,
              decoration: InputDecoration(
                  labelText: "Filtrar",
                  //hintText: "Filtrar",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.close,
                          color: filtroLivrosController.text.isNotEmpty
                              ? Colors.grey
                              : Colors.transparent),
                      onPressed: () {
                        filtroLivrosController.clear();
                        refresh();
                      }),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
        StreamBuilder<QuerySnapshot>(
          stream: _livrosStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return Expanded(
              child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  Livro livro = Livro.fromMapObject(document.id, data);
                  String descricaoCrop = (livro.descricao.length > 316
                      ? livro.descricao.substring(0, 316) + "..."
                      : livro.descricao);
                  if (filtroLivrosController.text.isNotEmpty &&
                      !livro.titulo.contains(filtroLivrosController.text)) {
                    return Container();
                  }
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.all(0),
                      child: Row(children: [
                        Expanded(
                          flex: 8,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(livro.url),
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 14,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(livro.titulo,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Autor: ' + livro.autor,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Ano: ' + livro.ano,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Gênero: ' + livro.genero,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        'Descrição: ' + descricaoCrop,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            livroSelecionado = livro;
                                            solicitarEmprestimo();
                                          },
                                          child: Text(
                                              "Devolver", style: TextStyle(color: Colors.red),)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
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

  solicitarEmprestimo() {

    TextEditingController raController = TextEditingController();
    TextEditingController senhaController = TextEditingController();
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Salvar"),
      onPressed: () async {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        QuerySnapshot snapshot =
            await users.where("ra", isEqualTo: raController.text).get();
        if (snapshot.size > 0) {
          Map<String, dynamic> data =
              snapshot.docs[0].data()! as Map<String, dynamic>;
          if (senhaController.text == data["senha"]) {
            User user = User.fromMapObject(snapshot.docs[0].id, data);
            userSelecionado = user;
            Navigator.of(context).pop();
            selecionarDataEmprestimo();
          } else {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            const snackBar = SnackBar(
              content: Text('Senha incorreta!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          const snackBar = SnackBar(
            content: Text('RA inválido!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmar Login:"),
      content: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (value) {
                  raController.text = value;
                  setState(() {});
                },
                controller: raController,
                decoration: InputDecoration(
                    labelText: "RA:",
                    //prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.close,
                            color: raController.text.isNotEmpty
                                ? Colors.grey
                                : Colors.transparent),
                        onPressed: () {
                          raController.clear();
                          setState(() {});
                        }),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              )),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (value) {
                  senhaController.text = value;
                  setState(() {});
                },
                controller: senhaController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    labelText: "Senha:",
                    //prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.close,
                            color: senhaController.text.isNotEmpty
                                ? Colors.grey
                                : Colors.transparent),
                        onPressed: () {
                          senhaController.clear();
                          setState(() {});
                        }),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              )),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  selecionarDataEmprestimo() {
    TextEditingController dateInput = TextEditingController(text: UtilData.obterDataDDMMAAAA(DateTime.now()));
    TextEditingController dateFimInput = TextEditingController(text: UtilData.obterDataDDMMAAAA(DateTime.now().add(Duration(days: 3))));

    int dtInicio = DateTime.now().millisecondsSinceEpoch;
    int dtFinal = (DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch);

    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Emprestar"),
      onPressed: () async {
        livroSelecionado!.dtInicio = dtInicio;
        livroSelecionado!.dtFim = dtFinal;
        livroSelecionado!.userid = userSelecionado!.id;
        DocumentReference doc = FirebaseFirestore.instance.collection("livros").doc(livroSelecionado!.id);
        doc.set(livroSelecionado!.toMap(),SetOptions(merge: true));

        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmar Data de Empréstimo:"),
      content: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: dateInput,
                //editing controller of this TextField
                decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Início:" //label text of field
                ),
                readOnly: true,
                //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2100));

                  if (pickedDate != null) {
                    print(
                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                    String formattedDate =
                    UtilData.obterDataDDMMAAAA(pickedDate);
                    print(
                        formattedDate);
                    dtInicio = pickedDate.millisecondsSinceEpoch;//formatted date output using intl package =>  2021-03-16
                    setState(() {
                      dateInput.text =
                          formattedDate; //set output date to TextField value.
                    });
                  } else {}
                },
              )),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: dateFimInput,
                //editing controller of this TextField
                decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today), //icon of text field
                    labelText: "Fim:" //label text of field
                ),
                readOnly: true,
                //set it true, so that user will not able to edit text
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2100));

                  if (pickedDate != null) {
                    print(
                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                    String formattedDate =
                    UtilData.obterDataDDMMAAAA(pickedDate);
                    dtFinal = pickedDate.millisecondsSinceEpoch;
                    setState(() {
                      dateInput.text =
                          formattedDate; //set output date to TextField value.
                    });
                  } else {}
                },
              )),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: ListView.builder(
//           itemCount: 15,
//           itemBuilder: (context, index) {
//
//           }),
//     );
//   }
// }

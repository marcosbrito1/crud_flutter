import 'package:flutter/material.dart';
import 'ClienteDb.dart';

class Cliente extends StatelessWidget {
  const Cliente({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Cliente',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const clientePage());
  }
}

class clientePage extends StatefulWidget {
  const clientePage({Key? key}) : super(key: key);

  @override
  _clientePageState createState() => _clientePageState();
}

class _clientePageState extends State<clientePage> {
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _journalsfilter = [];
  bool _isLoading = true;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _comidaController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey<FormState>();

  void _refreshJournals() async {
    final data = await ClienteDb.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
      _journalsfilter = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nomeController.text = existingJournal['nome'];
      _telefoneController.text = existingJournal['telefone'];
      _enderecoController.text = existingJournal['endereco'];
      _comidaController.text = existingJournal['comidafav'];
    } else {
      _nomeController.text = '';
      _telefoneController.text = '';
      _enderecoController.text = '';
      _comidaController.text = '';
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom * 1,
              ),
              child: Form(
                key: _key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: "Nome: ",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Informe o Nome";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: "Telefone: ",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Informe o Telefone";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: "Endereço: ",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Informe o Endereço";
                          }
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _comidaController,
                        decoration: const InputDecoration(
                          labelText: "Comida Favorita: ",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Informe a sua comida favorita";
                          }
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Container(
                          height: 50.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.deepPurple)),
                            onPressed: () async {
                              if (id == null && _key.currentState!.validate()) {
                                await _addItem();
                                _nomeController.text = '';
                                _enderecoController.text = '';
                                _comidaController.text = '';
                                _telefoneController.text = '';
                                Navigator.of(context).pop();
                              }

                              if (id != null && _key.currentState!.validate()) {
                                await _updateItem(id);
                                _nomeController.text = '';
                                _enderecoController.text = '';
                                _comidaController.text = '';
                                _telefoneController.text = '';
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(id == null ? 'Cadastrar' : 'Atualizar'),
                          )),
                    )
                  ],
                ),
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await ClienteDb.createItem(_nomeController.text, _telefoneController.text,
        _enderecoController.text, _comidaController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await ClienteDb.updateItem(
        id,
        _nomeController.text,
        _telefoneController.text,
        _enderecoController.text,
        _comidaController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 140,
              child: Column(
                children: [
                  Container(
                    height: 60.0,
                    width: 160.0,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        child: Text(
                          "Confirmar Exclusão",
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () async {
                          await ClienteDb.deleteItem(id);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Excluido com sucesso!'),
                          ));
                          _refreshJournals();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Text(""),
                  Container(
                    height: 60.0,
                    width: 160.0,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        child: Text(
                          "Cancelar Operação",
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Clientes'),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: "Pesquisar cliente..."),
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _journalsfilter = _journals
                      .where((item) => item['nome']
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journalsfilter.length,
              itemBuilder: (context, index) => Card(
                color: Colors.deepPurple,
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(
                      _journalsfilter[index]['nome'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Comida Favorita: " +
                          _journalsfilter[index]['comidafav'].toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _showForm(_journalsfilter[index]['id']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () =>
                                _deleteItem(_journalsfilter[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showForm(null),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved = Map();
  int _lastRemovedIndex = 0;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "";
    }
  }

  void _addToDo() {
    Map<String, dynamic> newToDO = new Map();
    newToDO["title"] = _toDoController.text;
    _toDoController.text = "";
    newToDO["ok"] = false;
    setState(() {
      _toDoList.add(newToDO);
    });
    _saveData();
  }

  Widget _buildItem(context, index) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment(-0.9, 0),
            child: Icon(Icons.delete, color: Colors.white),
          )),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (check) {
          setState(() {
            _toDoList[index]["ok"] = check;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemovedIndex = index;
          _lastRemoved = Map.from(_toDoList[index]);
          _toDoList.removeAt(index);
          _saveData();
        });

        final snack = SnackBar(
          content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _toDoList.insert(_lastRemovedIndex, _lastRemoved);
                _saveData();
              });
            },
          ),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 17, top: 1, right: 7, bottom: 1),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                  controller: _toDoController,
                )),
                ElevatedButton(
                  onPressed: _addToDo,
                  style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                  child: Text("Add"),
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            itemCount: _toDoList.length,
            itemBuilder: _buildItem,
          ))
        ],
      ),
    );
  }
}

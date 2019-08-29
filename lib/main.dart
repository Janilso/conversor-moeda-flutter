import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=01a59273";

void main() async {
  print(await getData());
  runApp(MaterialApp(
    title: "Conversor de Moeda",
    home: Home(),
    theme: ThemeData(
      hintColor: Color(0xFF67D1FA),
      canvasColor: Color(0xFF13262E),
      primaryColor: Color(0xFF67D1FA),
    ),
  ));
}

Future<Map> getData() async {
  http.Response respostaServidor = await http.get(request);
  return json.decode(respostaServidor.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controladorReal = TextEditingController();
  final controladorDolar = TextEditingController();
  final controladorEuro = TextEditingController();

  double dolar;
  double euro;

  void _alterarReal(String valor) {
    double real = double.parse(valor);
    controladorDolar.text = (real / dolar).toStringAsFixed(2);
    controladorEuro.text = (real / euro).toStringAsFixed(2);
  }

  void _alterarDolar(String valor) {
    double dolar = double.parse(valor);
    controladorReal.text = (dolar * this.dolar).toStringAsFixed(2);
    controladorEuro.text = (dolar * this.dolar / this.euro).toStringAsFixed(2);
  }

  void _alterarEuro(String valor) {
    double euro = double.parse(valor);
    controladorReal.text = (euro * this.euro).toStringAsFixed(2);
    controladorDolar.text = (euro * this.euro / this.dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      // backgroundColor: Color(0xFF0A1317),
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          "\$ Conversor \$",
          style: TextStyle(color: Color(0xFF67D1FA)),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF13262E),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(color: Color(0xFF13262E))),
              );
              break;
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Ocorreu algum erro ao carregar dados.",
                      style: TextStyle(color: Color(0xFF67D1FA))),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(
                            Icons.monetization_on,
                            size: 120.0,
                            color: Color(0xFF67D1FA),
                          ),
                          Divider(),
                          Divider(),
                          campos(
                              "Reais", "R\$ ", controladorReal, _alterarReal),
                          Divider(),
                          campos("Dolar", "US\$ ", controladorDolar,
                              _alterarDolar),
                          Divider(),
                          campos("Euro", "€ ", controladorEuro, _alterarEuro),
                        ],
                      ),
                    ));
              }
          }
        },
      ),
    );
  }
}

Widget campos(String moeda, String simbolo, TextEditingController controlador,
    Function alterar) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(),
    onChanged: alterar,
    controller: controlador,
    decoration: InputDecoration(
      labelText: moeda,
      labelStyle: TextStyle(
        color: Color(0xFF67D1FA),
      ),
      border: OutlineInputBorder(),
      prefixText: simbolo,
      // prefixStyle: TextStyle(color: Color(0xFF67D1FA)),
    ),
    style: TextStyle(
      color: Color(0xFF67D1FA),
      fontSize: 17,
    ),
  );
}

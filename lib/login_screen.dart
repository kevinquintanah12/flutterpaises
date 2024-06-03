import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';

final storage = FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginUser() async {
    final HttpLink httpLink = HttpLink(
      'http://34.125.185.36:9003/graphql/',
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation TokenAuth(\$username: String!, \$password: String!) {
          tokenAuth(username: \$username, password: \$password) {
            token
          }
        }
      '''),
      variables: <String, dynamic>{
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      final token = result.data?['tokenAuth']?['token'];
      if (token != null) {
        await storage.write(key: 'token', value: token);
        _checkToken(); // Verificar el token guardado en el almacenamiento local
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('No se pudo obtener el token. Intente de nuevo.');
      }
    } else {
      _showErrorDialog('Usuario o contraseña incorrectos.');
    }
  }

  void _checkToken() async {
    final String? token = await storage.read(key: 'token');
    if (token != null) {
      print('Token JWT: $token');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginUser,
                child: Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

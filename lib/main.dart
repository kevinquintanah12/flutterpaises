import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'create_country_screen.dart';
import 'country_list_widget.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:universal_io/io.dart'; // Para detectar la plataforma

final storage = FlutterSecureStorage();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token;

  if (Platform.isAndroid || Platform.isIOS) {
    // Usar flutter_secure_storage para dispositivos móviles
    token = await storage.read(key: 'token') ?? ''; // Usar '' si el token es null
  } else {
    // Usar shared_preferences para Web y otras plataformas
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? ''; // Usar '' si el token es null
  }

  print('Token JWT: $token');

  final HttpLink httpLink = HttpLink(
    'http://34.125.185.36:9003/graphql/',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Token JWT $token',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    ),
  );

  runApp(MyApp(client: client, link: link));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final Link link;

  MyApp({required this.client, required this.link});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Countries',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(client: client),
        routes: {
          '/home': (context) => MyHomePage(client: client),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/createCountry': (context) => CreateCountryScreen(),
          '/countryList': (context) => CountryListWidget(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueNotifier<GraphQLClient> client;

  MyHomePage({required this.client});

  @override
  _MyHomePageState createState() => _MyHomePageState(client: client);
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<GraphQLClient> client;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    CountryListWidget(),
    LoginScreen(),
    SignupScreen(),
    CreateCountryScreen(),
  ];

  _MyHomePageState({required this.client});

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COUNTRY NEWS'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20), // Añadir espacio aquí para bajar los botones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _onItemTapped(0),
                child: Text('Paises Publicados'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(1),
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(2),
                child: Text('Registrate'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(3),
                child: Text('Publica Pais'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    await storage.delete(key: 'token');
                  } else {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                  }
                  Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la pantalla de Login después del logout
                },
                child: Text('Logout'),
              ),
            ],
          ),
          SizedBox(height: 20), // Añadir espacio aquí si se requiere más separación
          Expanded(
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              borderRadius: 0,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFffffff),
                  Color(0xFFf2f4f7),
                ],
              ),
              border: 0,
              blur: 20,
              alignment: Alignment.center,
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFffffff),
                  Color(0xFFf2f4f7),
                ],
              ),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}
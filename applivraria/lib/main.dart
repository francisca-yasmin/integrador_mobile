import 'package:applivraria/bem_vindo.dart';
import 'package:applivraria/cadastro.dart';
import 'package:applivraria/home.dart';
import 'package:applivraria/login.dart';
import 'package:applivraria/perfil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => BemVindo(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/cadastro': (context) => PageCadastro(),
        '/perfil': (context) => PerfilPage(docId: "",),
 
      },
    );
  }
}

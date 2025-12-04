import 'package:applivraria/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Função de login com Firestore
Future<dynamic> loginUser({
  required String email,
  required String senha,
}) async {
  try {
    final query = await FirebaseFirestore.instance
        .collection("usuario")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return "Usuário não encontrado.";
    }

    final doc = query.docs.first;
    final userData = doc.data();

    if (userData["senha"] != senha) {
      return "Senha incorreta.";
    }

    // Retorna os dados do usuário
    return {
      "docId": doc.id,
      "name": userData["name"],
      "email": userData["email"],
    };

  } catch (e) {
    return "Erro ao fazer login: $e";
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool loading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha e-mail e senha!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => loading = true);

    // LOGIN VIA FIRESTORE
    String? error = await loginUser(email: email, senha: password);

    if (error == null) {
      // Login OK → vai para home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),

      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFDF2),
        elevation: 0,
      ),

      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.email, size: 20),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock, size: 20),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf47cb9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Entrar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: 220,
                  child: Image.asset(
                    "./assets/images/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

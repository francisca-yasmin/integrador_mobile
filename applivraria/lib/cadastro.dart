import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


// ======================================================
// FUNÇÃO PARA CRIAR USUÁRIO
// ======================================================
Future<String?> createUserAccount({
  required String name,
  required String email,
  required String senha,
}) async {
  try {
    // Verifica se o email já existe no banco
    final existing = await FirebaseFirestore.instance
        .collection("usuario")
        .where("email", isEqualTo: email)
        .get();

    if (existing.docs.isNotEmpty) {
      return "E-mail já cadastrado.";
    }

    // Salvar usuário no Firestore
    await FirebaseFirestore.instance.collection("usuario").add({
      "name": name,
      "email": email,
      "senha": senha, // pode criptografar depois
      "createdAt": DateTime.now().toIso8601String(),
    });

    return null; // sucesso
  } catch (e) {
    return "Erro ao salvar usuário: $e";
  }
}


// ======================================================
// FUNÇÃO PARA LOGIN
// ======================================================
Future<Map<String, dynamic>?> loginUser({
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
      return {"error": "Usuário não encontrado."};
    }

    final doc = query.docs.first;

    if (doc["senha"] != senha) {
      return {"error": "Senha incorreta."};
    }

    return {
      "userId": doc.id,
      "name": doc["name"],
      "email": doc["email"],
    };
  } catch (e) {
    return {"error": "Erro ao fazer login: $e"};
  }
}


// ======================================================
// PAGINA DE CADASTRO
// ======================================================
class PageCadastro extends StatefulWidget {
  const PageCadastro({super.key});

  @override
  State<PageCadastro> createState() => _PageCadastroState();
}

class _PageCadastroState extends State<PageCadastro> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),

      appBar: AppBar(
        title: const Text("Criar Conta"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFCFDF2),
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
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Nome completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => loading = true);

                        String? error = await createUserAccount(
                          name: name.text.trim(),
                          email: email.text.trim(),
                          senha: password.text.trim(),
                        );

                        setState(() => loading = false);

                        if (error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Conta criada com sucesso!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf47cb9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Criar Conta',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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

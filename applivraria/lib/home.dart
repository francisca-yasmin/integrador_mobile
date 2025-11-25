import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    fetchBooks("romance"); // carregamento inicial
  }
  List books = [];
  bool loading = false;

  TextEditingController searchController = TextEditingController();

  Future<void> fetchBooks(String query) async {
  setState(() {
    loading = true;
  });

  try {
    final url = Uri.parse(
      "https://www.googleapis.com/books/v1/volumes?q=$query",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        books = (data["items"] ?? [])
            .where((item) => item["volumeInfo"] != null)
            .toList();
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
      print("Erro da API: ${response.statusCode}");
    }
  } catch (e) {
    setState(() {
      loading = false;
    });
    print("Erro ao buscar livros: $e");
  }
}

String getBookPrice(dynamic book) {
  final saleInfo = book["saleInfo"];

  if (saleInfo == null) return "Indisponível";

  if (saleInfo["saleability"] == "FOR_SALE") {
    final amount = saleInfo["retailPrice"]?["amount"] ?? 0.0;
    return "R\$ ${amount.toStringAsFixed(2)}";
  }

  return "Indisponível";
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Amor & Livros"),
      centerTitle: true,
      backgroundColor: const Color(0xFFFCFDF2),
    ),

    //footerbar pra navegation
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0,          
      onTap: (index) {},         
      selectedItemColor: const Color(0xFFf47cb9),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Carrinho"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    ),

    body: Column(
      children: [
        // campo de busca
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Buscar livros...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) fetchBooks(value);
            },
          ),
        ),

        // 📚 Lista de livros estilizada
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : (books.isEmpty)
                  ? const Center(child: Text("Nenhum livro encontrado"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index]["volumeInfo"];

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // 📘 Capa
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: book["imageLinks"]?["thumbnail"] != null
                                    ? Image.network(
                                        book["imageLinks"]["thumbnail"],
                                        width: 90,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 90,
                                        height: 130,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.book, size: 40),
                                      ),
                              ),

                              const SizedBox(width: 12),

                              // 📖 Informações do livro
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book["title"] ?? "Sem título",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      book["authors"]?.join(", ") ?? "Autor desconhecido",
                                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                                    ),

                                    const SizedBox(height: 10),

                                    // 💲 Preço (se existir)
                                    Text(
                                      getBookPrice(books[index]),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFf47cb9),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // 🛒 Botão Comprar
                                    SizedBox(
                                      width: 130,
                                      height: 38,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFf47cb9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          final link = books[index]["saleInfo"]["buyLink"];
                                          if (link != null) {
                                            launchUrl(Uri.parse(link));
                                          }
                                        },
                                        child: const Text(
                                          "Comprar",
                                          style: TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      },
                    ),
        ),
      ],
    ),
  );
  }
}
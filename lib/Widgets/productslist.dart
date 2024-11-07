import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsList extends StatefulWidget {
  const ProductsList({super.key});

  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost:3000/products'));
    final data = jsonDecode(response.body);
    products = List<Product>.from(data.map((item) => Product.fromJson(item)));
    setState(() {});
  }

  Future<void> deleteProduct(int id) async {
    await http.delete(Uri.parse('http://localhost:3000/products/$id'));
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductFormScreen()),
              );
              fetchProducts();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('R\$${product.price}', style: const TextStyle(color: Colors.green)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductFormScreen(product: product),
                          ),
                        );
                        fetchProducts();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final DateTime date;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.date,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      description: json['description'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'date': date.toIso8601String(),
      'quantity': quantity,
    };
  }
}

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${product.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Preço: R\$${product.price}', style: const TextStyle(fontSize: 18, color: Colors.green)),
                const SizedBox(height: 8),
                Text('Descrição: ${product.description}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Quantidade: ${product.quantity}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Data de criação: ${product.date.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text = widget.product!.price.toString();
      descriptionController.text = widget.product!.description;
      quantityController.text = widget.product!.quantity.toString();
    }
  }

  Future<void> saveProduct() async {
    final product = Product(
      id: widget.product?.id ?? 0,
      name: nameController.text,
      price: double.parse(priceController.text),
      description: descriptionController.text,
      date: widget.product?.date ?? DateTime.now(),
      quantity: int.parse(quantityController.text),
    );

    if (widget.product == null) {
      await http.post(
        Uri.parse('http://localhost:3000/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
    } else {
      await http.put(
        Uri.parse('http://localhost:3000/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar/Editar Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o preço';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a descrição';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a quantidade';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveProduct();
                      }
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
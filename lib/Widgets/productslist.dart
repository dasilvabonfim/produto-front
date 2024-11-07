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
    fetchProducts(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductFormScreen()),
              );
              fetchProducts(); // Refresh the list after adding a product
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('\$${product.price}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await deleteProduct(product.id);
              },
            ),
          );
        },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${product.name}', style: const TextStyle(fontSize: 18)),
            Text('Prece: \$${product.price}', style: const TextStyle(fontSize: 18)),
            Text('Descrição: ${product.description}', style: const TextStyle(fontSize: 18)),
            Text('Quantdade: ${product.quantity}', style: const TextStyle(fontSize: 18)),
            Text('Data de criação: ${product.date.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({Key? key}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Future<void> saveProduct() async {
    final product = Product(
      id: 0, // Assuming 0 or null ID for a new product
      name: nameController.text,
      price: double.parse(priceController.text),
      description: descriptionController.text,
      date: DateTime.now(),
      quantity: int.parse(quantityController.text),
    );

    await http.post(
      Uri.parse('http://localhost:3000/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Preco'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProduct,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

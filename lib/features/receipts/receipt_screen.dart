import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tag/services/auth_service.dart';
import 'package:flutter_tag/shared/var.dart';
import 'package:http/http.dart' as http;

class ReceiptScreen extends StatefulWidget {
  final String orderId;

  const ReceiptScreen({super.key, required this.orderId});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  Map<String, dynamic>? receiptData;
  bool isLoading = true;
  bool isError = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchReceiptData();
  }

  Future<void> fetchReceiptData() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse("$apiUrl/customer/orders/${widget.orderId}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          receiptData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch receipt');
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Failed to load receipt."))
              : buildReceipt(),
    );
  }

  Widget buildReceipt() {
    final items = receiptData!['items'] as List<dynamic>;
    final details = receiptData!['details']['customer'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            "Receipt #${receiptData!['number']}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text("Status: ${receiptData!['status']}"),
          Text("Date: ${DateTime.parse(receiptData!['created_at']).toLocal()}"),
          const Divider(),
          Text(
            "Customer Details",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text("Name: ${details['firstname']} ${details['lastname']}"),
          Text("Email: ${details['email']}"),
          Text("Phone: ${details['phone']}"),
          const Divider(),
          Text(
            "Items",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...items.map((item) => buildItem(item)),
          const Divider(),
          Text(
            "Total: \$${(receiptData!['total'] / 100).toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildItem(Map<String, dynamic> item) {
    final imageUrl = item['images'][0]['name']; // Adjust according to backend
    return Card(
      child: ListTile(
        leading: imageUrl != null
            ? Image.network('$apiUrl/images/$imageUrl')
            : const Icon(Icons.image),
        title: Text(item['name']),
        subtitle: Text("Quantity: ${item['quantity']}"),
        trailing: Text("\$${(item['price'] / 100).toStringAsFixed(2)}"),
      ),
    );
  }
}

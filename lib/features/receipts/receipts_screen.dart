import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tag/features/receipts/receipt_screen.dart';
import 'package:flutter_tag/services/auth_service.dart';
import 'package:flutter_tag/shared/var.dart';
import 'package:http/http.dart' as http;

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  bool isError = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse("$apiUrl/customer/orders"),
        headers: {
          'Authorization': 'Bearer $token'
        }, // Replace with your endpoint
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          orders = responseData['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch orders');
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
        title: const Text("All Receipts"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text("Failed to load orders."))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return buildOrderCard(order);
                  },
                ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    return Card(
      child: ListTile(
        leading: Icon(
          order['status'] == 'completed'
              ? Icons.check_circle
              : Icons.pending_actions,
          color: order['status'] == 'completed' ? Colors.green : Colors.orange,
        ),
        title: Text("Order #${order['number']}"),
        subtitle: Text(
          "Total: \$${(order['total'] / 100).toStringAsFixed(2)}\nStatus: ${order['status']}",
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to ReceiptScreen with orderId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReceiptScreen(orderId: order['id'].toString()),
            ),
          );
        },
      ),
    );
  }
}

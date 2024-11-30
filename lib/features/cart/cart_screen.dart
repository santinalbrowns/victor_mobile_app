import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tag/features/cart/model.dart';
import 'package:flutter_tag/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.items});

  final List<Item> items;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AuthService _authService = AuthService();

  final int storeId = 1;

  late String paymentUrl;

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        //onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://flutter.dev'));

  Future<WebViewController?> createPaymentSession() async {
    final token = await _authService.getToken();

    final cart = Cart(storeId: 1, items: widget.items);

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.3:5000/customer/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(cart.toJson()),
      );

      final data = jsonDecode(response.body);

      return WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            //onHttpError: (HttpResponseError error) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(data['channel']));
    } catch (e) {
      print("Error creating payment session: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.items.length > 0
        ? Scaffold(
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    title: Text("Cart"),
                  ),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        onLongPress: () {
                          /* Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (BuildContext context) =>
                            const QuantityScreen(),
                      ),
                    ); */

                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child:
                                    StatefulBuilder(builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                        child: Text(
                                          "Item Name",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_rounded,
                                              size: 18,
                                            ),
                                            SizedBox(width: 6),
                                            Text("Mpamba Merchant Code: 0000"),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 10,
                                        ),
                                        child: Form(
                                          //key: _formKey,
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  border:
                                                      const OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                    color: Colors.green,
                                                  )),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 20,
                                                  ),
                                                  hintText:
                                                      'Enter reference number',
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                  ),
                                                ),
                                                // The validator receives the text that the user has entered.
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please provide a payment reference number';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {},
                                              ),
                                              const SizedBox(height: 20),
                                              MaterialButton(
                                                minWidth: double.infinity,
                                                height: 46,
                                                onPressed: () {
                                                  // Validate returns true if the form is valid, or false otherwise.
                                                },
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 10),
                                                color: Colors.black,
                                                disabledColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'Add',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                }),
                              );
                            },
                          );
                        },
                        leading: Image.network(
                          "http://172.20.10.3:5000/thumbnails/${widget.items[index].product.image}",
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          widget.items[index].product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "K${widget.items[index].price * widget.items[index].quantity}"),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            //TODO add product price
                            Text("Unit price: K25,000"),
                            Text("Quantity: ${widget.items[index].quantity}"),
                          ],
                        ),
                      );
                    },
                    itemCount: widget.items.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                            color: Color.fromARGB(255, 218, 218, 218)),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: widget.items.length > 0
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 46,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => Scaffold(
                              appBar: AppBar(
                                title: const Text("Checkout"),
                              ),
                              body: FutureBuilder<WebViewController?>(
                                future: createPaymentSession(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return WebViewWidget(
                                        controller: snapshot.data!);
                                  }

                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                          ));
                        },
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        color: Colors.black,
                        disabledColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.items.length} items',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          )
        : Scaffold(
            body: Center(
              child: Text("Your cart is empty"),
            ),
          );
  }
}

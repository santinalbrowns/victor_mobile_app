import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tag/features/cart/cart_screen.dart';
import 'package:flutter_tag/features/cart/model.dart';
import 'package:flutter_tag/features/stores/store_screen.dart';
import 'package:flutter_tag/services/auth_service.dart';
import 'package:flutter_tag/shared/models/product.dart';
import 'package:ndef/utilities.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NfcTag? _tag;

  int currentPageIndex = 0;
  final AuthService _authService = AuthService();

  final int storeId = 1;
  List<Item> cartItems = [];

  late String paymentUrl;

  void addToCart(String sku, double price, Product product) {
    final cart = Cart(storeId: storeId, items: cartItems);

    setState(() {
      // Check if the item already exists in the cart
      Item? existingItem = cartItems.firstWhere((item) => item.sku == sku,
          orElse: () => Item(sku: '', quantity: 0, price: 0, product: product));
      if (existingItem.sku.isNotEmpty) {
        // Increment quantity if item already exists
        existingItem.quantity++;
      } else {
        // Add new item to the cart
        cartItems
            .add(Item(sku: sku, quantity: 1, price: price, product: product));
      }
    });
  }

  void removeFromCart(String sku) {
    setState(() {
      cartItems.removeWhere((item) => item.sku == sku);
    });
  }

  void sendOrder() {
    // Create a Cart instance
    final cart = Cart(storeId: storeId, items: cartItems);

    // Convert cart to JSON
    final orderJson = cart.toJson();
  }

  Future<void> createPaymentSession() async {
    final token = await _authService.getToken();

    final cart = Cart(storeId: storeId, items: cartItems);

    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.3:5000/customer/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: cart.toJson(),
      );

      final data = jsonDecode(response.body);
      setState(() {
        paymentUrl = data['channel'];
      });
    } catch (e) {
      print("Error creating payment session: $e");
    }
  }

  Future<Product?> fetchProductDetails(String sku) async {
    final token = await _authService.getToken();

    final url = Uri.parse(
        'http://172.20.10.3:5000/customer/products/$sku'); // Replace with your API endpoint

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Add the token here
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: FutureBuilder<bool>(
        future: NfcManager.instance.isAvailable(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            NfcManager.instance.startSession(
              onDiscovered: (NfcTag tag) async {
                final demo = Uint8List.fromList(
                    tag.data["ndefformatable"]["identifier"]);

                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true, // Allows full height customization
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: StatefulBuilder(builder: (context, state) {
                        return FractionallySizedBox(
                          heightFactor:
                              0.9, // Adjust height as a percentage of the screen
                          child: FutureBuilder<Product?>(
                            future: fetchProductDetails(demo.toHexString()),
                            builder: ((context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData) {
                                return const Center(
                                  child: Text('No product found.'),
                                );
                              } else {
                                return Scaffold(
                                  body: CustomScrollView(
                                    slivers: [
                                      SliverAppBar(
                                        stretch: true,
                                        pinned: true,
                                        snap: false,
                                        floating: false,
                                        backgroundColor: Colors.transparent,
                                        expandedHeight: 400.0,
                                        flexibleSpace: FlexibleSpaceBar(
                                          stretchModes: const <StretchMode>[
                                            StretchMode.zoomBackground,
                                            StretchMode.fadeTitle,
                                          ],
                                          background: Stack(
                                            fit: StackFit.expand,
                                            children: <Widget>[
                                              SafeArea(
                                                child: Image.network(
                                                  "http://172.20.10.3:5000/images/${snapshot.data!.image}",
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 10),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.all(20),
                                        sliver: SliverToBoxAdapter(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    snapshot.data!.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              133,
                                                              231,
                                                              231,
                                                              231),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {},
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        2,
                                                                    vertical:
                                                                        3),
                                                            child: const Icon(
                                                              Icons.remove,
                                                              size: 20,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 15,
                                                          ),
                                                          child: Text("1"),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {},
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        2,
                                                                    vertical:
                                                                        3),
                                                            child: const Icon(
                                                              Icons.add,
                                                              size: 20,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                snapshot.data!.description,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  bottomNavigationBar: SafeArea(
                                    child: SizedBox(
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);

                                            addToCart(snapshot.data!.sku, 10000,
                                                snapshot.data!);
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40),
                                                  ),
                                                  child: const Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 26,
                                                                vertical: 14),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Add to Basket",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Icon(
                                                              Icons
                                                                  .shopping_cart,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        );
                      }),
                    );
                  },
                );
              },
            );

            return <Widget>[
              /// Home page
              CartScreen(
                items: cartItems,
              ),

              /// Notifications page
              StoreFinder(),

              /// Messages page
              ListView.builder(
                reverse: true,
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Hello',
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    );
                  }
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Hi!',
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  );
                },
              ),
            ][currentPageIndex];
          }
          return const Center(
            child: Text("Phone not supported"),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_bag),
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.store)),
            label: 'Finder',
          ),
          NavigationDestination(
            icon: Badge(
              child: Icon(Icons.person),
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

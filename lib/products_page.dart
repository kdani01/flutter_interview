import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_interview/bottom_menu.dart';
import 'package:flutter_interview/main.dart';
import 'package:http/http.dart' as http;

class ProductsPage extends StatelessWidget {
  final Function(int) onProductCardTap;

  const ProductsPage({super.key, required this.onProductCardTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black12,
            height: 1.0,
          ),
        ),
      ),
      body: ProductGridView(onProductCardTap: onProductCardTap),
      bottomNavigationBar: BottomNavigationMenu(
          onProductButtonPressed: onProductButtonPressed()),
    );
  }
}

class ProductGridView extends StatefulWidget {
  final Function(int) onProductCardTap;

  const ProductGridView({super.key, required this.onProductCardTap});

  @override
  ProductGridViewState createState() => ProductGridViewState();
}

class ProductGridViewState extends State<ProductGridView> {
  late ScrollController scrollController;
  static List<dynamic> productList = [];
  int numberOfDisplayedProducts = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(scrollListener);
    fetchNextProducts();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (!isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      fetchNextProducts();
    }
  }

  Future<void> fetchNextProducts() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(
          'https://dummyjson.com/products?limit=8&skip=$numberOfDisplayedProducts&'));

      if (response.statusCode == 200) {
        final List<dynamic> productsLoading =
            json.decode(response.body)['products'];
        setState(() {
          productList.addAll(productsLoading);
          numberOfDisplayedProducts += 8;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
      ),
      itemCount: productList.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < productList.length) {
          final product = productList[index];
          return GestureDetector(
            onTap: () => widget.onProductCardTap(index),
            child: GridTile(
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                semanticContainer: true,
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: 0.22 * MediaQuery.of(context).size.height,
                          child: Image.network(
                            product['thumbnail'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Error loading image');
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product['title']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${product['price']}',
                            style: const TextStyle(
                                color: Color.fromRGBO(40, 80, 180, 1)),
                          ),
                          Text(
                            '${'${product['discountPercentage']}'.split(".").first}% • ${product['stock']} left',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

Function() onProductButtonPressed() {
  return () => MyAppState.displayedProductIndex.value = null;
}

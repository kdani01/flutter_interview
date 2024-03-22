import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_interview/bottom_menu.dart';
import 'package:flutter_interview/product_description_page.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  static ValueNotifier<int?> displayedProductIndex = ValueNotifier<int?>(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const ProductsPage(),
            ValueListenableBuilder<int?>(
              valueListenable: displayedProductIndex,
              builder: (context, index, _) {
                return index != null
                    ? Positioned.fill(child: ProductDescriptionPage(index))
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// PRODUCTS PAGE

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

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
      body: const ProductGridView(),
      bottomNavigationBar: BottomNavigationMenu(
          onProductButtonPressed: onProductButtonPressed()),
    );
  }
}

class ProductGridView extends StatefulWidget {
  const ProductGridView({super.key});

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
            onTap: () {
              setState(() {
                // this is the reason, why I will not put this widget in another .dart file.
                // i considered using Riverpod, but it seemed to be a bit overkill for this project.
                // however, if the 2 other buttons and their functionalities should be implemented on the bottomNavigationPanel,
                // I would definitely use Riverpod

                MyAppState.displayedProductIndex.value = index;
              });
            },
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
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: 0.5,
                          child: SizedBox(
                            height: 360,
                            child: Image.network(
                              product['thumbnail'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                            '${'${product['discountPercentage']}'.split(".").first}% · ${product['stock']} left',
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

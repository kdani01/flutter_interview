import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static ValueNotifier<int?> displayedProductIndex = ValueNotifier<int?>(null);

  @override
  Widget build(BuildContext context) {
    print("rebuilt");
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            ProductsPage(),
            ValueListenableBuilder<int?>(
              valueListenable: displayedProductIndex,
              builder: (context, index, _) {
                return index != null
                    ? Positioned.fill(
                        child: ProductDescriptionPage(index!),
                      )
                    : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CustomMenuButton(
              icon: Icons.home,
              label: "Feed",
              onPressed: () => {},
            ),
            CustomMenuButton(
              icon: Icons.shopping_bag,
              label: "Products",
              onPressed: () => {
                _MyAppState.displayedProductIndex.value = null,
              },
            ),
            CustomMenuButton(
              icon: Icons.person,
              label: "Profile",
              onPressed: () => {},
            ),
          ],
        ),
      ),
    );
  }
}

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
      bottomNavigationBar: const BottomMenu(),
    );
  }
}

class CustomMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onPressed;

  const CustomMenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width / 5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Icon(
                icon,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 60,
              height: 20,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
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
                _MyAppState.displayedProductIndex.value = index;
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

// ignore: must_be_immutable
class ProductDescriptionPage extends StatefulWidget {
  ProductDescriptionPage(this.index, {super.key});
  int index;

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  dynamic product;
  bool isLoading = false;
  List<Widget> images = [];

  @override
  Widget build(BuildContext context) {
    product = ProductGridViewState.productList[widget.index];

    for (String imageLink in product['images']) {
      images.add(
        Padding(
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageLink,
              width: 200,
              height: 200,
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
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: ListView(
          shrinkWrap: true,
          children: [
            Image.network(
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    product["description"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "Images",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: images,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomMenu(),
      ),
    );
  }
}

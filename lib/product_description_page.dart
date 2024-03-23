import 'package:flutter/material.dart';
import 'package:flutter_interview/bottom_menu.dart';
import 'package:flutter_interview/products_page.dart';

class ProductDescriptionPage extends StatelessWidget {
  const ProductDescriptionPage(this.product, {super.key});
  final dynamic product;

  @override
  Widget build(BuildContext context) {
    List<Widget> images = [];
    // fill images list
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

    // the page itself
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
                const Padding(
                  padding: EdgeInsets.all(8),
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
        bottomNavigationBar: BottomNavigationMenu(
            onProductButtonPressed: onProductButtonPressed()),
      ),
    );
  }
}

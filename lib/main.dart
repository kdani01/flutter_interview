import 'package:flutter/material.dart';
import 'package:flutter_interview/product_description_page.dart';
import 'package:flutter_interview/products_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            ProductsPage(
                onProductCardTap: (index) =>
                    displayedProductIndex.value = index),
            ValueListenableBuilder<int?>(
              // later idea: change displayedProductIndex to displayedProduct -> makes code clearer, index is not really needed here
              valueListenable: displayedProductIndex,
              builder: (context, index, _) {
                return index != null
                    ? Positioned.fill(
                        child: ProductDescriptionPage(
                            ProductGridViewState.productList[index]))
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

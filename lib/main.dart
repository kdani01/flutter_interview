import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
        body: GridView.count(
          crossAxisCount: 2,
          children: [],
        ),
        bottomNavigationBar: const BottomMenu(),
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CustomMenuButton(icon: Icons.home, label: "Feed"),
            CustomMenuButton(icon: Icons.shopping_bag, label: "Products"),
            CustomMenuButton(icon: Icons.person, label: "Profile"),
          ],
        ),
      ),
    );
  }
}

class CustomMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const CustomMenuButton({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {},
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

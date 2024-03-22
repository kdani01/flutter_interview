import 'package:flutter/material.dart';

// There is a widget named "BottomNavigationBar" in Flutter.
// I got to know this right after I wrote my custom widget for it, so I didn't change it now, only if needed in a real project.
class BottomNavigationMenu extends StatelessWidget {
  final Function() onProductButtonPressed;
  const BottomNavigationMenu({super.key, required this.onProductButtonPressed});

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
            BottomMenuButton(
              icon: Icons.home,
              label: "Feed",
              onPressed: () => {},
            ),
            BottomMenuButton(
              icon: Icons.shopping_bag,
              label: "Products",
              onPressed: onProductButtonPressed,
            ),
            BottomMenuButton(
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

class BottomMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onPressed;

  const BottomMenuButton({
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

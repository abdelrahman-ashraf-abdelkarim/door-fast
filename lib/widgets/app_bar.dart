import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.isOnline,
    required this.userName,
  });

  final bool isOnline;
  final String userName;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              userName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            isOnline
                ? Row(
                    children: [
                      Text(
                        "متصل الآن",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.circle, color: Colors.green, size: 14),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        "غير متصل",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.circle, color: Colors.red, size: 14),
                    ],
                  ),
          ],
        ),
        const Spacer(),
        Text(
          "DoorFast",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto",
            fontSize: 24,
            color: Color(0xffec6623),
          ),
        ),
      ],
    );
  }
}

import 'package:captain_app/models/auth_model.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppBarWidget extends StatelessWidget {
  const AppBarWidget({
    super.key,
    required this.isOnline,
    required this.userName,
    required this.role,
  });

  final bool isOnline;
  final String userName;
  final DeliveryType role;
  @override
  Widget build(BuildContext context) {
    final isReserve = role == DeliveryType.reserve;
    return Row(
      children: [
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.circle, color: Colors.green, size: 10),
              const SizedBox(width: 6),

              Text(
                isReserve ? "إحتياطي" : "اساسي",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Image.asset(
          "assets/images/DF_logo_for_dash.png",
          height: 70,
          width: 140,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

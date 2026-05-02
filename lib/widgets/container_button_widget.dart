import 'package:flutter/material.dart';

class ContainerButtonWidget extends StatelessWidget {
  const ContainerButtonWidget({
    super.key,
    required this.colors,
    this.text, this.widget, this.isText = true,
  });
  final List<Color> colors;
  final String? text;
  final Widget? widget;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: isText
            ? Text(
                text ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : widget,
      ),
    );
  }
}

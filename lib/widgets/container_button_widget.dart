import 'package:flutter/material.dart';

class ContainerButtonWidget extends StatelessWidget {
  const ContainerButtonWidget({
    super.key,
    required this.color,
    this.text,
    this.widget,
    this.isText = true,
    this.textColor = Colors.white,
    this.isWhite = false,
  });
  final Color color;
  final bool? isWhite;
  final String? text;
  final Color? textColor;
  final Widget? widget;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
        color: isWhite == true ? Colors.white : color,
      ),
      child: Center(
        child: isText
            ? Text(
                text ?? '',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : widget,
      ),
    );
  }
}

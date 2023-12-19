import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';

class MonthCard extends StatelessWidget {
  final DateTime date;
  final Color backgroundColor;

  final Color? textColor;

  const MonthCard(
      {super.key,
      required this.date,
      required this.backgroundColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var itemHeight = (86 / baseHeightDesign) * height;
    var itemWidth = (60 / baseWidthDesign) * width;
    return Container(
      height: itemHeight,
      width: itemWidth,
      padding: EdgeInsets.only(
        top: (25 / baseHeightDesign) * height,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(children: [
        Text(
          'Mois',
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          date.month.toString().padLeft(2, '0'),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ]),
    );
  }
}

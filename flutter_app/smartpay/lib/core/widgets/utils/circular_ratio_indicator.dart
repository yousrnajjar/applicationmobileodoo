import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';

class CircularRatioIndicator extends StatelessWidget {
  final String suffix;
  final String title;
  final double ratio;
  final double maxRatio;
  final Color colorText;
  final Color colorBackground;
  final Color progressColor;

  const CircularRatioIndicator({
    super.key,
    required this.suffix,
    required this.title,
    required this.ratio,
    required this.maxRatio,
    required this.colorText,
    required this.progressColor,
    required this.colorBackground,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width / 2,
      height: (111 / baseHeightDesign) * height,
      padding: EdgeInsets.only(
          top: (6 / baseHeightDesign) * height,
          bottom: (10 / baseHeightDesign) * height),
      decoration: BoxDecoration(
        color: colorBackground,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildRatioIndicator(context),
          SizedBox(
            width: (92 / baseWidthDesign) * width,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioIndicator(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var indicatorWidth = (55 / baseWidthDesign) * width + 10;
    int value = (ratio * maxRatio).toInt();
    return Stack(
      children: [
        Container(
          width: indicatorWidth,
          height: indicatorWidth,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: progressColor,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: indicatorWidth,
            height: indicatorWidth,
            child: CircularProgressIndicator(
              value: ratio,
              backgroundColor: progressColor,
              valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: colorText,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent, //colorBackground,
            ),
            child: Center(
              child: Text(
                suffix,
                style: TextStyle(
                  color: colorText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

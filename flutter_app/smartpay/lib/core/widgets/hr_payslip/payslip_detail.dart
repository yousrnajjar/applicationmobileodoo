import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';

import '../utils/month_card.dart';

class PayslipDetail extends StatelessWidget {
  final Map<OdooField, dynamic> pay;
  double itemHeight = 0;
  double itemWidth = 0;
  Color backgroundColor = Colors.white;

  PayslipDetail({super.key, required this.pay});

  Map<String, Color> stateColor = {
    'draft': kGrey,
    'done': kGreen,
    'verify': kPink,
    'cancel': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> lastPay = {};
    pay.forEach((k, v) {
      lastPay[k.name] = v;
    });

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    itemHeight = (86 / baseHeightDesign) * height;
    itemWidth = (60 / baseWidthDesign) * width;
    backgroundColor = stateColor[lastPay['state']] ?? kGreen;

    // Si aucune fiche de pay n'est disponible
    if (pay.isEmpty) {
      return Container(
        height: itemHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 191, 248, 187),
        ),
        child: const Center(
          child: Text('Pas de fiche de paie disponible pour le moment'),
        ),
      );
    }

    var dateFormatter = DateFormat('yyyy-MM-dd');
    var date = dateFormatter.parse(lastPay['date_from']);

    var footer = buildFooter(context);
    return Row(
      children: [
        buildMonth(date, backgroundColor),
        buildBody(context, date, lastPay),
        if (footer != null)
        // footer, --> Add vertical line
          Container(
            width: 1,
            height: itemHeight,
            color: Colors.black,
          ),
        if (footer != null) footer,
      ],
    );
  }

  Widget buildBody(
      BuildContext context, DateTime date, Map<String, dynamic> lastPay) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var stateDisplay = pay.keys
        .firstWhere((k) => k.name == 'state')
        .selectionOptions
        .firstWhere((v) => v['value'] == lastPay['state'])['display_name'];
    return Expanded(
      child: Container(
        height: itemHeight,
        width: double.infinity,
        padding: EdgeInsets.only(
          top: (12 / baseHeightDesign) * height,
          left: (10 / baseWidthDesign) * width,
          right: (10 / baseWidthDesign) * width,
        ),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 230, 229, 225),
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dernière fiche de paie',
                  style: TextStyle(
                    color: kGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  DateFormat('yyyy/MM/dd').format(date),
                  style: const TextStyle(
                    color: kGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'État : ',
                      style: TextStyle(
                        color: stateColor[lastPay['state']],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '$stateDisplay',
                      style: TextStyle(
                        color: stateColor[lastPay['state']],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '+ ',
                      style: TextStyle(
                        color: stateColor[lastPay['state']],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: kGreen,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.all(5),
                          shape: const BeveledRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0))),
                          textStyle: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                        child: const Text('Consulter la fiche de paie'),
                        onPressed: () {})
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMonth(DateTime date, backgroundColor) {
    return MonthCard(date: date, backgroundColor: backgroundColor);
  }

  Widget? buildFooter(BuildContext context) {
    return null;
  }
}

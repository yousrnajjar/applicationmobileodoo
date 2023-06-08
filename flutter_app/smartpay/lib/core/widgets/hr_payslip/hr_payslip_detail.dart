import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';

class PayslipDetail extends StatelessWidget {

  final Map<OdooField, dynamic> pay;

  const PayslipDetail({super.key, required this.pay});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var itemHeight = (86 / baseHeightDesign) * height;
    var itemWidth = (60 / baseWidthDesign) * width;
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

    Map<String, Color> stateColor = {
      'draft': kGrey,
      'done': kGreen,
      'verify': kPink,
      'cancel': Colors.red,
    };
    Map<String, dynamic> lastPay = {};
    pay.forEach((k, v) {
      lastPay[k.name] = v;
    });
    var stateDisplay = pay.keys
        .firstWhere((k) => k.name == 'state')
        .selectionOptions
        .firstWhere((v) => v['value'] == lastPay['state'])['display_name'];
    var dateFormatter = DateFormat('yyyy-MM-dd');
    var date = dateFormatter.parse(lastPay['date_from']);

    return Row(
      children: [
        Container(
          height: itemHeight,
          width: itemWidth,
          padding: EdgeInsets.only(
            top: (25 / baseHeightDesign) * height,
          ),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 191, 248, 187),
          ),
          child: Column(children: [
            const Text(
              'Mois',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              date.month.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
        Expanded(
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
        ),
      ],
    );

  }

}

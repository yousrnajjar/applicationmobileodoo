import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';

import 'contract_detail.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class ContractListDetail extends ContractDetail {
  ContractListDetail({super.key, required super.contract, super.onPrintPdf});

  @override
  Widget? buildFooter(BuildContext context, double itemHeight) {
    return Container(
        height: itemHeight,
        width: (93 / baseWidthDesign) * MediaQuery.of(context).size.width,
        // Ligne de séparation noire
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 230, 229, 225),
          border: Border(
            left: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kGrey,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.all(5),
                shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0))),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Consulter le contrat'),
              onPressed: () {}),
        ));
  }
}

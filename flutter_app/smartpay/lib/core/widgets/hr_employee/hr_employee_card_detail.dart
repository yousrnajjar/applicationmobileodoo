import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';
import 'package:smartpay/ir/model.dart';
import 'package:smartpay/ir/models/user.dart';
import 'package:transparent_image/transparent_image.dart';

class EmployeeCardDetail extends StatelessWidget {
  final Map<OdooField, dynamic> employee;
  final User? user;
  final showDetails;
  const EmployeeCardDetail({
    super.key, 
    required this.employee, 
    this.user,
    this.showDetails,
  });

  @override
  Widget build(BuildContext context) {
    var showInfo = (showDetails == null) ? true : showDetails;
    print('EmployeeCardDetail with showInfo: $showInfo');
    Map<String, dynamic> employeeKeyAsString = {};
    employee.forEach((key, value) {
      employeeKeyAsString[key.name] = value;
    });
    if (user != null){
      employeeKeyAsString['vat'] =
        user!.info['vat'] == false ? '--/--' : user!.info['vat'];
    } else {
      employeeKeyAsString['vat'] ='--/--';
    }

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var smallCircleDiameter = (65 / baseHeightDesign) * height;
    var bigCircleDiameter = (125 / baseHeightDesign) * height;
    var containerWidth = (300 / baseHeightDesign) * width;
    return Positioned(
      // Center the container
      top: (35 / baseHeightDesign) * height,
      left: 0,
      right: 0,
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: (19 / baseHeightDesign) * width),
        width: containerWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showInfo)
                // Vat in a circle and a background color white
                Stack(
                  children: [
                    Container(
                      width: smallCircleDiameter,
                      height: 10 + smallCircleDiameter + 10,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          employeeKeyAsString['vat'].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        width: smallCircleDiameter,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'Matricule',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!showInfo)
                  Spacer(),
                // blank space
                //Container(
                  //width: smallCircleDiameter,
                  //height: 10 + smallCircleDiameter + 10,
                  //margin: const EdgeInsets.only(top: 10, bottom: 10),
                  //decoration: const BoxDecoration(
                    //color: Colors.transparent,
                    //shape: BoxShape.circle,
                  //),
                //),
                // Image of employee centered
                Container(
                  padding: const EdgeInsets.all(5),
                  width: bigCircleDiameter,
                  height: bigCircleDiameter,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: FadeInImage(
                      // Montre une placeholder quand l'image n'est pas disponible
                      placeholder: MemoryImage(
                        // Convertit des bytes en images
                        kTransparentImage, // Cree une image transparente en bytes
                      ),
                      image: Image.memory(
                              base64Decode(employeeKeyAsString['image_128']))
                          .image,
                      fit: BoxFit.contain
                      //height: 60,
                      //width: 60,
                    ),
                  ),
                ),
                if (showInfo)
                // Number of work month
                Stack(
                  children: [
                    Container(
                      width: smallCircleDiameter,
                      height: 10 + smallCircleDiameter + 10,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          DateTime.now().month.toString().padLeft(2, '0'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: kGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: -10,
                      child: Container(
                        width: smallCircleDiameter + 29,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'Mois en cours',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!showInfo)
                  Spacer(),
                // blank space
                //Container(
                  //width: smallCircleDiameter,
                  //height: 10 + smallCircleDiameter + 10,
                  //margin: const EdgeInsets.only(top: 10, bottom: 10),
                  //decoration: const BoxDecoration(
                    //color: Colors.transparent,
                    //shape: BoxShape.circle,
                  //),
                //),

              ],

            ),
            Center(
              child: Text(
                employeeKeyAsString['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                employeeKeyAsString['job_id'] == false
                    ? "----/----"
                    : employeeKeyAsString['job_id'][1].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Map<OdooField, dynamic> employee;

  final User? user;
  final showDetails;
  const EmployeeCard(
    {
    required this.employee,
    this.user,
    super.key,
    this.showDetails,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var cardHeight = (200 / 650) * height;
    return SizedBox(
      height: cardHeight,
      width: width,
      child: Stack(
        children: [
          // Image de background rempli tout le card
          _buildBackgroundImage(cardHeight),
          // Container avec une couleur de fond et une opacité de 0.5 qui recouvre l'image
          _buildBackgroundContainer(cardHeight),
          if (showDetails)
          // Bare horizontale
          Positioned(
            top: (96 / 650) * height,
            left: (30 / 650) * width,
            right: (30 / 650) * width,
            child: Container(
              height: 5,
              color: Colors.white,
            ),
          ),
          // Informations de l'employé
          EmployeeCardDetail(
            employee: employee,
            user: user ?? null,
            showDetails: showDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage(double cardHeight) {
    var image = "assets/images/employee_background.png";
    return Image.asset(
      image,
      fit: BoxFit.cover,
      height: cardHeight,
    );
  }

  Widget _buildBackgroundContainer(double cardHeight) {
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: kGreen.withOpacity(0.85),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/models.dart';
import 'package:smartpay/core/data/themes.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:smartpay/api/attendance.dart';
import 'package:smartpay/api/auth/session.dart';
import 'package:smartpay/providers/session_providers.dart';
import 'package:smartpay/providers/user_attendance_info.dart';

class CheckInOut extends ConsumerStatefulWidget {
  const CheckInOut({super.key});

  @override
  ConsumerState<CheckInOut> createState() => _CheckInOutState();
}

class _CheckInOutState extends ConsumerState<CheckInOut> {
  void _updateAttendance() async {
    Employee employee = ref.watch(currentEmployeeAttendanceProvider);
    Session session = ref.watch(sessionProvider);
    AttendanceAPI api = AttendanceAPI(session);
    employee = await api.updateAttendance(employee.id);
    ref.read(currentEmployeeAttendanceProvider.notifier).setEmployee(employee);
  }

  @override
  Widget build(BuildContext context) {
    Session session = ref.watch(sessionProvider);
    Employee employee = ref.watch(currentEmployeeAttendanceProvider);
    bool employeeIn = employee.attendanceState == 'checked_in';
    double boxWith = 350;
    ThemeData theme = Theme.of(context);
    var smallText = smallText100(theme);
    var titleLarge = titleLargeBold(theme);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 80,
                    width: boxWith,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      gradient: LinearGradient(
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight,
                          colors: [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withOpacity(0.5)
                          ]),
                    ),
                  ),
                  Center(
                    child: Container(
                      color: theme.colorScheme.background.withAlpha(220),
                      width: boxWith,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            employee.name,
                            style: titleLarge.copyWith(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            employeeIn
                                ? "Vous souhaitez partir?"
                                : "Bienvenue!",
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (employeeIn)
                            Text("Heure de travail aujourd'hui", style: smallText),
                          Text("${employee.hoursToday}", style: smallText.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: employeeIn ? Colors.amber : Colors.white,
                            ),
                            child: IconButton(
                              icon: (employeeIn)
                                  ? const Icon(Icons.logout,
                                      color: Colors.black, size: 50)
                                  : const Icon(Icons.login,
                                      color: Colors.black, size: 50),
                              onPressed: _updateAttendance,
                            ),
                          ),
                          Text(employeeIn ? '' : "Cliquez pour entrer"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(top: 40),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircleAvatar(
                    backgroundImage: FadeInImage(
                      // Montre une placeholder quand l'image n'est pas disponible
                      placeholder: MemoryImage(
                        // Convertit des bytes en images
                        kTransparentImage, // Cree une image transparente en bytes
                      ),
                      image: (employee.image_128 != null)
                          ? Image.memory(base64Decode(employee.image_128)).image
                          : NetworkImage(
                              // Recupere une image par sont url
                              "${session.url}/web/image?model=hr.employee.public&amp;field=image_128&amp;id=${employee.id}",
                            ),
                      fit: BoxFit.contain,
                      height: 60,
                      //width: 60,
                    ).image,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

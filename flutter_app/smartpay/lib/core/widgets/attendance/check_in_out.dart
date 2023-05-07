import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    EmployeeAttendanceInfo attendanceInfo = ref.watch(userAttendanceProvider);
    Session session = ref.watch(sessionProvider);
    AttendanceAPI api = AttendanceAPI(session);
    attendanceInfo = await api.updateAttendance(attendanceInfo.id);
    ref.read(userAttendanceProvider.notifier).setAttendance(attendanceInfo);
  }

  @override
  Widget build(BuildContext context) {
    EmployeeAttendanceInfo attendanceInfo = ref.watch(userAttendanceProvider);
    bool employeeIn = attendanceInfo.attendanceState == 'checked_in';
    double boxWith = 350;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
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
                      color: Theme.of(context).colorScheme.secondary,
                      gradient: LinearGradient(
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ]),
                    ),
                  ),
                  Center(
                    child: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(220),
                      width: boxWith,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            attendanceInfo.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            employeeIn
                                ? "Vous souhaitez partir?"
                                : "Bienvenue!",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          if (employeeIn)
                            Text(
                              "Heure de travail aujourd'hui: ${attendanceInfo.hoursToday}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .color!
                                          .withAlpha(100)),
                            ),
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
                  image: DecorationImage(
                      image: AssetImage('assets/images/admin.jpeg'),
                      fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

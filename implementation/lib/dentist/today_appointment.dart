import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayAppointmentPage extends StatelessWidget {
  const TodayAppointmentPage({Key? key});

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in dentist's ID
    final currentUser = FirebaseAuth.instance.currentUser;
    final String dentistId = currentUser?.uid ?? '';

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Today Appointments', // Title text here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 400, // Set a fixed height for the calendar
                child: StreamBuilder<QuerySnapshot>(
                  // StreamBuilder to listen for changes in Firestore collection
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('did', isEqualTo: dentistId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No appointments available'));
                    }
                    return FutureBuilder<List<Appointment>>(
                      future:
                          _fetchAppointments(snapshot.data!.docs, dentistId),
                      builder: (context, appointmentSnapshot) {
                        if (appointmentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (appointmentSnapshot.hasError) {
                          return Center(
                              child:
                                  Text('Error: ${appointmentSnapshot.error}'));
                        }
                        return SfCalendar(
                          view: CalendarView.timelineDay,
                          timeSlotViewSettings: TimeSlotViewSettings(
                            startHour: 9, // Adjust the starting hour
                            endHour: 18, // Adjust the ending hour
                            timeIntervalWidth:
                                100, // Adjust the width of each time slot
                          ),
                          dataSource:
                              AppointmentDataSource(appointmentSnapshot.data!),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Appointment>> _fetchAppointments(
      List<DocumentSnapshot> documents, String dentistId) async {
    if (documents.isEmpty) {
      return [];
    }

    final List<Appointment> appointments = [];

    for (final doc in documents) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('date') && data['date'] != null) {
        final DateTime date = data['date'].toDate();
        final int hour = data['hour'];
        final DateTime startTime =
            DateTime(date.year, date.month, date.day, hour);
        DateTime endTime;
        if (data['end'] != null) {
          endTime = DateTime(date.year, date.month, date.day, data['end']);
        } else {
          endTime = startTime
              .add(Duration(minutes: 30)); // Default duration if end is null
        }
        final String patientId = data['uid'];
        final String patientName = await getPatientName(patientId);
        QuerySnapshot dentistDoc = await FirebaseFirestore.instance
            .collection('dentist')
            .where('uid', isEqualTo: dentistId)
            .get();
        String dentistColor =
            (dentistDoc.docs[0].data() as Map<String, dynamic>)['color'];

        String hexColor = decimalToHex(int.parse(dentistColor));
        appointments.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: 'Appointment with $patientName',
          color: Color(int.parse(hexColor)),
        ));
      } else {
        print('Invalid date format');
      }
    }
    return appointments;
  }

  Future<String> getPatientName(String patientId) async {
    String patientName = 'Unknown Patient';
    final patientDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(patientId)
        .get();
    if (patientDoc.exists) {
      final fullName = patientDoc.data()?['FullName'] ?? 'Unknown Patient';
      final List<String> names = fullName.split(' ');
      if (names.length >= 2) {
        patientName = '${names[0]} ${names[1]}';
      } else {
        patientName = fullName;
      }
    }
    return patientName;
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

String decimalToHex(int decimalColor) {
  return '0x${decimalColor.toRadixString(16).toUpperCase()}';
}

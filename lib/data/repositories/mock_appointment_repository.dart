import '../models/appointment.dart';

class MockAppointmentRepository {
  List<Appointment> seed() => [
    Appointment(
      id: 'a1',
      customerId: 'c1',
      clientName: 'Aýjemal Annagulyýewa',
      serviceName: 'Kantovka',
      startsAt: DateTime(2026, 8, 13, 9),
      price: 60,
    ),
    Appointment(
      id: 'a2',
      customerId: 'c2',
      clientName: 'Gülşirin Mämmedowa',
      serviceName: 'Saç reňklemek',
      startsAt: DateTime(2026, 8, 13, 9, 30),
      price: 80,
    ),
    Appointment(
      id: 'a3',
      customerId: 'c3',
      clientName: 'Oguljahan Hydyrowa',
      serviceName: 'Keratin prosedurasy',
      startsAt: DateTime(2026, 8, 13, 10),
      price: 100,
    ),
    Appointment(
      id: 'a4',
      customerId: 'c4',
      clientName: 'Mähri Gurbanowa',
      serviceName: 'Saç kesmek',
      startsAt: DateTime(2026, 8, 13, 10, 30),
      price: 50,
      status: AppointmentStatus.arrived,
    ),
    Appointment(
      id: 'a5',
      customerId: 'c5',
      clientName: 'Jeren Myradowa',
      serviceName: 'Manikýur',
      startsAt: DateTime(2026, 8, 13, 11, 30),
      price: 40,
    ),
    Appointment(
      id: 'a6',
      customerId: 'c6',
      clientName: 'Nursoltan Jepbarowa',
      serviceName: 'Botoks saç üçin',
      startsAt: DateTime(2026, 8, 13, 13),
      price: 120,
    ),
  ];
}

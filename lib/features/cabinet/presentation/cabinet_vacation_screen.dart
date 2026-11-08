part of '../../../app/komekci_app.dart';

/// The master's vacations (`/me/vacations`): the list on top, and a form to
/// add another period. Each add/remove is sent to the server immediately.
class VacationScreen extends StatefulWidget {
  const VacationScreen({super.key});

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

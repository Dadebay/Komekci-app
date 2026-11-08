part of '../../../app/komekci_app.dart';

extension _VacationDatePicker on _VacationScreenState {
  Future<void> _pickDateWithUpdate({
    required bool isStart,
    required void Function(VoidCallback) update,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    update(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_start.isAfter(_end)) _start = _end;
      }
    });
  }

}

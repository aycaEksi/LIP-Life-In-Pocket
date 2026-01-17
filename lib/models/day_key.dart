String ymd(DateTime d) {
  final yy = d.year.toString().padLeft(4, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return "$yy-$mm-$dd";
}

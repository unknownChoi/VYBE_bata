class DayHours {
  final bool isOpen;
  final String? open;
  final String? close;

  const DayHours({required this.isOpen, this.open, this.close});

  static const closed = DayHours(isOpen: false);

  factory DayHours.fromMap(Map<String, dynamic>? map) {
    if (map == null) return closed;
    return DayHours(
      isOpen: map['isOpen'] as bool? ?? false,
      open: map['open'] as String?,
      close: map['close'] as String?,
    );
  }

  bool get isCurrentlyOpen {
    if (!isOpen || open == null || close == null) return false;
    final now = DateTime.now();
    final cur = now.hour * 60 + now.minute;
    final o = _toMin(open!);
    final c = _toMin(close!);
    return c < o ? cur >= o || cur < c : cur >= o && cur < c;
  }

  int _toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  Map<String, dynamic> toMap() => {
        'isOpen': isOpen,
        if (open != null) 'open': open,
        if (close != null) 'close': close,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayHours &&
          isOpen == other.isOpen &&
          open == other.open &&
          close == other.close;

  @override
  int get hashCode => Object.hash(isOpen, open, close);
}

class OperatingHours {
  final DayHours mon;
  final DayHours tue;
  final DayHours wed;
  final DayHours thu;
  final DayHours fri;
  final DayHours sat;
  final DayHours sun;

  const OperatingHours({
    this.mon = DayHours.closed,
    this.tue = DayHours.closed,
    this.wed = DayHours.closed,
    this.thu = DayHours.closed,
    this.fri = DayHours.closed,
    this.sat = DayHours.closed,
    this.sun = DayHours.closed,
  });

  DayHours get today => dayOf(DateTime.now().weekday);

  DayHours dayOf(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return mon;
      case DateTime.tuesday:
        return tue;
      case DateTime.wednesday:
        return wed;
      case DateTime.thursday:
        return thu;
      case DateTime.friday:
        return fri;
      case DateTime.saturday:
        return sat;
      case DateTime.sunday:
        return sun;
      default:
        return DayHours.closed;
    }
  }

  factory OperatingHours.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OperatingHours();
    return OperatingHours(
      mon: DayHours.fromMap(map['mon'] as Map<String, dynamic>?),
      tue: DayHours.fromMap(map['tue'] as Map<String, dynamic>?),
      wed: DayHours.fromMap(map['wed'] as Map<String, dynamic>?),
      thu: DayHours.fromMap(map['thu'] as Map<String, dynamic>?),
      fri: DayHours.fromMap(map['fri'] as Map<String, dynamic>?),
      sat: DayHours.fromMap(map['sat'] as Map<String, dynamic>?),
      sun: DayHours.fromMap(map['sun'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() => {
        'mon': mon.toMap(),
        'tue': tue.toMap(),
        'wed': wed.toMap(),
        'thu': thu.toMap(),
        'fri': fri.toMap(),
        'sat': sat.toMap(),
        'sun': sun.toMap(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperatingHours &&
          mon == other.mon &&
          tue == other.tue &&
          wed == other.wed &&
          thu == other.thu &&
          fri == other.fri &&
          sat == other.sat &&
          sun == other.sun;

  @override
  int get hashCode => Object.hash(mon, tue, wed, thu, fri, sat, sun);
}

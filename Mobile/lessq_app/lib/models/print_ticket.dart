class PrintOptions {
  final int copies;
  final bool duplex;
  final String colorMode;
  final String? pageRange;

  const PrintOptions({
    required this.copies,
    required this.duplex,
    required this.colorMode,
    this.pageRange,
  });

  factory PrintOptions.fromJson(Map<String, dynamic> json) => PrintOptions(
    copies: json['copies'] as int,
    duplex: json['duplex'] as bool,
    colorMode: json['colorMode'] as String,
    pageRange: json['pageRange'] as String?,
  );

  String get colorLabel => colorMode == 'color' ? 'Color' : 'Blanco y negro';
  String get duplexLabel => duplex ? 'Doble cara' : 'Una cara';
}

class PrintTicket {
  final String id;
  final int ticketNumber;
  final String documentName;
  final PrintOptions options;
  final String status;
  final int queuePosition;
  final DateTime createdAt;

  const PrintTicket({
    required this.id,
    required this.ticketNumber,
    required this.documentName,
    required this.options,
    required this.status,
    required this.queuePosition,
    required this.createdAt,
  });

  factory PrintTicket.fromJson(Map<String, dynamic> json) => PrintTicket(
    id: json['id'] as String,
    ticketNumber: json['ticketNumber'] as int,
    documentName: json['documentName'] as String,
    options: PrintOptions.fromJson(json['options'] as Map<String, dynamic>),
    status: json['status'] as String,
    queuePosition: json['queuePosition'] as int,
    createdAt: DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now(),
  );

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
}

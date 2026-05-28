class QueueStatus {
  final int? currentServingTicket;
  final int totalWaiting;
  final List<int> pendingTickets;

  const QueueStatus({
    required this.currentServingTicket,
    required this.totalWaiting,
    required this.pendingTickets,
  });

  factory QueueStatus.fromJson(Map<String, dynamic> json) => QueueStatus(
    currentServingTicket: json['currentServingTicket'] as int?,
    totalWaiting: json['totalWaiting'] as int,
    pendingTickets: (json['pendingTickets'] as List<dynamic>)
        .map((e) => e as int)
        .toList(),
  );
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/print_ticket.dart';
import '../models/queue_status.dart';
import '../services/api_service.dart';

class TicketScreen extends StatefulWidget {
  final PrintTicket ticket;

  const TicketScreen({super.key, required this.ticket});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late PrintTicket _ticket;
  QueueStatus? _queueStatus;
  Timer? _timer;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final results = await Future.wait([
        ApiService.getTicket(_ticket.id),
        ApiService.getQueueStatus(),
      ]);
      if (mounted) {
        setState(() {
          _ticket = results[0] as PrintTicket;
          _queueStatus = results[1] as QueueStatus;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ticket'),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _refresh,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _TicketCard(
              ticket: _ticket,
              queueStatus: _queueStatus,
            ),
            const SizedBox(height: 16),
            _SummaryCard(ticket: _ticket),
            const SizedBox(height: 16),
            _StatusBadge(status: _ticket.status),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final PrintTicket ticket;
  final QueueStatus? queueStatus;

  const _TicketCard({required this.ticket, required this.queueStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Tu número de turno',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${ticket.ticketNumber}',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 80,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: AppColors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoStat(
                label: 'Atendiendo',
                value: queueStatus?.currentServingTicket != null
                    ? '#${queueStatus!.currentServingTicket}'
                    : '—',
              ),
              _InfoStat(
                label: 'Posición en cola',
                value: ticket.isPending
                    ? '${ticket.queuePosition}'
                    : ticket.isInProgress
                        ? 'Ahora'
                        : 'Listo',
              ),
              _InfoStat(
                label: 'Esperando',
                value: queueStatus != null
                    ? '${queueStatus!.totalWaiting}'
                    : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;

  const _InfoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PrintTicket ticket;

  const _SummaryCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del pedido',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.description_rounded,
            label: 'Archivo',
            value: ticket.documentName,
          ),
          const Divider(height: 20, color: AppColors.divider),
          _SummaryRow(
            icon: Icons.copy_rounded,
            label: 'Copias',
            value: '${ticket.options.copies}',
          ),
          const Divider(height: 20, color: AppColors.divider),
          _SummaryRow(
            icon: Icons.flip_rounded,
            label: 'Cara',
            value: ticket.options.duplexLabel,
          ),
          const Divider(height: 20, color: AppColors.divider),
          _SummaryRow(
            icon: Icons.palette_rounded,
            label: 'Color',
            value: ticket.options.colorLabel,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'in_progress' => ('En proceso', AppColors.secondary),
      'completed' => ('Completado', AppColors.primary),
      _ => ('En espera', AppColors.mutedText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

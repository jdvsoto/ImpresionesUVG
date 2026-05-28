import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/queue_status.dart';
import '../services/api_service.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  QueueStatus? _status;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final status = await ApiService.getQueueStatus();
      if (mounted) setState(() => _status = status);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de la Cola'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _hasError
              ? _ErrorView(onRetry: _load)
              : _QueueContent(status: _status!, onRefresh: _load),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: AppColors.mutedText),
            const SizedBox(height: 16),
            const Text(
              'No se pudo conectar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Verifica tu conexión e intenta de nuevo.',
              style: TextStyle(color: AppColors.mutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueContent extends StatelessWidget {
  final QueueStatus status;
  final VoidCallback onRefresh;

  const _QueueContent({required this.status, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CurrentServingCard(ticketNumber: status.currentServingTicket),
          const SizedBox(height: 20),
          _WaitingHeader(count: status.totalWaiting),
          const SizedBox(height: 12),
          if (status.pendingTickets.isEmpty)
            _EmptyQueue()
          else
            _PendingList(tickets: status.pendingTickets),
        ],
      ),
    );
  }
}

class _CurrentServingCard extends StatelessWidget {
  final int? ticketNumber;

  const _CurrentServingCard({required this.ticketNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Atendiendo ahora',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ticketNumber != null ? '#$ticketNumber' : '—',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 72,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingHeader extends StatelessWidget {
  final int count;

  const _WaitingHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.people_rounded, size: 18, color: AppColors.mutedText),
        const SizedBox(width: 6),
        Text(
          count == 1 ? '1 persona en espera' : '$count personas en espera',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 36, color: AppColors.secondary),
          SizedBox(height: 10),
          Text(
            'La cola está vacía',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No hay pedidos pendientes.',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _PendingList extends StatelessWidget {
  final List<int> tickets;

  const _PendingList({required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(tickets.length, (i) {
          final number = tickets[i];
          final isFirst = i == 0;
          return Column(
            children: [
              if (i > 0)
                const Divider(height: 1, indent: 16, endIndent: 16,
                    color: AppColors.divider),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isFirst
                        ? Icons.arrow_forward_rounded
                        : Icons.hourglass_empty_rounded,
                    size: 18,
                    color: isFirst ? AppColors.secondary : AppColors.mutedText,
                  ),
                ),
                title: Text(
                  '#$number',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isFirst ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                trailing: isFirst
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      )
                    : Text(
                        'Pos. ${i + 1}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.mutedText),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

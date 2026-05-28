import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/queue_status.dart';
import '../services/api_service.dart';
import 'upload_screen.dart';
import 'queue_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QueueStatus? _queueStatus;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQueueStatus();
  }

  Future<void> _loadQueueStatus() async {
    setState(() => _loading = true);
    try {
      final status = await ApiService.getQueueStatus();
      if (mounted) setState(() => _queueStatus = status);
    } catch (_) {
      if (mounted) setState(() => _queueStatus = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(queueStatus: _queueStatus, loading: _loading),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  _ActionCard(
                    icon: Icons.upload_file_rounded,
                    title: 'Nueva Impresión',
                    subtitle: 'Sube tu documento y elige las opciones',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UploadScreen()),
                    ).then((_) => _loadQueueStatus()),
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.format_list_numbered_rounded,
                    title: 'Ver Cola',
                    subtitle: 'Consulta el estado de la fila de espera',
                    color: AppColors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QueueScreen()),
                    ).then((_) => _loadQueueStatus()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final QueueStatus? queueStatus;
  final bool loading;

  const _Header({required this.queueStatus, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LessQ',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Impresiones sin espera',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              _QueuePeek(queueStatus: queueStatus, loading: loading),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueuePeek extends StatelessWidget {
  final QueueStatus? queueStatus;
  final bool loading;

  const _QueuePeek({required this.queueStatus, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: loading
          ? const Center(
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : queueStatus == null
              ? Text(
                  'No se pudo conectar al servidor',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                )
              : Row(
                  children: [
                    _PeekStat(
                      label: 'Atendiendo',
                      value: queueStatus!.currentServingTicket != null
                          ? '#${queueStatus!.currentServingTicket}'
                          : '—',
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.white.withValues(alpha: 0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    _PeekStat(
                      label: 'En espera',
                      value: '${queueStatus!.totalWaiting}',
                    ),
                  ],
                ),
    );
  }
}

class _PeekStat extends StatelessWidget {
  final String label;
  final String value;

  const _PeekStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.65),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import 'ticket_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  String? _fileName;
  int _copies = 1;
  bool _duplex = false;
  String _colorMode = 'bw';
  bool _uploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un archivo primero.')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      final ticket = await ApiService.createTicket(
        file: _selectedFile!,
        copies: _copies,
        duplex: _duplex,
        colorMode: _colorMode,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TicketScreen(ticket: ticket)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Impresión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilePicker(
              fileName: _fileName,
              onTap: _pickFile,
            ),
            const SizedBox(height: 28),
            const _SectionLabel('Opciones de impresión'),
            const SizedBox(height: 14),
            _CopiesCounter(
              value: _copies,
              onDecrement: _copies > 1
                  ? () => setState(() => _copies--)
                  : null,
              onIncrement: _copies < 20
                  ? () => setState(() => _copies++)
                  : null,
            ),
            const SizedBox(height: 14),
            _SegmentedOption(
              label: 'Cara de impresión',
              options: const ['Una cara', 'Doble cara'],
              values: const ['false', 'true'],
              selected: _duplex ? 'true' : 'false',
              onChanged: (v) => setState(() => _duplex = v == 'true'),
            ),
            const SizedBox(height: 14),
            _SegmentedOption(
              label: 'Color',
              options: const ['Blanco y negro', 'Color'],
              values: const ['bw', 'color'],
              selected: _colorMode,
              onChanged: (v) => setState(() => _colorMode = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _uploading ? null : _submit,
              child: _uploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Generar Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;

  const _FilePicker({required this.fileName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? AppColors.primary : AppColors.divider,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.description_rounded : Icons.upload_file_rounded,
              size: 40,
              color: hasFile ? AppColors.primary : AppColors.mutedText,
            ),
            const SizedBox(height: 10),
            Text(
              hasFile ? fileName! : 'Toca para seleccionar archivo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                color:
                    hasFile ? AppColors.primary : AppColors.mutedText,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!hasFile) ...[
              const SizedBox(height: 4),
              const Text(
                'PDF, JPG, PNG, DOCX',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedText,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CopiesCounter extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _CopiesCounter({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Copias',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.mutedText,
        ),
      ),
    );
  }
}

class _SegmentedOption extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentedOption({
    required this.label,
    required this.options,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(options.length, (i) {
              final isSelected = values[i] == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(values[i]),
                  child: Container(
                    margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      options[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.mutedText,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

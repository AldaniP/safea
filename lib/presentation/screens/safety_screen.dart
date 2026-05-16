import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';

import '../../data/vault_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  String _activeTab = 'crisis'; // crisis, plan, vault

  Map<String, dynamic>? _safetyPlan;
  bool _isEditing = false;

  bool _hasPin = false;
  bool _isUnlocked = false;
  final TextEditingController _pinController = TextEditingController();
  List<Map<String, dynamic>> _notes = [];
  final TextEditingController _noteController = TextEditingController();
  String _vaultError = "";
  Map<String, dynamic>? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _safetyPlan = context.read<VaultService>().getSafetyPlan();
      _hasPin = context.read<VaultService>().isVaultSetup();
    });
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat melakukan panggilan ke $phoneNumber'),
          ),
        );
      }
    }
  }

  void _handleSavePlan() async {
    if (_safetyPlan != null) {
      await context.read<VaultService>().saveSafetyPlan(_safetyPlan!);
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _handleUpdateList(String key, int index, String value) {
    setState(() {
      _safetyPlan![key][index] = value;
    });
  }

  void _handleUpdateContact(int index, String field, String value) {
    setState(() {
      _safetyPlan!['contacts'][index][field] = value;
    });
  }

  void _handleVaultAccess() async {
    setState(() {
      _vaultError = "";
    });

    final pin = _pinController.text;

    if (!_hasPin) {
      if (pin.length < 4) {
        setState(() {
          _vaultError = "PIN minimal 4 karakter";
        });
        return;
      }
      await context.read<VaultService>().setupVault(pin);
      setState(() {
        _hasPin = true;
        _isUnlocked = true;
        _pinController.clear();
        _notes = context.read<VaultService>().getNotes();
      });
    } else {
      if (context.read<VaultService>().verifyPin(pin)) {
        setState(() {
          _isUnlocked = true;
          _pinController.clear();
          _notes = context.read<VaultService>().getNotes();
        });
      } else {
        setState(() {
          _vaultError = "PIN Salah!";
        });
      }
    }
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.any);

    if (result != null) {
      PlatformFile file = result.files.first;

      String? base64Data;
      if (file.bytes != null) {
        base64Data =
            'data:${file.extension ?? "application/octet-stream"};base64,${base64Encode(file.bytes!)}';
      } else if (file.path != null) {
        final fileObj = File(file.path!);
        final readBytes = await fileObj.readAsBytes();
        base64Data =
            'data:${file.extension ?? "application/octet-stream"};base64,${base64Encode(readBytes)}';
      }

      setState(() {
        _selectedFile = {
          'name': file.name,
          'type': file.extension ?? 'unknown',
          'data': base64Data,
        };
      });
    }
  }

  void _handleAddNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty && _selectedFile == null) return;

    final success = await context.read<VaultService>().addNote(content, _selectedFile);
    if (success) {
      setState(() {
        _notes = context.read<VaultService>().getNotes();
        _noteController.clear();
        _selectedFile = null;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penyimpanan penuh atau gagal menyimpan.'),
          ),
        );
      }
    }
  }

  void _handlePanicWipe() async {
    // In a real app, use a proper dialog
    await context.read<VaultService>().panicWipe();
    setState(() {
      _hasPin = false;
      _isUnlocked = false;
      _notes = [];
      _pinController.clear();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildTabSelector(context),
            const SizedBox(height: 24),
            if (_activeTab == 'crisis') _buildCrisisContent(context),
            if (_activeTab == 'plan' && _safetyPlan != null)
              _buildPlanContent(context),
            if (_activeTab == 'vault') _buildVaultContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.shieldCheck,
              color: Color(0xFF2DD4BF),
              size: 32,
            ), // teal-400
            const SizedBox(width: 12),
            Text(
              'Keamanan & Bantuan',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Pusat kendali untuk rencana keamanan pribadi, brankas bukti rahasia, dan kontak krisis.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('Bantuan Darurat', 'crisis', Colors.red),
          _buildTabButton('Rencana Aman', 'plan', Colors.white),
          _buildTabButton(
            'Brankas Bukti',
            'vault',
            const Color(0xFF818CF8),
          ), // indigo-400
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value, Color activeColor) {
    final isActive = _activeTab == value;
    return InkWell(
      onTap: () => setState(() => _activeTab = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCrisisContent(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.red.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(
                  LucideIcons.alertOctagon,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Apakah Anda dalam bahaya saat ini?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Jika Anda merasa terancam, segera hubungi otoritas terkait atau layanan krisis darurat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFFECACA)),
                ), // red-200
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 400;
                    final btns = [
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: ElevatedButton.icon(
                          onPressed: () => _makeCall('112'),
                          icon: const Icon(LucideIcons.phone),
                          label: const Text('Hubungi 112 (Polisi)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626), // red-600
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                        ),
                      ),
                      if (isWide)
                        const SizedBox(width: 16)
                      else
                        const SizedBox(height: 16),
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: ElevatedButton(
                          onPressed: () => _makeCall('129'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFEA580C,
                            ), // orange-600
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('SAPA 129 (Kekerasan)'),
                        ),
                      ),
                    ];
                    return isWide
                        ? Row(children: btns)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: btns,
                          );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hotline Bantuan Psikologis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final content = [
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "D'HOPE (Yayasan Harapan)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Pencegahan Bunuh Diri",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () => _makeCall('021123456'),
                                child: const Text('021-123456'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isWide)
                        const SizedBox(width: 16)
                      else
                        const SizedBox(height: 16),
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kemenkes Sejiwa",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Konseling Darurat Mental",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              OutlinedButton(
                                onPressed: () => _makeCall('119'),
                                child: const Text('119 ext. 8'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                    return isWide
                        ? Row(children: content)
                        : Column(children: content);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanContent(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rencana Keamanan Pribadi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Panduan langkah saat krisis atau serangan panik melanda.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _handleSavePlan,
                    child: const Text('Simpan Rencana'),
                  )
                else
                  OutlinedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    child: const Text('Edit Rencana'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildPlanSection('1. Tanda Peringatan Krisis', 'warnings'),
            const SizedBox(height: 24),
            _buildPlanSection(
              '2. Langkah Menenangkan Diri',
              'copingStrategies',
            ),
            const SizedBox(height: 24),
            const Text(
              '3. Kontak Bantuan Tepercaya',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2DD4BF),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final items = (_safetyPlan!['contacts'] as List)
                    .asMap()
                    .entries
                    .map((e) {
                      final idx = e.key;
                      final c = e.value;
                      return SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 16) / 2
                            : double.infinity,
                        child: Container(
                          margin: EdgeInsets.only(bottom: isWide ? 0 : 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: _isEditing
                              ? Column(
                                  children: [
                                    TextField(
                                      controller:
                                          TextEditingController(
                                              text: c['title'],
                                            )
                                            ..selection =
                                                TextSelection.collapsed(
                                                  offset: c['title'].length,
                                                ),
                                      onChanged: (v) =>
                                          _handleUpdateContact(idx, 'title', v),
                                      decoration: const InputDecoration(
                                        hintText: 'Nama Kontak',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller:
                                          TextEditingController(text: c['desc'])
                                            ..selection =
                                                TextSelection.collapsed(
                                                  offset: c['desc'].length,
                                                ),
                                      onChanged: (v) =>
                                          _handleUpdateContact(idx, 'desc', v),
                                      decoration: const InputDecoration(
                                        hintText: 'Deskripsi/Kapan Dihubungi',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller:
                                          TextEditingController(
                                              text: c['phone'],
                                            )
                                            ..selection =
                                                TextSelection.collapsed(
                                                  offset: c['phone'].length,
                                                ),
                                      onChanged: (v) =>
                                          _handleUpdateContact(idx, 'phone', v),
                                      decoration: const InputDecoration(
                                        hintText: 'Nomor Telepon',
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          c['desc'],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () => _makeCall(c['phone']),
                                      icon: const Icon(
                                        LucideIcons.phone,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    })
                    .toList();
                return isWide
                    ? Wrap(spacing: 16, runSpacing: 16, children: items)
                    : Column(children: items);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSection(String title, String key) {
    final list = _safetyPlan![key] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2DD4BF),
            letterSpacing: 1.5,
          ),
        ), // teal-400
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: list.asMap().entries.map((e) {
              final idx = e.key;
              final val = e.value as String;
              if (_isEditing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: TextEditingController(text: val)
                      ..selection = TextSelection.collapsed(offset: val.length),
                    onChanged: (v) => _handleUpdateList(key, idx, v),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Icon(Icons.circle, size: 6, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        val,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVaultContent(BuildContext context) {
    return Card(
      color: const Color(0xFF312E81).withValues(alpha: 0.2), // indigo-900/20
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
        ), // indigo-500/30
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.lock,
                  color: Color(0xFF818CF8),
                ), // indigo-400
                const SizedBox(width: 8),
                const Text(
                  'Brankas Bukti Terenkripsi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF818CF8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Penyimpanan aman untuk bukti (screenshot, chat, foto, rekaman suara). Dilindungi PIN lokal & tidak dicadangkan secara otomatis untuk keamanan maksimum.',
              style: TextStyle(color: Color(0xFFC7D2FE)), // indigo-200
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: !_isUnlocked
                  ? _buildVaultLogin(context)
                  : _buildVaultInner(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultLogin(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.shield,
            color: Color(0xFF6366F1),
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _hasPin ? 'Brankas Terkunci' : 'Setup PIN Brankas',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _hasPin
              ? 'Masukkan PIN Anda untuk mengakses dokumen yang tersimpan.'
              : 'Buat PIN baru (minimal 4 karakter) untuk mengamankan brankas ini.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 150,
          child: TextField(
            controller: _pinController,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(letterSpacing: 8, fontSize: 24),
            decoration: const InputDecoration(hintText: 'PIN'),
          ),
        ),
        if (_vaultError.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _vaultError,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleVaultAccess,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(_hasPin ? 'Buka Brankas' : 'Simpan PIN'),
        ),
      ],
    );
  }

  Widget _buildVaultInner(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Isi Brankas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            OutlinedButton(
              onPressed: () => setState(() => _isUnlocked = false),
              child: const Text('Kunci Kembali'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_notes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Text(
                'Belum ada catatan/bukti tersimpan.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.separated(
              itemCount: _notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final note = _notes[index];
                final date = DateTime.parse(note['date'] as String);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note['content'] as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (note['file'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.paperclip,
                                size: 14,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note['file']['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if ((note['file']['type'] as String).startsWith(
                              'image/',
                            ) ||
                            (note['file']['name'] as String).endsWith('.jpg') ||
                            (note['file']['name'] as String).endsWith(
                              '.png',
                            )) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(
                                (note['file']['data'] as String).split(',')[1],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tulis catatan atau log kejadian baru...',
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedFile != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.file, size: 16, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFile!['name'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(LucideIcons.paperclip, size: 16),
              label: const Text('Lampirkan File'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleAddNote,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Simpan Bukti'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.eyeOff, size: 16),
              label: const Text('Mode Penyamaran'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
            TextButton(
              onPressed: _handlePanicWipe,
              style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
              child: const Text('Hapus Semua Cepat (Panic Mode)'),
            ),
          ],
        ),
      ],
    );
  }
}

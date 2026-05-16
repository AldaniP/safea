import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../data/profile_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isEditing = false;

  late Map<String, dynamic> _profileData;
  late Map<String, dynamic> _tempData;

  bool _relaxationReminder = true;
  bool _weeklyReport = false;

  @override
  void initState() {
    super.initState();
    _profileData = ProfileService.getProfile();
    _tempData = Map.from(_profileData);
  }

  void _handleSave() async {
    setState(() {
      _profileData = Map.from(_tempData);
      _isEditing = false;
    });
    await ProfileService.updateProfile(_profileData);
  }

  void _handleCancel() {
    setState(() {
      _tempData = Map.from(_profileData);
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildProfileCard(context)),
                      const SizedBox(width: 32),
                      Expanded(flex: 2, child: _buildSettingsSection(context)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildProfileCard(context),
                    const SizedBox(height: 32),
                    _buildSettingsSection(context),
                  ],
                );
              },
            ),
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
              LucideIcons.user,
              color: Color(0xFF2DD4BF),
              size: 32,
            ), // teal-400
            const SizedBox(width: 12),
            Text(
              'Profil Akun',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Kelola informasi pribadi, preferensi, dan pengaturan privasi Anda.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF14B8A6,
                ).withValues(alpha: 0.2), // teal-500/20
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                LucideIcons.user,
                color: Color(0xFF2DD4BF),
                size: 48,
              ), // teal-400
            ),
            const SizedBox(height: 24),
            if (_isEditing) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: TextEditingController(text: _tempData['name'])
                      ..selection = TextSelection.collapsed(
                        offset: _tempData['name'].length,
                      ),
                    onChanged: (v) => _tempData['name'] = v,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: TextEditingController(text: _tempData['email'])
                      ..selection = TextSelection.collapsed(
                        offset: _tempData['email'].length,
                      ),
                    onChanged: (v) => _tempData['email'] = v,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                _profileData['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _profileData['email'],
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF6366F1,
                ).withValues(alpha: 0.1), // indigo-500/10
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'PERSONAL PLAN',
                style: TextStyle(
                  color: Color(0xFF818CF8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ), // indigo-400
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleCancel,
                      icon: const Icon(LucideIcons.x, size: 16),
                      label: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Simpan'),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton(
                onPressed: () => setState(() => _isEditing = true),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Edit Profil'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.shield,
                      color: Color(0xFF2DD4BF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Keamanan & Privasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pengaturan login dan keamanan data.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildSettingsRow(
                  context,
                  LucideIcons.mail,
                  'Email Address',
                  _profileData['email'],
                  'Ubah',
                ),
                const SizedBox(height: 16),
                _buildSettingsRow(
                  context,
                  LucideIcons.key,
                  'Kata Sandi',
                  'Terakhir diubah 2 bulan yang lalu',
                  'Perbarui',
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
                const Row(
                  children: [
                    Icon(LucideIcons.bell, color: Color(0xFF2DD4BF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Preferensi Notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildToggleRow(
                  context,
                  'Pengingat Relaksasi',
                  'Dapatkan notifikasi waktu istirahat',
                  _relaxationReminder,
                  (v) => setState(() => _relaxationReminder = v),
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  context,
                  'Laporan Mingguan',
                  'Analisis Progres ke email Anda',
                  _weeklyReport,
                  (v) => setState(() => _weeklyReport = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            context.read<AppState>().logout();
            context.go('/landing');
          },
          icon: const Icon(LucideIcons.logOut),
          label: const Text('Keluar Akun', style: TextStyle(fontSize: 16)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red[400],
            side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    String btnLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2DD4BF),
            ),
            child: Text(btnLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context,
    String title,
    String desc,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2DD4BF),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';

import '../providers/language_provider.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_sync_service.dart';

import '../utils/app_localizations.dart';
import 'language_selection_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DatabaseService _dbService;
  late AuthService _authService;
  late FirebaseSyncService _syncService;

  Map<String, int> _localStats = {
    'total': 0,
    'diseased': 0,
    'healthy': 0,
  };

  bool _isLoading = true;
  bool _isSyncing = false;
  bool _syncEnabled = false;

  // ✅ ONLY ONE initState
  @override
  void initState() {
    super.initState();

    _dbService = DatabaseService();
    _authService = AuthService();
    _syncService = FirebaseSyncService();

    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await _dbService.getStatistics();
    final syncEnabled = await _syncService.isSyncEnabled();

    if (!mounted) return;

    setState(() {
      _localStats = stats;
      _syncEnabled = syncEnabled;
      _isLoading = false;
    });
  }

  Future<void> _performSync() async {
    setState(() => _isSyncing = true);

    final result = await _syncService.performFullSync();

    if (!mounted) return;

    setState(() => _isSyncing = false);

    _showSnack(
      result['success'] ? 'Synced successfully' : result['message'],
      result['success'] ? AppColors.success : AppColors.error,
    );
  }

  Future<void> _toggleSync(bool value) async {
    setState(() => _syncEnabled = value);
    await _syncService.setSyncEnabled(value);

    if (value) await _performSync();
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final result = await _authService.deleteAccount();

    if (!mounted) return;

    if (result['success']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    } else {
      _showSnack(result['message'], AppColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final localizations = AppLocalizations.of(context);
    final user = _authService.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(localizations, user, isAnonymous),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildStatisticsSection(localizations),
              const SizedBox(height: AppConstants.paddingLarge),

              if (!isAnonymous) _buildSyncSection(),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildSettingsSection(context, languageProvider, localizations),
              const SizedBox(height: AppConstants.paddingLarge),

              _buildDangerZone(isAnonymous),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations, dynamic user, bool isAnonymous) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.radiusXLarge),
          bottomRight: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              isAnonymous
                  ? '👤'
                  : (user?.displayName?.substring(0, 1).toUpperCase() ?? 'U'),
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            isAnonymous ? 'Guest User' : (user?.displayName ?? 'Farmer'),
            style: AppTextStyles.h4.copyWith(color: Colors.white),
          ),
          if (!isAnonymous)
            Text(
              user?.email ?? '',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      child: Row(
        children: [
          _statCard(_localStats['total'].toString(), localizations.totalScans, Icons.analytics, AppColors.primary),
          _statCard(_localStats['diseased'].toString(), localizations.diseasesDetected, Icons.bug_report, AppColors.error),
          _statCard(_localStats['healthy'].toString(), localizations.healthyScans, Icons.check_circle, AppColors.success),
        ],
      ),
    );
  }

  Widget _statCard(String v, String l, IconData i, Color c) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Icon(i, color: c),
            Text(v, style: AppTextStyles.h4),
            Text(l, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSection() {
    return Card(
      child: SwitchListTile(
        value: _syncEnabled,
        onChanged: _toggleSync,
        title: const Text('Cloud Sync'),
        subtitle: const Text('Backup & sync across devices'),
        secondary: _isSyncing
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(Icons.cloud),
      ),
    );
  }

  Widget _buildSettingsSection(
      BuildContext context,
      LanguageProvider languageProvider,
      AppLocalizations localizations,
      ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(localizations.language),
      subtitle: Text(
        languageProvider.getLanguageName(
          languageProvider.currentLocale.languageCode,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LanguageSelectionScreen(),
          ),
        );
      },
    );
  }

  Widget _buildDangerZone(bool isAnonymous) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Sign Out'),
          onTap: _signOut,
        ),
        if (!isAnonymous)
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Delete Account'),
            onTap: _deleteAccount,
          ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/scan_history.dart';
import '../services/database_service.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const HistoryScreen(),
    const EncyclopediaPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Encyclopedia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _dbService = DatabaseService();
  Map<String, int> _stats = {'total': 0, 'diseased': 0, 'healthy': 0};
  List<ScanHistory> _recentScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await _dbService.getStatistics();
      final scans = await _dbService.getScansByFilter(limit: 3);

      setState(() {
        _stats = stats;
        _recentScans = scans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading data: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppConstants.radiusXLarge),
                      bottomRight: Radius.circular(AppConstants.radiusXLarge),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.homeWelcome,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                AppStrings.appName,
                                style: AppTextStyles.h3.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(
                              AppConstants.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMedium,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      Text(
                        AppStrings.homeSubtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Quick Scan Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: _buildQuickScanCard(),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: _buildStatsSection(),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Recent Scans
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: _buildRecentScansSection(),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Tips Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                  ),
                  child: _buildTipsSection(),
                ),

                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickScanCard() {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
        _refreshData(); // Refresh after returning from camera
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          gradient: AppColors.successGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: AppConstants.iconLarge,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.scanNow,
                    style: AppTextStyles.h5.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detect diseases in seconds',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            _stats['total'].toString(),
            AppStrings.totalScans,
            Icons.analytics_rounded,
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: _buildStatCard(
            _stats['diseased'].toString(),
            AppStrings.diseasesDetected,
            Icons.bug_report_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: AppConstants.iconMedium),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(value, style: AppTextStyles.statNumber),
          Text(
            label,
            style: AppTextStyles.statLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.recentScans, style: AppTextStyles.h5),
            TextButton(
              onPressed: () {
                // Switch to history tab
                final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                homeState?.setState(() {
                  homeState._selectedIndex = 1;
                });
              },
              child: Text(AppStrings.viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _recentScans.isEmpty
            ? _buildEmptyState()
            : Column(
          children: _recentScans
              .map((scan) => _buildRecentScanCard(scan))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentScanCard(ScanHistory scan) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            child: File(scan.imagePath).existsSync()
                ? Image.file(
              File(scan.imagePath),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Container(
              width: 50,
              height: 50,
              color: AppColors.borderLight,
              child: Icon(Icons.image, color: AppColors.textLight),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.diseaseName,
                  style: AppTextStyles.labelBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  scan.getFormattedDate(),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Icon(
            scan.isHealthy ? Icons.check_circle : Icons.warning,
            color: scan.isHealthy ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            AppStrings.noRecentScans,
            style: AppTextStyles.h6.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            AppStrings.startFirstScan,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: AppColors.info, size: AppConstants.iconLarge),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.tipOfDay, style: AppTextStyles.labelBold),
                const SizedBox(height: 4),
                Text(AppStrings.tip1, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder pages for other tabs
class EncyclopediaPage extends StatelessWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.encyclopediaTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Encyclopedia coming soon!')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Profile coming soon!')),
    );
  }
}
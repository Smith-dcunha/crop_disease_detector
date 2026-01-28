import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../models/disease_info.dart';
import '../services/encyclopedia_service.dart';
import 'disease_detail_screen.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<DiseaseInfo> _allDiseases = [];
  List<DiseaseInfo> _filteredDiseases = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await EncyclopediaService.initialize();

      final diseases = await EncyclopediaService.getAllDiseases();
      final categories = await EncyclopediaService.getCategories();
      final stats = await EncyclopediaService.getStatistics();

      setState(() {
        _allDiseases = diseases;
        _filteredDiseases = diseases;
        _categories = categories;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load encyclopedia data');
    }
  }

  void _filterDiseases(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDiseases = _selectedCategory == 'all'
            ? _allDiseases
            : _allDiseases.where((d) => d.category.toLowerCase() == _selectedCategory).toList();
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredDiseases = _allDiseases.where((disease) {
          final matchesQuery = disease.name.toLowerCase().contains(lowerQuery) ||
              disease.scientificName.toLowerCase().contains(lowerQuery) ||
              disease.affectedCrops.any((c) => c.toLowerCase().contains(lowerQuery));

          final matchesCategory = _selectedCategory == 'all' ||
              disease.category.toLowerCase() == _selectedCategory;

          return matchesQuery && matchesCategory;
        }).toList();
      }
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterDiseases(_searchController.text);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
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
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white, size: 32),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disease Encyclopedia',
                            style: AppTextStyles.h4.copyWith(color: Colors.white),
                          ),
                          Text(
                            '${_statistics['total'] ?? 0} diseases documented',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _filterDiseases,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search diseases, crops...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        _filterDiseases('');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'All Diseases'),
                Tab(text: 'Categories'),
                Tab(text: 'By Crop'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllDiseasesTab(),
                _buildCategoriesTab(),
                _buildByCropTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDiseasesTab() {
    return Column(
      children: [
        // Category Filter
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            children: [
              _buildCategoryChip('All', 'all'),
              ..._categories.map((cat) => _buildCategoryChip(
                cat['name'],
                cat['id'],
                icon: cat['icon'],
              )),
            ],
          ),
        ),

        // Disease List
        Expanded(
          child: _filteredDiseases.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: _filteredDiseases.length,
            itemBuilder: (context, index) {
              return _buildDiseaseCard(_filteredDiseases[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String category, {String? icon}) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => _selectCategory(category),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDiseaseCard(DiseaseInfo disease) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiseaseDetailScreen(disease: disease),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      disease.getCategoryIcon(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),

                  // Disease Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(disease.name, style: AppTextStyles.h6),
                        const SizedBox(height: 4),
                        Text(
                          disease.scientificName,
                          style: AppTextStyles.caption.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Severity Badge
                  _buildSeverityBadge(disease.severity),
                ],
              ),

              const SizedBox(height: AppConstants.paddingSmall),

              // Description
              Text(
                disease.description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppConstants.paddingSmall),

              // Affected Crops
              Wrap(
                spacing: 4,
                children: disease.affectedCrops.take(3).map((crop) {
                  return Chip(
                    label: Text(crop, style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.secondary),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'high':
        color = AppColors.error;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      case 'low':
        color = AppColors.success;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Text(
        severity,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: _categories.map((category) {
        final count = _allDiseases.where(
              (d) => d.category.toLowerCase() == category['id'],
        ).length;

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
          child: ListTile(
            leading: Text(
              category['icon'],
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(category['name'], style: AppTextStyles.h6),
            subtitle: Text(category['description']),
            trailing: Chip(
              label: Text('$count'),
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
            onTap: () {
              _selectCategory(category['id']);
              _tabController.animateTo(0);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildByCropTab() {
    return FutureBuilder<List<String>>(
      future: EncyclopediaService.getAffectedCrops(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final crops = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: crops.length,
          itemBuilder: (context, index) {
            final crop = crops[index];
            final count = _allDiseases.where(
                  (d) => d.affectedCrops.contains(crop),
            ).length;

            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
              child: ListTile(
                leading: const Icon(Icons.agriculture, color: AppColors.secondary),
                title: Text(crop, style: AppTextStyles.labelBold),
                trailing: Text('$count diseases', style: AppTextStyles.caption),
                onTap: () async {
                  final diseases = await EncyclopediaService.getDiseasesByCrop(crop);
                  // Navigate to filtered list
                  _searchController.text = crop;
                  _filterDiseases(crop);
                  _tabController.animateTo(0);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textLight),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'No diseases found',
            style: AppTextStyles.h6.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Try a different search term',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
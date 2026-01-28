import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    final languages = [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
      {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
      {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
      {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(localizations.selectLanguage),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected =
              languageProvider.currentLocale.languageCode == language['code'];


          return Container(
            margin: const EdgeInsets.only(
              bottom: AppConstants.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                AppConstants.radiusMedium,
              ),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingSmall,
              ),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusSmall,
                  ),
                ),
                child: Center(
                  child: Text(
                    language['nativeName']!.substring(0, 2).toUpperCase(),
                    style: AppTextStyles.h6.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              title: Text(
                language['name']!,
                style: AppTextStyles.h6.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                language['nativeName']!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 28,
              )
                  : Icon(
                Icons.circle_outlined,
                color: AppColors.borderLight,
                size: 28,
              ),
              onTap: () async {
                await languageProvider.changeLanguage(language['code']!);


                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Language changed to ${language['name']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Optional: Pop back after selection
                  // Navigator.pop(context);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
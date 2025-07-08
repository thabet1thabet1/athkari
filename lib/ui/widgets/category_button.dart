import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const CategoryButton({super.key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: AppConstants.spacing8 / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        onTap: onTap,
        child: Container(
          height: AppConstants.categoryButtonHeight,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: Row(
            children: [
              const SizedBox(width: AppConstants.spacing16),
              Icon(icon, color: AppColors.forestGreen, size: 28),
              const SizedBox(width: AppConstants.spacing16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
      label: Text(text),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color ?? AppColors.surface,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (actionText != null)
              TextButton(
                onPressed: onActionPressed,
                child: Text(
                  actionText!,
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ],
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: AppColors.grey) : null,
          ),
        ),
      ],
    );
  }
}
class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final int unreadCount;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'View',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color themeColor;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.notifications_none_outlined,
    this.themeColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: themeColor.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

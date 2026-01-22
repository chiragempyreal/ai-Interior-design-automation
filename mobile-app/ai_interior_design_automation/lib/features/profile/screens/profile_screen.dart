import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/brand_colors.dart';
import '../../../core/providers/preferences_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userEmail = "loading...";
  String _userName =
      "John Designer"; // Mock for now as we don't store name in simple login

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email') ?? "user@designquote.ai";
    });
  }

  Future<void> _launchHelpUrl() async {
    final url = Uri.parse(
      "https://6970fac2d22ae013611ea250--profound-stardust-78b6b9.netlify.app/",
    );
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch support page")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String message = "Error: $e";
        if (e.toString().contains("channel-error")) {
          message = "Please restart the app to enable Help support";
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    // await prefs.remove('user_email'); // Optional: keep email for convenience? User said "enters mail again", so maybe keep it or clear. "Keep it simple" -> clear session.

    if (mounted) {
      context.go('/login');
    }
  }

  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Personal Information", style: BrandTypography.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Full Name", _userName),
            const Divider(),
            _buildInfoRow("Email", _userEmail),
            const Divider(),
            _buildInfoRow("Role", "Senior Interior Architect"),
            const Divider(),
            _buildInfoRow("Member Since", "Jan 2024"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: BrandTypography.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: BrandTypography.bodyRegular.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppearanceModal(PreferencesProvider prefs) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Appearance", style: BrandTypography.h4),
            const SizedBox(height: 16),
            _buildRadioTile<ThemeMode>(
              title: "System Default",
              value: ThemeMode.system,
              groupValue: prefs.themeMode,
              onChanged: (val) {
                prefs.setThemeMode(val!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile<ThemeMode>(
              title: "Light Mode",
              value: ThemeMode.light,
              groupValue: prefs.themeMode,
              onChanged: (val) {
                prefs.setThemeMode(val!);
                Navigator.pop(context);
              },
            ),
            _buildRadioTile<ThemeMode>(
              title: "Dark Mode",
              value: ThemeMode.dark,
              groupValue: prefs.themeMode,
              onChanged: (val) {
                prefs.setThemeMode(val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(PreferencesProvider prefs) {
    final languages = [
      {'name': 'English', 'code': 'en'},
      {'name': 'Spanish', 'code': 'es'},
      {'name': 'French', 'code': 'fr'},
      {'name': 'German', 'code': 'de'},
      {'name': 'Chinese', 'code': 'zh'},
      {'name': 'Japanese', 'code': 'ja'},
      {'name': 'Arabic', 'code': 'ar'},
      {'name': 'Russian', 'code': 'ru'},
      {'name': 'Portuguese', 'code': 'pt'},
      {'name': 'Hindi', 'code': 'hi'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text("Select Language", style: BrandTypography.h4),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected =
                        prefs.locale.languageCode == lang['code'];
                    return ListTile(
                      title: Text(
                        lang['name']!,
                        style: BrandTypography.bodyRegular,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: BrandColors.primary)
                          : null,
                      onTap: () {
                        prefs.setLocale(Locale(lang['code']!));
                        Navigator.pop(context);
                        // Optional: Show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Language switched to ${lang['name']}",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(title, style: BrandTypography.bodyRegular),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: BrandColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 4,
                        ),
                        boxShadow: BrandShadows.medium,
                        image: DecorationImage(
                          image: const AssetImage(
                            'assets/images/user_avatar_placeholder.png',
                          ),
                          onError: (_, __) {},
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: BrandTypography.h3.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      _userEmail,
                      style: BrandTypography.bodySmall.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 40),

              // Settings Items
              _buildSectionHeader("Account"),
              _buildSettingItem(
                icon: Icons.person_outline,
                title: "Personal Information",
                onTap: _showPersonalInfoDialog,
              ),
              _buildSwitchItem(
                icon: Icons.notifications_none,
                title: "Notifications",
                value: prefs.notificationsEnabled,
                onChanged: (val) => prefs.setNotificationsEnabled(val),
              ),

              // Security & Privacy removed
              const SizedBox(height: 24),
              _buildSectionHeader("App Settings"),
              _buildSettingItem(
                icon: Icons.palette_outlined,
                title: "Appearance",
                subtitle: _getAppearanceName(prefs.themeMode),
                onTap: () => _showAppearanceModal(prefs),
              ),
              _buildSettingItem(
                icon: Icons.language,
                title: "Language",
                subtitle: _getLanguageName(prefs.locale.languageCode),
                onTap: () => _showLanguageModal(prefs),
              ),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: "Help & Support",
                onTap: _launchHelpUrl,
              ),

              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: BrandColors.error,
                  side: const BorderSide(color: BrandColors.error),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Log Out"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppearanceName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return "System Default";
      case ThemeMode.light:
        return "Light";
      case ThemeMode.dark:
        return "Dark";
    }
  }

  String _getLanguageName(String code) {
    const langs = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ar': 'Arabic',
      'ru': 'Russian',
      'pt': 'Portuguese',
      'hi': 'Hindi',
    };
    return langs[code] ?? 'English';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: BrandTypography.h5.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.light,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: BrandColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: BrandTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: BrandTypography.caption)
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.light,
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: BrandColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: BrandTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: BrandColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

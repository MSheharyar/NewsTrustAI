import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _displayName(User? user) {
    final name = (user?.displayName ?? "").trim();
    if (name.isNotEmpty) return name;

    final email = (user?.email ?? "").trim();
    if (email.contains("@")) return email.split("@").first;

    return "User";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = _displayName(user);
    final email = (user?.email ?? "No email").trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.withOpacity(0.12),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                    ),
                    child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ProfileOption(icon: LucideIcons.settings, title: "Settings", onTap: () {}),
                  _ProfileOption(icon: LucideIcons.bell, title: "Notifications", onTap: () {}),
                  _ProfileOption(icon: LucideIcons.shield, title: "Privacy & Security", onTap: () {}),
                  _ProfileOption(icon: LucideIcons.helpCircle, title: "Help & Support", onTap: () {}),
                  const SizedBox(height: 20),

                  // Logout
                  _ProfileOption(
                    icon: LucideIcons.logOut,
                    title: "Log Out",
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text("App Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (iconColor ?? Colors.blue).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor ?? Colors.black87)),
        trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
      ),
    );
  }
}
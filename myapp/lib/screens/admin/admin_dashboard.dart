import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final int userId;

  const AdminDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        title: Text("Admin Paneli  — ID: $userId"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Yönetim Menüsü",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- MENÜ KUTULARI ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _menuCard(
                    context,
                    icon: Icons.people,
                    title: "Müşteri Listesi",
                    onTap: () {
                      Navigator.pushNamed(context, "/admin_user_detail");
                    },
                  ),

                  _menuCard(
                    context,
                    icon: Icons.insights,
                    title: "Tahmin Ekranı",
                    onTap: () {
                      Navigator.pushNamed(context, "/admin_prediction");
                    },
                  ),

                  _menuCard(
                    context,
                    icon: Icons.history,
                    title: "Log Kayıtları",
                    onTap: () {
                      Navigator.pushNamed(context, "/admin_logs");
                    },
                  ),

                  _menuCard(
                    context,
                    icon: Icons.settings,
                    title: "Sistem Ayarları",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

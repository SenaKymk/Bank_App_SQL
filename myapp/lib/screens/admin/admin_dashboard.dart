import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final int userId;

  const AdminDashboard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6fb),
      appBar: AppBar(
        title: const Text("Admin Paneli"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff2196F3), Color(0xff21CBF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Çıkış Yap",
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.grid_view, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Yönetim Menüsü",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // 🔥 OVERFLOW FIX
                children: [
                  _menuCard(
                    context,
                    icon: Icons.people,
                    title: "Müşteri\nListesi",
                    onTap: () =>
                        Navigator.pushNamed(context, "/admin_user_detail"),
                  ),
                  _menuCard(
                    context,
                    icon: Icons.insights,
                    title: "Tahmin\nEkranı",
                    onTap: () =>
                        Navigator.pushNamed(context, "/admin_prediction"),
                  ),
                  _menuCard(
                    context,
                    icon: Icons.history,
                    title: "Log\nKayıtları",
                    onTap: () => Navigator.pushNamed(context, "/admin_logs"),
                  ),
                  _menuCard(
                    context,
                    icon: Icons.settings,
                    title: "Sistem\nAyarları",
                    onTap: () => Navigator.pushNamed(context, "/admin_system"),
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
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xfff7fbff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 🔥 FIX
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffe3f2fd),
              ),
              child: Icon(icon, size: 42, color: Colors.blueAccent),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }
}

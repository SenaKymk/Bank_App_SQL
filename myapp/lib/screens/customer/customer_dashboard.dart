import 'package:flutter/material.dart';
import 'customer_profile.dart';
import 'customer_monthly_usage.dart';
import 'customer_trend.dart';

class CustomerDashboard extends StatelessWidget {
  final int userId;
  final String username;

  const CustomerDashboard({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hoşgeldin, $username"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DashboardButton(
              title: "Profil Bilgilerim",
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerProfileScreen(userId: userId),
                  ),
                );
              },
            ),

            DashboardButton(
              title: "Aylık İşlem Özeti",
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerMonthlyUsage(userId: userId),
                  ),
                );
              },
            ),

            DashboardButton(
              title: "Trend Analizi",
              icon: Icons.timeline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerTrendScreen(userId: userId),
                  ),
                );
              },
            ),

            DashboardButton(
              title: "Churn Tahmini (Risk Analizi)",
              icon: Icons.warning_amber,
              onTap: () {
                // Prediction ekranını admin folder’dan alacağız
                Navigator.pushNamed(context, "/prediction");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.deepPurple),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

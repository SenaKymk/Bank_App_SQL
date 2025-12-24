import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_logs.dart'; // BUNU EKLE
import 'screens/admin/admin_dashboard.dart'; // Eğer kullanıyorsan bunu da ekle
import 'screens/admin/admin_user_detail.dart'; // bunu oluşturacağız
import 'screens/admin/prediction_screen.dart';
import 'screens/admin/admin_system_screen.dart'; // BUNU EKLE

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bank Account",
      theme: ThemeData(primarySwatch: Colors.blue),

      routes: {
        "/admin_logs": (context) => const AdminLogsScreen(),
        "/admin_user_detail": (context) => const AdminUserDetailScreen(),
        "/admin_prediction": (context) => const AdminPredictionScreen(),
        "/admin_system": (context) => const AdminSystemSettingsScreen(),
      },

      home: const LoginScreen(),
    );
  }
}

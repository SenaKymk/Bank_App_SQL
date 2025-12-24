import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin/admin_dashboard.dart';
import 'customer/customer_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final userId = userIdController.text.trim();
    final password = passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.login(userId, password);
      final status = response['status'];

      if (status == 'success') {
        final role = response['role'];
        final int id = response['user_id'];
        final String username = response['username'];

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminDashboard(userId: id)),
          );
        } else if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerDashboard(userId: id, username: username),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Bilinmeyen rol tipi")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hatalı kullanıcı ID veya şifre')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Churn Predictor',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: userIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı ID',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 25),

                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Giriş Yap'),
                      ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Hesabın yok mu? Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

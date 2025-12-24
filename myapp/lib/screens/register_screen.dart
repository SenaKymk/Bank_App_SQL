import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final jobController = TextEditingController();
  final provinceController = TextEditingController();
  final religionController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  String? gender;

  bool isLoading = false;

  void registerUser() async {
    if (nameController.text.isEmpty ||
        surnameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm zorunlu alanları doldurun.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final fullName =
        "${nameController.text.trim()} ${surnameController.text.trim()}";

    final response = await ApiService.register({
      "username": fullName,
      "password": passwordController.text.trim(),
      "gender": gender!,
      "age": ageController.text.trim(),
      "province": provinceController.text.trim(),
      "religion": religionController.text.trim(),
      "work_type": jobController.text.trim(),
      "work_sector": "general",
    });

    setState(() => isLoading = false);

    if (response != null && response["status"] == "success") {
      final userId = response["user_id"];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Kayıt Başarılı 🎉"),
          content: Text(
            "Kaydınız oluşturuldu.\n\n"
            "Müşteri ID'niz:\n\n$userId\n\n"
            "Lütfen giriş yaparken bu ID’yi kullanın.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // register ekranı
              },
              child: const Text("Tamam"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarısız, tekrar deneyin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Ad"),
            ),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: "Soyad"),
            ),

            TextField(
              controller: jobController,
              decoration: const InputDecoration(labelText: "Meslek"),
            ),

            DropdownButtonFormField(
              value: gender,
              hint: const Text("Cinsiyet"),
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Erkek")),
                DropdownMenuItem(value: "Female", child: Text("Kadın")),
              ],
              onChanged: (val) => setState(() => gender = val),
            ),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Yaş"),
            ),

            TextField(
              controller: provinceController,
              decoration: const InputDecoration(labelText: "Şehir"),
            ),

            TextField(
              controller: religionController,
              decoration: const InputDecoration(labelText: "Din"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Şifre"),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: registerUser,
                    child: const Text("Kayıt Ol"),
                  ),
          ],
        ),
      ),
    );
  }
}

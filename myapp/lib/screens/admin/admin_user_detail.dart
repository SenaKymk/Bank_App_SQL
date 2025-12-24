import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({super.key});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  bool isLoading = true;
  bool profileLoading = false;

  List customers = []; // → Dropdown için müşteri listesi
  Map<String, dynamic>? profileData; // → Seçilen müşterinin profil bilgisi
  int? selectedUserId; // → Admin'in seçtiği kullanıcı

  @override
  void initState() {
    super.initState();
    fetchCustomerList();
  }

  /// ------------------ MÜŞTERİ LİSTESİ GETİR ------------------
  Future<void> fetchCustomerList() async {
    final url = Uri.parse("http://10.0.2.2:8000/api/admin/customers/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        customers = json.decode(response.body);
        isLoading = false;
      });
    }
  }

  /// ------------------ PROFİL BİLGİLERİ GETİR ------------------
  Future<void> fetchProfile(int userId) async {
    setState(() => profileLoading = true);

    final url = Uri.parse("http://10.0.2.2:8000/api/customer_profile/$userId/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        profileData = json.decode(response.body);
        profileLoading = false;
      });
    } else {
      setState(() {
        profileData = null;
        profileLoading = false;
      });
    }
  }

  /// ------------------ PROFİL GÜNCELLE ------------------
  Future<void> updateProfile(int userId, Map<String, dynamic> data) async {
    final url = Uri.parse(
      "http://10.0.2.2:8000/api/customer_profile/$userId/update/",
    );
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil başarıyla güncellendi")),
      );
      fetchProfile(userId); // → Güncel bilgileri tekrar çek
    }
  }

  /// ------------------ PROFİL SİL ------------------
  Future<void> deleteCustomer(int userId) async {
    final url = Uri.parse("http://10.0.2.2:8000/api/admin/delete/$userId/");

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Müşteri başarıyla silindi")),
      );

      Navigator.pop(context); // geri dön (admin dashboard’a)
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Silme işlemi başarısız!")));
    }
  }

  void confirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Müşteriyi Sil"),
        content: const Text(
          "Bu müşteriyi kalıcı olarak silmek istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteCustomer(selectedUserId!);
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ------------------ PROFİL DÜZENLEME POPUP ------------------
  void showEditDialog() {
    final genderController = TextEditingController(
      text: profileData?["gender"] ?? "",
    );
    final provinceController = TextEditingController(
      text: profileData?["province"] ?? "",
    );
    final workTypeController = TextEditingController(
      text: profileData?["work_type"] ?? "",
    );
    final workSectorController = TextEditingController(
      text: profileData?["work_sector"] ?? "",
    );
    final tenureController = TextEditingController(
      text: profileData?["tenure"]?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Müşteri Bilgilerini Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _editField("Cinsiyet", genderController),
                _editField("İl", provinceController),
                _editField("Çalışma Tipi", workTypeController),
                _editField("Sektör", workSectorController),
                _editField("Kıdem ", tenureController),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Kaydet"),
              onPressed: () {
                updateProfile(selectedUserId!, {
                  "gender": genderController.text,
                  "province": provinceController.text,
                  "work_type": workTypeController.text,
                  "work_sector": workSectorController.text,
                  "tenure": int.tryParse(tenureController.text) ?? 0,
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  /// ------------------ PROFİL KARTI ------------------
  Widget _profileCard() {
    if (profileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileData == null) {
      return const Center(child: Text("Bu müşteriye ait profil bulunamadı."));
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoRow("Cinsiyet", profileData!["gender"]),
            _infoRow("Yaş", profileData!["age"].toString()),
            _infoRow("İl", profileData!["province"]),
            _infoRow("Din", profileData!["religion"]),
            _infoRow("Çalışma Tipi", profileData!["work_type"]),
            _infoRow("Sektör", profileData!["work_sector"]),
            _infoRow("Kıdem", "${profileData!["tenure"]} "),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: showEditDialog,
              icon: const Icon(Icons.edit),
              label: const Text("Düzenle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 63, 160, 224),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () => confirmDeleteDialog(),
              icon: const Icon(Icons.delete),
              label: const Text("Sil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 243, 102, 92),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  /// ------------------ EKRAN ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müşteri Detayları "),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff2196F3), // mavi
                Color(0xff21CBF3), // açık mavi
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: "Müşteri Seç",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedUserId,
                    items: customers.map<DropdownMenuItem<int>>((c) {
                      return DropdownMenuItem<int>(
                        value: c["user_id"] as int,
                        child: Text("${c["username"]} (ID: ${c["user_id"]})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedUserId = value);
                      fetchProfile(value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _profileCard()),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CustomerProfileScreen extends StatefulWidget {
  final int userId;

  const CustomerProfileScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;
  bool editing = false;

  final TextEditingController genderCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();
  final TextEditingController religionCtrl = TextEditingController();
  final TextEditingController workTypeCtrl = TextEditingController();
  final TextEditingController workSectorCtrl = TextEditingController();
  final TextEditingController tenureCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    profile = await ApiService.getCustomerProfile(widget.userId);

    genderCtrl.text = profile!["gender"] ?? "";
    ageCtrl.text = profile!["age"].toString();
    provinceCtrl.text = profile!["province"] ?? "";
    religionCtrl.text = profile!["religion"] ?? "";
    workTypeCtrl.text = profile!["work_type"] ?? "";
    workSectorCtrl.text = profile!["work_sector"] ?? "";
    tenureCtrl.text = profile!["tenure"].toString();

    setState(() => loading = false);
  }

  Future<void> saveProfile() async {
    final updated = {
      "gender": genderCtrl.text,
      "age": int.tryParse(ageCtrl.text) ?? 0,
      "province": provinceCtrl.text,
      "religion": religionCtrl.text,
      "work_type": workTypeCtrl.text,
      "work_sector": workSectorCtrl.text,
      "tenure": int.tryParse(tenureCtrl.text) ?? 0,
    };

    bool success = await ApiService.updateCustomerProfile(
      widget.userId,
      updated,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profil güncellendi")));
      setState(() => editing = false);
    }
  }

  Widget buildField(
    String label,
    TextEditingController ctrl, {
    bool number = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: ctrl,
        enabled: editing,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: editing ? const Icon(Icons.edit) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔷 GRADYAN HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 60,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff6A11CB), Color(0xff2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Profilim",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          editing ? Icons.check_circle : Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (editing) {
                            saveProfile();
                          } else {
                            setState(() => editing = true);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 🔷 FORM ALANI
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        buildField("Cinsiyet", genderCtrl),
                        buildField("Yaş", ageCtrl, number: true),
                        buildField("Şehir", provinceCtrl),
                        buildField("Din", religionCtrl),
                        buildField("Meslek Türü", workTypeCtrl),
                        buildField("Meslek Sektörü", workSectorCtrl),
                        buildField(
                          "Bankada Kalma Süresi (Tenure)",
                          tenureCtrl,
                          number: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

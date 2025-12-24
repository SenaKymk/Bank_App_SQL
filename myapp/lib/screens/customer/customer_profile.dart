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

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profil güncellendi")));

      setState(() {
        editing = false;
      });
    }
  }

  Widget buildField(
    String label,
    TextEditingController ctrl, {
    bool number = false,
  }) {
    return TextField(
      controller: ctrl,
      enabled: editing,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: editing ? Icon(Icons.edit) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profilim"),
        actions: [
          IconButton(
            icon: Icon(editing ? Icons.check : Icons.edit),
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

      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: ListView(
                children: [
                  buildField("Cinsiyet", genderCtrl),
                  SizedBox(height: 15),
                  buildField("Yaş", ageCtrl, number: true),
                  SizedBox(height: 15),
                  buildField("Şehir", provinceCtrl),
                  SizedBox(height: 15),
                  buildField("Din", religionCtrl),
                  SizedBox(height: 15),
                  buildField("Meslek Türü", workTypeCtrl),
                  SizedBox(height: 15),
                  buildField("Meslek Sektörü", workSectorCtrl),
                  SizedBox(height: 15),
                  buildField(
                    "Bankada Kalma Süresi (Tenure)",
                    tenureCtrl,
                    number: true,
                  ),
                ],
              ),
            ),
    );
  }
}

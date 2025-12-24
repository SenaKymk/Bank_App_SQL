import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminSystemSettingsScreen extends StatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  State<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState extends State<AdminSystemSettingsScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  // 🔽 LİSTE STATE
  List customers = [];
  bool listLoading = false;
  String selectedType = "";

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final res = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/admin/system-stats/"),
    );

    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        loading = false;
      });
    }
  }

  Future<void> fetchCustomerList(String type) async {
    setState(() {
      selectedType = type;
      listLoading = true;
    });

    final res = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/admin/system-customers/?type=$type"),
    );

    if (res.statusCode == 200) {
      final List jsonData = json.decode(res.body);
      setState(() {
        customers = jsonData;
        listLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        title: const Text("Sistem Ayarları"),
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
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _summaryGrid(),
                  const SizedBox(height: 24),
                  _churnPieChart(),
                  _customerListSection(),
                ],
              ),
            ),
    );
  }

  // 🔹 ÜST KARTLAR
  Widget _summaryGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _infoCard(
          "Toplam Müşteri",
          data!["total_customers"],
          Colors.blue,
          () => fetchCustomerList("all"),
        ),
        _infoCard(
          "Churn Eden",
          data!["churn_yes"],
          Colors.red,
          () => fetchCustomerList("churned"),
        ),
        _infoCard(
          "Aktif Müşteri",
          data!["churn_no"],
          Colors.green,
          () => fetchCustomerList("active"),
        ),
        _infoCard(
          "Yüksek Risk",
          data!["high_risk"],
          Colors.orange,
          () => fetchCustomerList("high"),
        ),
      ],
    );
  }

  Widget _infoCard(String title, int value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // 🥧 PIE CHART
  Widget _churnPieChart() {
    final churnYes = data!["churn_yes"];
    final churnNo = data!["churn_no"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Text(
            "Churn Dağılımı",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: churnYes.toDouble(),
                    color: Colors.redAccent,
                    title: "Churn\n$churnYes",
                    radius: 70,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: churnNo.toDouble(),
                    color: Colors.green,
                    title: "Aktif\n$churnNo",
                    radius: 70,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📋 ALT LİSTE
  Widget _customerListSection() {
    if (selectedType.isEmpty) return const SizedBox();

    if (listLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Müşteri Listesi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...customers.map(
            (c) => ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: Text(c["name"]),
              subtitle: Text("ID: ${c["id"]}"),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  bool loading = true;
  String? errorMsg;
  List logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      final data = await ApiService.getAdminLogs();
      setState(() {
        logs = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        title: const Text("Admin Log Kayıtları"),
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
          : errorMsg != null
          ? Center(child: Text(errorMsg!))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (_, index) => _buildLogCard(logs[index]),
            ),
    );
  }

  Widget _buildLogCard(dynamic log) {
    final meta = _actionMeta(log["action"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: meta["color"],
          child: Icon(meta["icon"], color: Colors.white),
        ),
        title: Text(
          meta["label"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log["description"] ?? "-"),
              const SizedBox(height: 6),
              Text(
                log["created_at"] ?? "",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDetail(log),
      ),
    );
  }

  void _showDetail(dynamic log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Log Detayı",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _detailRow("Action", log["action"]),
            _detailRow("Admin ID", log["admin_user_id"]),
            _detailRow("Tablo", log["table_name"]),
            _detailRow("Row PK", log["row_pk"]),
            const SizedBox(height: 12),
            const Text(
              "Açıklama",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(log["description"] ?? "-"),
            const SizedBox(height: 12),
            Text(
              "Tarih: ${log["created_at"]}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$label: $value", style: const TextStyle(fontSize: 14)),
    );
  }

  Map<String, dynamic> _actionMeta(String action) {
    switch (action) {
      case "REGISTER_NEW_USER":
        return {
          "icon": Icons.person_add,
          "color": Colors.green,
          "label": "Yeni Üye Kaydı",
        };

      case "LOGIN":
        return {
          "icon": Icons.login,
          "color": Colors.blue,
          "label": "Admin Girişi",
        };

      case "VIEW_CUSTOMER":
        return {
          "icon": Icons.visibility,
          "color": Colors.orange,
          "label": "Müşteri Görüntülendi",
        };

      case "PREDICT_CHURN":
        return {
          "icon": Icons.trending_up,
          "color": Colors.purple,
          "label": "Churn Tahmini",
        };

      default:
        return {
          "icon": Icons.info_outline,
          "color": Colors.grey,
          "label": action,
        };
    }
  }
}

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
      appBar: AppBar(
        title: const Text("Admin Log Kayıtları"),
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(child: Text(errorMsg!))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              itemBuilder: (_, index) => _buildLogCard(logs[index]),
            ),
    );
  }

  Widget _buildLogCard(dynamic log) {
    final meta = _actionMeta(log["action"]);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: meta["color"],
          child: Icon(meta["icon"], color: Colors.white),
        ),
        title: Text(
          meta["label"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log["description"] ?? "-"),
            const SizedBox(height: 4),
            Text(
              log["created_at"] ?? "",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showDetail(log),
      ),
    );
  }

  void _showDetail(dynamic log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Action: ${log["action"]}"),
            Text("Admin ID: ${log["admin_user_id"]}"),
            Text("Table: ${log["table_name"]}"),
            Text("Row PK: ${log["row_pk"]}"),
            const SizedBox(height: 8),
            Text("Description:\n${log["description"]}"),
            const SizedBox(height: 8),
            Text("Tarih: ${log["created_at"]}"),
          ],
        ),
      ),
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
        return {"icon": Icons.info, "color": Colors.grey, "label": action};
    }
  }
}

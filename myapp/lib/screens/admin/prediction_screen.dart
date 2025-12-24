import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPredictionScreen extends StatefulWidget {
  const AdminPredictionScreen({super.key});

  @override
  State<AdminPredictionScreen> createState() => _AdminPredictionScreenState();
}

class _AdminPredictionScreenState extends State<AdminPredictionScreen> {
  final TextEditingController userIdController = TextEditingController();

  bool isLoading = false;
  double? churnPct; // ARTIK % CİNSİNDEN
  String? risk;
  int? label;
  String? refDate;

  Future<void> predictChurn() async {
    final idText = userIdController.text.trim();
    if (idText.isEmpty) return;

    final int userId = int.parse(idText);

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.0.2.2:8000/api/admin/predict/$userId/");

    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        churnPct = (data["churn_probability"] as num).toDouble(); // % zaten
        risk = data["risk"];
        label = data["label"];
        refDate = data["ref_date"];
        isLoading = false;
      });
    } else {
      setState(() {
        churnPct = null;
        risk = null;
        label = null;
        refDate = null;
        isLoading = false;
      });
    }
  }

  Color riskColor() {
    switch (risk) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData riskIcon() {
    switch (risk) {
      case "HIGH":
        return Icons.warning_amber_rounded;
      case "MEDIUM":
        return Icons.error_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  String riskText() {
    switch (risk) {
      case "HIGH":
        return "Yüksek Churn Riski";
      case "MEDIUM":
        return "Orta Seviye Churn Riski";
      default:
        return "Düşük Churn Riski";
    }
  }

  Widget resultCard() {
    if (churnPct == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(riskIcon(), color: riskColor(), size: 48),
            const SizedBox(height: 12),
            Text(
              "%${churnPct!.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: riskColor(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              riskText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: riskColor(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Ref Date: $refDate",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Churn Tahmini (Admin)"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Müşteri ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: isLoading ? null : predictChurn,
              icon: const Icon(Icons.analytics),
              label: const Text("Tahmin Yap"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            resultCard(),
          ],
        ),
      ),
    );
  }
}

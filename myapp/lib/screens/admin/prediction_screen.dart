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
  double? churnPct;
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
        churnPct = (data["churn_probability"] as num).toDouble();
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
        return Colors.redAccent;
      case "MEDIUM":
        return Colors.orangeAccent;
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

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: riskColor().withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(riskIcon(), color: riskColor(), size: 52),
          const SizedBox(height: 14),
          Text(
            "%${churnPct!.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 30,
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
          const SizedBox(height: 12),
          Text(
            "Referans Tarihi: $refDate",
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        title: const Text("Churn Tahmini (Admin)"),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 INPUT + BUTON KARTI
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
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
                  const SizedBox(height: 16),

                  // 🔥 GRADYAN BUTON
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff2196F3), Color(0xff21CBF3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : predictChurn,
                          icon: const Icon(
                            Icons.psychology,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "Tahmin Yap",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),

            resultCard(),
          ],
        ),
      ),
    );
  }
}

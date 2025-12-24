import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerTrendScreen extends StatefulWidget {
  final int userId;
  const CustomerTrendScreen({super.key, required this.userId});

  @override
  State<CustomerTrendScreen> createState() => _CustomerTrendScreenState();
}

class _CustomerTrendScreenState extends State<CustomerTrendScreen> {
  bool loading = true;
  String? error;

  Map<String, dynamic> summary = {};
  List<Map<String, dynamic>> monthly = [];

  double d(v) =>
      v == null ? 0 : (v is int ? v.toDouble() : (v as num).toDouble());
  int i(v) => v == null ? 0 : (v is double ? v.toInt() : v as int);

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      final res1 = await http.get(
        Uri.parse("http://10.0.2.2:8000/api/customer_trend/${widget.userId}/"),
      );
      final res2 = await http.get(
        Uri.parse(
          "http://10.0.2.2:8000/api/customer_monthly_timeseries/${widget.userId}/",
        ),
      );

      if (res1.statusCode != 200 || res2.statusCode != 200) {
        throw "Veri alınamadı";
      }

      summary = json.decode(res1.body);
      monthly = List<Map<String, dynamic>>.from(json.decode(res2.body));

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryText(),
                        const SizedBox(height: 20),
                        _trendCards(),
                        const SizedBox(height: 30),
                        _ratioChart(),
                        const SizedBox(height: 30),
                        _monthlyChart(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff6A11CB), Color(0xff2575FC)],
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
          const Text(
            "Trend Analizi",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TEXT SUMMARY ----------------

  Widget _summaryText() {
    final months = i(summary["months_since_last_txn"]);
    final products = i(summary["active_product_category_nbr_last"]);
    final ratio = d(summary["mobile_to_card_ratio_amt"]) * 100;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Özet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("• Son işlemden bu yana $months ay geçti."),
            Text("• Aktif ürün sayısı: $products"),
            Text("• İşlemlerin %${ratio.toStringAsFixed(1)}’i EFT üzerinden."),
          ],
        ),
      ),
    );
  }

  // ---------------- TREND CARDS ----------------

  Widget _trendCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Trend Değişimi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _trendCard("EFT (1 Ay)", d(summary["mobile_eft_all_cnt_trend"])),
            _trendCard(
              "Kart (1 Ay)",
              d(summary["cc_transaction_all_cnt_trend"]),
            ),
            _trendCard("EFT (3 Ay)", d(summary["mobile_eft_all_cnt_trend_3m"])),
            _trendCard(
              "Kart (3 Ay)",
              d(summary["cc_transaction_all_cnt_trend_3m"]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _trendCard(String title, double v) {
    final up = v > 0;
    final icon = up ? Icons.trending_up : Icons.trending_down;
    final color = up ? Colors.green : Colors.red;
    final text = v == 0
        ? "Sabit"
        : up
        ? "Artış Eğiliminde"
        : "Azalış Eğiliminde";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(text, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  // ---------------- PIE CHART ----------------

  Widget _ratioChart() {
    final eft = d(summary["mobile_to_card_ratio_amt"]).clamp(0, 1);
    final card = 1 - eft;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "EFT / Kart Oranı",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: eft * 100,
                      color: Colors.blue,
                      title: "EFT\n${(eft * 100).toStringAsFixed(1)}%",
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: card * 100,
                      color: Colors.orange,
                      title: "Kart\n${(card * 100).toStringAsFixed(1)}%",
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
      ),
    );
  }

  // ---------------- MONTHLY LINE CHART ----------------

  Widget _monthlyChart() {
    if (monthly.isEmpty) {
      return const Text("Aylık veri yok");
    }

    final eft = <FlSpot>[];
    final card = <FlSpot>[];

    for (int i = 0; i < monthly.length; i++) {
      eft.add(FlSpot(i.toDouble(), d(monthly[i]["eft_cnt"])));
      card.add(FlSpot(i.toDouble(), d(monthly[i]["card_cnt"])));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aylık İşlem Sayıları (EFT vs Kart)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: eft,
                      color: Colors.blue,
                      isCurved: true,
                      barWidth: 3,
                    ),
                    LineChartBarData(
                      spots: card,
                      color: Colors.red,
                      isCurved: true,
                      barWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

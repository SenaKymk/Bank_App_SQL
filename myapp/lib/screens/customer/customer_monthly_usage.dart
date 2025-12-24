import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';

class CustomerMonthlyUsage extends StatefulWidget {
  final int userId;

  const CustomerMonthlyUsage({Key? key, required this.userId})
    : super(key: key);

  @override
  State<CustomerMonthlyUsage> createState() => _CustomerMonthlyUsageState();
}

class _CustomerMonthlyUsageState extends State<CustomerMonthlyUsage> {
  List<String> months = [];
  String? selectedMonth;
  Map<String, dynamic>? usage;
  bool loading = true;

  double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    loadMonths();
  }

  Future<void> loadMonths() async {
    months = await ApiService.getAvailableMonths(widget.userId);

    setState(() {
      selectedMonth = months.isNotEmpty ? months.last : null;
    });

    if (selectedMonth != null) loadUsage();
  }

  Future<void> loadUsage() async {
    if (selectedMonth == null) return;

    setState(() => loading = true);
    usage = await ApiService.getMonthlyUsage(widget.userId, selectedMonth!);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aylık İşlem Özeti")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ------------------ AY SEÇİCİ --------------------
                    DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() => selectedMonth = value);
                        loadUsage();
                      },
                      items: months.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m, style: const TextStyle(fontSize: 18)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ------------------ GRAFİK 1 --------------------
                    const Text(
                      "İşlem Sayıları (adet)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: 220, child: LineChart(_countChart())),

                    const SizedBox(height: 30),

                    // ------------------ GRAFİK 2 --------------------
                    const Text(
                      "İşlem Tutarları (TL)",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: 220, child: BarChart(_amountChart())),

                    const SizedBox(height: 30),

                    // ------------------ ÖZET BİLGİ --------------------
                    _infoCard(
                      "Aktif Ürün Sayısı",
                      usage?["active_product_category_nbr"]?.toString() ?? "0",
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ----------------------- CHART 1 -----------------------
  LineChartData _countChart() {
    final eftCnt = _safeDouble(usage?["total_mobile_eft_cnt"]);
    final ccCnt = _safeDouble(usage?["total_cc_cnt"]);

    return LineChartData(
      minX: 0,
      maxX: 1,
      minY: 0,
      maxY: (eftCnt > ccCnt ? eftCnt : ccCnt) + 10,
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          spots: [FlSpot(0, eftCnt), FlSpot(1, ccCnt)],
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _bottomTitlesCount,
          ),
        ),
      ),
    );
  }

  Widget _bottomTitlesCount(double value, TitleMeta meta) {
    switch (value.toInt()) {
      case 0:
        return const Text("EFT");
      case 1:
        return const Text("Kart");
      default:
        return const Text("");
    }
  }

  // ----------------------- CHART 2 -----------------------
  BarChartData _amountChart() {
    final eftAmt = _safeDouble(usage?["total_mobile_eft_amt"]);
    final ccAmt = _safeDouble(usage?["total_cc_amt"]);

    final maxY = (eftAmt > ccAmt ? eftAmt : ccAmt) * 1.3 + 10;

    return BarChartData(
      maxY: maxY,
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(toY: eftAmt, color: Colors.green, width: 22),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(toY: ccAmt, color: Colors.orange, width: 22),
          ],
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) => Text(value == 0 ? "EFT" : "Kart"),
          ),
        ),
      ),
    );
  }

  // ----------------------- INFO CARD -----------------------
  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

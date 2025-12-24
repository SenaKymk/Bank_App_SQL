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
      backgroundColor: const Color.fromARGB(255, 248, 244, 251),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔮 MOR GRADYAN HEADER (PROFİL EKRANI İLE AYNI)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 56,
                    left: 10,
                    right: 16,
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
                          "Aylık İşlem Özeti",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 📄 SAYFA İÇERİĞİ
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔽 AY SEÇİCİ
                        DropdownButtonFormField<String>(
                          value: selectedMonth,
                          decoration: const InputDecoration(
                            labelText: "Ay Seç",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() => selectedMonth = value);
                            loadUsage();
                          },
                          items: months
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                        ),

                        const SizedBox(height: 24),

                        // 📝 YAZILI ÖZET
                        _textSummary(),

                        const SizedBox(height: 30),

                        // 📊 GRAFİK 1
                        const Text(
                          "İşlem Sayıları Karşılaştırması",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        SizedBox(height: 220, child: BarChart(_countChart())),

                        const SizedBox(height: 30),

                        // 📊 GRAFİK 2
                        const Text(
                          "İşlem Tutarları Karşılaştırması (TL)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(height: 220, child: BarChart(_amountChart())),

                        const SizedBox(height: 30),

                        // ℹ️ EK BİLGİ
                        _infoCard(
                          "Aktif Ürün Sayısı",
                          usage?["active_product_category_nbr"]?.toString() ??
                              "0",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // 📝 METİNSEL ÖZET
  Widget _textSummary() {
    final eftCnt = _safeDouble(usage?["total_mobile_eft_cnt"]).toInt();
    final ccCnt = _safeDouble(usage?["total_cc_cnt"]).toInt();
    final eftAmt = _safeDouble(usage?["total_mobile_eft_amt"]);
    final ccAmt = _safeDouble(usage?["total_cc_amt"]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$selectedMonth Ayı İşlem Özeti",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("• EFT İşlem Sayısı: $eftCnt adet"),
          Text("• Kart İşlem Sayısı: $ccCnt adet"),
          const SizedBox(height: 6),
          Text("• EFT Toplam Tutarı: ${eftAmt.toStringAsFixed(2)} TL"),
          Text("• Kart Toplam Tutarı: ${ccAmt.toStringAsFixed(2)} TL"),
        ],
      ),
    );
  }

  // 📊 BAR CHART – İŞLEM SAYILARI
  BarChartData _countChart() {
    final eftCnt = _safeDouble(usage?["total_mobile_eft_cnt"]);
    final ccCnt = _safeDouble(usage?["total_cc_cnt"]);
    final maxY = (eftCnt > ccCnt ? eftCnt : ccCnt) + 5;

    return BarChartData(
      maxY: maxY,
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: eftCnt,
              color: const Color.fromARGB(255, 79, 212, 221),
              width: 26,
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: ccCnt,
              color: const Color.fromARGB(255, 144, 45, 224),
              width: 26,
            ),
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

  // 📊 BAR CHART – İŞLEM TUTARLARI
  BarChartData _amountChart() {
    final eftAmt = _safeDouble(usage?["total_mobile_eft_amt"]);
    final ccAmt = _safeDouble(usage?["total_cc_amt"]);
    final maxY = (eftAmt > ccAmt ? eftAmt : ccAmt) * 1.2 + 10;

    return BarChartData(
      maxY: maxY,
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: eftAmt,
              color: const Color.fromARGB(255, 79, 212, 221),
              width: 26,
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: ccAmt,
              color: const Color.fromARGB(255, 144, 45, 224),
              width: 26,
            ),
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

  // ℹ️ INFO CARD
  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

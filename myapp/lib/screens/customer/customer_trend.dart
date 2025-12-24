import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// CustomerTrendScreen - Müşteri Trend Analizi Ekranı
/// Backend'den iki API çağrısı yapar:
/// 1. /api/customer_trend/<user_id>/ - Özet değerler
/// 2. /api/customer_monthly_timeseries/<user_id>/ - Aylık zaman serisi verisi
class CustomerTrendScreen extends StatefulWidget {
  final int userId;

  const CustomerTrendScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CustomerTrendScreen> createState() => _CustomerTrendScreenState();
}

class _CustomerTrendScreenState extends State<CustomerTrendScreen> {
  bool isLoading = true;
  String? errorMessage;

  // API 1: Trend Summary Data
  Map<String, dynamic> trendSummary = {};

  // API 2: Monthly Timeseries Data
  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Güvenli double dönüşümü - null veya geçersiz değerleri 0.0 yapar
  double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Güvenli int dönüşümü
  int safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Her iki API'yi sırayla çağırır
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // API 1: Trend Summary
      await loadTrendSummary();

      // API 2: Monthly Timeseries
      await loadMonthlyTimeseries();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Veri yüklenirken hata oluştu: $e';
      });
    }
  }

  /// Trend özet verisini çeker
  Future<void> loadTrendSummary() async {
    final url = 'http://10.0.2.2:8000/api/customer_trend/<user_id>/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      trendSummary = json.decode(response.body);
    } else {
      throw Exception('Trend verisi alınamadı: ${response.statusCode}');
    }
  }

  /// Aylık zaman serisi verisini çeker
  Future<void> loadMonthlyTimeseries() async {
    final url =
        'http://10.0.2.2:8000/api/customer_monthly_timeseries/${widget.userId}/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      monthlyData = data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Aylık veri alınamadı: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Trend Analizi'), elevation: 0),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCards(),
                  const SizedBox(height: 24),
                  _buildRatioPieChart(),
                  const SizedBox(height: 24),
                  _buildMonthlyLineChart(),
                  const SizedBox(height: 24),
                  _buildTrendSummaryCards(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Bilgi kartları (Ay ve Ürün sayısı)
  Widget _buildInfoCards() {
    final monthsInactive = safeInt(trendSummary['months_inactive']);
    final productLast = safeInt(trendSummary['product_last']);

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Son işlemden bu yana geçen ay',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$monthsInactive',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shopping_bag, color: Colors.green, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Son ürün kullanım sayısı',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$productLast',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// EFT / Kart Oranı - Pie Chart
  Widget _buildRatioPieChart() {
    final ratio = safeDouble(trendSummary['ratio']);
    final eftValue = ratio.clamp(0.0, 1.0);
    final cardValue = 1.0 - eftValue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EFT / Kart Oranı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: eftValue * 100,
                      title: 'EFT\n${(eftValue * 100).toStringAsFixed(1)}%',
                      color: Colors.blue,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: cardValue * 100,
                      title: 'Kart\n${(cardValue * 100).toStringAsFixed(1)}%',
                      color: Colors.red,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Aylık EFT / Kart İşlem Sayıları - Line Chart (GERÇEK VERİ)
  Widget _buildMonthlyLineChart() {
    if (monthlyData.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text('Aylık veri bulunamadı')),
        ),
      );
    }

    // X ekseni için ay etiketleri
    final months = monthlyData.map((e) => e['month'].toString()).toList();

    // EFT ve Kart sayıları
    final eftSpots = <FlSpot>[];
    final cardSpots = <FlSpot>[];

    for (int i = 0; i < monthlyData.length; i++) {
      final eftCount = safeDouble(monthlyData[i]['eft_cnt']);
      final cardCount = safeDouble(monthlyData[i]['card_cnt']);
      eftSpots.add(FlSpot(i.toDouble(), eftCount));
      cardSpots.add(FlSpot(i.toDouble(), cardCount));
    }

    // Y ekseni için maksimum değer
    double maxY = 0;
    for (var spot in [...eftSpots, ...cardSpots]) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY * 1.2; // %20 üst boşluk

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aylık EFT / Kart İşlem Sayıları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 16, height: 3, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('EFT', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 24),
                Container(width: 16, height: 3, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Kart', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            // Sadece bazı ayları göster (çok fazla ay varsa)
                            if (months.length > 12 && index % 2 != 0) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                months[index],
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      left: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                  lineBarsData: [
                    // EFT Line (Mavi)
                    LineChartBarData(
                      spots: eftSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    // Kart Line (Kırmızı)
                    LineChartBarData(
                      spots: cardSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.1),
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

  /// Trend özet kartları (1 aylık ve 3 aylık trendler)
  Widget _buildTrendSummaryCards() {
    final mobileEftTrend = safeInt(trendSummary['mobile_eft_trend']);
    final ccCntTrend = safeInt(trendSummary['cc_cnt_trend']);
    final mobileTrend3m = safeInt(trendSummary['mobile_trend_3m']);
    final ccTrend3m = safeInt(trendSummary['cc_trend_3m']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trend Özeti',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTrendCard(
                'EFT Trendi (1 Ay)',
                mobileEftTrend,
                Colors.blue,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTrendCard(
                'Kart Trendi (1 Ay)',
                ccCntTrend,
                Colors.red,
                Icons.credit_card,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTrendCard(
                'EFT Trendi (3 Ay)',
                mobileTrend3m,
                Colors.green,
                Icons.show_chart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTrendCard(
                'Kart Trendi (3 Ay)',
                ccTrend3m,
                Colors.orange,
                Icons.analytics,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tek bir trend kartı oluşturur
  Widget _buildTrendCard(String title, int value, Color color, IconData icon) {
    final isPositive = value >= 0;
    final trendIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(trendIcon, color: trendColor, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

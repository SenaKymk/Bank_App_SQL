import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CustomerCampaignsScreen extends StatefulWidget {
  final int userId;
  const CustomerCampaignsScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<CustomerCampaignsScreen> createState() =>
      _CustomerCampaignsScreenState();
}

class _CustomerCampaignsScreenState extends State<CustomerCampaignsScreen> {
  int selectedCampaign = 1;
  Map<String, dynamic>? result;
  bool loading = false;

  final campaigns = [
    {
      "id": 1,
      "title": "EFT Şampiyonu",
      "desc": "En yüksek EFT harcaması yapan müşteri",
      "icon": Icons.trending_up,
    },
    {
      "id": 2,
      "title": "Ürün Ustası",
      "desc": "En fazla ürün kategorisi kullanan müşteri",
      "icon": Icons.category,
    },
    {
      "id": 3,
      "title": "En Aktif Müşteri",
      "desc": "En fazla toplam işlem yapan müşteri",
      "icon": Icons.flash_on,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadCampaign();
  }

  Future<void> loadCampaign() async {
    setState(() => loading = true);
    result = await ApiService.getCampaignResult(
      widget.userId,
      selectedCampaign,
    );
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fb),
      body: Column(
        children: [
          // 🔷 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6A11CB), Color(0xff8E2DE2)],
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 5),
                const Icon(Icons.emoji_events, color: Colors.white),
                const SizedBox(width: 5),
                const Text(
                  "Kampanyalar",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔷 KAMPANYA SEÇİCİ
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: campaigns.map((c) {
                final isSelected = selectedCampaign == c["id"];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selectedCampaign = c["id"] as int;
                      loadCampaign();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, color: Colors.black12),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            c["icon"] as IconData,
                            color: isSelected
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c["title"] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔷 DETAY
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _resultSection(),
          ),
        ],
      ),
    );
  }

  Widget _resultSection() {
    if (result == null) return const SizedBox();

    final rank = result!["rank"];
    final total = result!["total"];
    final isWinner = result!["is_winner"];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaigns
                .firstWhere((c) => c["id"] == selectedCampaign)["desc"]
                .toString(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: isWinner
                  ? Column(
                      children: const [
                        Icon(Icons.celebration, color: Colors.green, size: 48),
                        SizedBox(height: 12),
                        Text(
                          "Tebrikler! 🎉\nBu kampanyada 1. oldunuz.\nÖdül kazandınız!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(
                          Icons.bar_chart,
                          color: Colors.orange,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Sıralamanız: $rank / $total",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Bir sonraki kampanyada ödülü kazanmak için\nbiraz daha aktif olabilirsiniz 💪",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  final int adminId;

  const AdminDashboard({super.key, required this.adminId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard (ID: $adminId)")),
      body: const Center(child: Text("Admin Paneli")),
    );
  }
}

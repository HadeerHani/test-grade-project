import 'package:flutter/material.dart';
import 'request_details_screen.dart';
import 'welcome_screen_modified.dart';

class HomeRepairPage extends StatelessWidget {
  const HomeRepairPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'name': 'Electrician', 'icon': Icons.bolt},
      {'name': 'Plumber', 'icon': Icons.water_drop},
      {'name': 'Carpenter', 'icon': Icons.handyman},
      {'name': 'Painter', 'icon': Icons.palette},
      {'name': 'AC & Cooling Repair', 'icon': Icons.ac_unit},
      {'name': 'Appliance Repair', 'icon': Icons.tv},
      {'name': 'Door & Lock Repair', 'icon': Icons.lock_outline},
      {'name': 'Gardening & Lawn Care', 'icon': Icons.yard_outlined},
    ];

    return Scaffold(
      backgroundColor: AppColors.secondaryLightBeige,
      appBar: AppBar(
        title: const Text("Home Repair"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceItem(context, services[index]);
        },
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(service['icon'], color: AppColors.primaryDarkGreen),
        title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDarkGreen)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(serviceName: service['name']),
            ),
          );
        },
      ),
    );
  }
}

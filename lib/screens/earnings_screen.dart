import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'welcome_screen_modified.dart';
import 'user_provider.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.backgroundWhite,
      
      appBar: AppBar(
        title: const Text(
          "Earnings History",
         // style: TextStyle(color: Colors.white),
        ),
      //  backgroundColor: const Color(0xFF1B5E20), // اللون الأخضر بتاعك
       // elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // النص العلوي (Total Earnings)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "You've earned a total of \$${userProvider.totalEarnings.toInt()}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ),

              // قائمة الكروت
              Expanded(
                child: ListView.builder(
                  itemCount: userProvider.earningsHistory.length,
                  itemBuilder: (context, index) {
                    final job = userProvider.earningsHistory[index];
                    return _buildEarningCard(job);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEarningCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        // Color(0xFFF2EFE9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // الأيقونة حسب النوع
          _buildIcon(job['type']),
          const SizedBox(width: 15),

          // النصوص (العنوان واسم العميل)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                Text(
                  "Customer: ${job['customer']}",
                  style: const TextStyle(color: AppColors.textgrey, fontSize: 14),
                ),
              ],
            ),
          ),

          // السعر والتقييم والتاريخ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "+\$${job['amount'].toInt()}",
                style: const TextStyle(
                  color: AppColors.primaryDarkGreen,
                 // color: Color(0xFF689F38),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.button, size: 16),
                  Text(
                    " ${job['rate']}",
                    style: const TextStyle(
                      color: AppColors.textgrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                job['date'] ?? '',
                style: const TextStyle(color: AppColors.textgrey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة بسيطة لاختيار الأيقونة
  Widget _buildIcon(String? type) {
    IconData iconData = Icons.build;
    if (type == 'plumbing') iconData = Icons.opacity;
    if (type == 'electric') iconData = Icons.bolt;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:  AppColors.backgroundWhite,
        //border: Border.all(color: Colors.grey.shade200),
       // borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color:AppColors.button,
      // const Color(0xFF2E4D48),
        size: 28),
    );
  }
}

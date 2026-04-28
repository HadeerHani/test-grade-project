
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_project/screens/request_details_screen.dart';
import 'package:second_project/screens/welcome_screen_modified.dart';
import 'user_provider.dart';

class ActiveRequestPage extends StatelessWidget {
  const ActiveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(title: const Text("Active Requests")),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final requests = userProvider.myRequests;

          if (requests.isEmpty) {
            return const Center(child: Text("No active requests found."));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            // padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) => _buildJobCard(
              job: requests[index],
              index: index,
              userProvider: userProvider,
              context: context
            ),
          );
        },
      ),
    );
  }

  IconData _getServiceIcon(String? type) {
    switch (type) {
      case 'Electrician':
        return Icons.flash_on;
      case 'Plumbing Repair':
        return Icons.water_drop;
      case 'Cleaning':
        return Icons.cleaning_services;
      default:
        return Icons.build;
    }
  }

  Widget _buildJobCard({
    required Map<String, dynamic> job,
    required int index,
    required UserProvider userProvider,
    required BuildContext context,
  }) {
    bool isPending = job['status'] == 'Pending';
    String workerName = isPending
        ? "Awaiting Acceptance"
        : (job['workerName'] ?? "Spencer N.");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Color(0xFFF2EFE9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // السطر الأول: الأيقونة، الاسم، والتقييم، وجنبه (الحالة + السعر)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getServiceIcon(job['serviceType']),
                color: AppColors.primaryDarkGreen,
                size: 25,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['serviceType'] ?? "Service Request",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(width: 6, height: 6),
                    Row(
                      children: [
                        Text(
                          "Worker: $workerName",
                          style: const TextStyle(
                            color: AppColors.textgrey,
                            fontSize: 12,
                          ),
                        ),
                        if (!isPending) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star,
                            color: AppColors.primaryDarkGreen,
                            size: 14,
                          ),
                          Text(
                            " ${job['workerRate'] ?? '4.9'}",
                            style: const TextStyle(
                              color: AppColors.primaryDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // الحتة اللي طلبتيها: السعر جنب الـ Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "${job['status']} - \$${job['price']??'0'}", // السعر مدمج هنا
                  style: TextStyle(
                    color: isPending ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          // const Divider(height: 24),
          // السطر التاني: التاريخ + أيقونات التعديل والحذف
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                job['date'] ?? "Today, 3:00 PM",
                style: const TextStyle(color: AppColors.textgrey, fontSize: 13),
              ),
              const Spacer(),
              // أيقونة التعديل (القلم)
              //const Icon(Icons.edit_note, color: Colors.grey, size: 24),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsScreen(
                        serviceName: job['serviceType'],
                        isEdit: true, // تفعيل وضع التعديل
                        editData: job, // إرسال بيانات الكارد الحالي
                        index: index, // إرسال مكانه في اللستة
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.edit_note,
                  color: AppColors.primaryDarkGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 6),
              // أيقونة الحذف (السلة)
              // السطر رقم 71 اللي فيه المشكلة
              IconButton(
                onPressed: () {
                  // نادي دالة المسح من البروفايدر
                  userProvider.removeRequest(index);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

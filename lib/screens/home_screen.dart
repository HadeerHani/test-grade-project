import 'package:second_project/screens/active_request_page.dart';
import 'package:second_project/screens/cleaning_page.dart';
import 'package:second_project/screens/custom_bottom_nav.dart';
import 'package:second_project/screens/home_repairpage.dart';
import 'package:second_project/screens/moving_page.dart';
import 'package:second_project/screens/other_services_page.dart';
import 'package:second_project/screens/personal_page.dart';
import 'package:second_project/screens/task_details_screen.dart';
import 'package:second_project/screens/services_list_screen.dart';
import 'package:second_project/screens/user_provider.dart';
//import 'package:second_project/screens/vehicle_servicespage.dart';
import 'package:second_project/screens/welcome_screen_modified.dart';

import 'package:flutter/material.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ⭐️ بيانات الـ API (تتغير تلقائياً لاحقاً) ⭐️
  final String userName = "Jane";
  final int activeRequestsCount = 4;
  final String latestRequestTitle = "Unusual Request";
  final String latestRequestStatus = "Accepted";
  final String latestRequestPrice = "100";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,

      appBar: AppBar(
        title: const Text("FIXPAY"),
        actions: [
          Consumer<UserProvider>(
  builder: (context, provider, child) {
    // بنحسب عدد الإشعارات اللي لسه اليوزر مشافهاش
    int unreadCount = provider.notifications.where((n) => n['isRead'] == false).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0), // مسافة بسيطة من الطرف
      child: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(unreadCount.toString(), style: const TextStyle(fontSize: 10)),
        backgroundColor: Colors.red,
        // بنحرك مكان الـ Badge شوية عشان يبقى مظبوط فوق الدايرة
        offset: const Offset(-4, 4), 
        child: GestureDetector(
          onTap: () {
            // لما يضغط يفتح الـ Dialog
            showDialog(
              context: context,
              builder: (context) => _buildNotificationDialog(context),
            );
          },
          child: CircleAvatar(
            radius: 18, // نفس حجم الـ CircleAvatar بتاع البروفايل اللي جنبه
            backgroundColor: AppColors.backgroundWhite, // اللون اللي مستخدمينه في البروفايل
            child: const Icon(
              Icons.notifications_none,
              color:AppColors.primaryDarkGreen,
              size: 20,
            ),
          ),
        ),
      ),
    );
  },
),
          // IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline)),
          // const SizedBox(width: 8),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return GestureDetector(
                onTap: () {
                  // ممكن تفتحي صفحة البروفايل لما يضغط على الصورة
                  Navigator.pushNamed(context, '/account');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor:// Color(0xFFF2EFE9),
                    AppColors.backgroundWhite,
                    // 💡 هنا بنشيك: لو فيه صورة في الـ Provider اعرضيها، لو مفيش اعرضي الأيقونة
                    backgroundImage: userProvider.userImage != null
                        ? FileImage(userProvider.userImage!)
                        : null,
                    child: userProvider.userImage == null
                        ? const Icon(
                            Icons.person,
                            color: AppColors.primaryDarkGreen,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFE9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2B2B),
                          ),
                          children: [
                            const TextSpan(text: "Good morning ☀️ , "),
                            TextSpan(text: userProvider.userName),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    "How can we help you today?",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // 1. العنوان ثابت بره الـ Consumer عشان ميتكررش
            const Text(
              "Active Requests", // شيلنا العداد من هنا عشان هنحطه جوه الكارت زي الفيديو
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B2B),
              ),
            ),
            const SizedBox(height: 12),

            // 2. الـ Consumer بيلف بس على الكارت المتغير
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final requests = userProvider.myRequests;
                //scheduledJobs;

                if (requests.isEmpty) {
                  return const Text("No active requests at the moment.");
                }

                // هنا بننادي الميثود اللي بتعمل الكارت الشيك اللي زي الفيديو
                return _buildActiveRequestsSection(context, requests);
              },
            ),

            const SizedBox(height: 24),
            const Text(
              "Browse Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B2B),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoriesGrid(),

            const SizedBox(height: 24),

            // 4️⃣ قسم المراجعات الأخيرة
            const Text(
              "Your Recent Reviews (2)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2B2B),
              ),
            ),
            const SizedBox(height: 12),
            _buildReviewsCard(context),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      //_buildBottomNav(context),
    );
  }

  // 1. الميثود اللي بتعمل الكارت الكبير (زي الفيديو)
  Widget _buildActiveRequestsSection(
    BuildContext context,
    List<Map<String, dynamic>> requests,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActiveRequestPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF2EFE9),
          // Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الجزء العلوي: الأيقونة والعدد
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primaryDarkGreen,
                  child: Icon(
                    Icons.build,
                    color: AppColors.backgroundWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You have ${requests.length} active requests",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                      const Text(
                        "Tap to view status updates.",
                        style: TextStyle(
                          color: AppColors.textgrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.button,
                  // Colors.grey,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // عرض أول طلبين بشكل Dynamic (حل مشكلة الـ map والـ Error)
            ...requests
                .take(2)
                .map<Widget>((job) => _buildSingleJobRow(job))
                .toList(),

            // عرض زرار "المزيد" لو فيه طلبات كتير
            if (requests.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Text(
                    "+ ${requests.length - 2} more requests",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 2. الميثود اللي بتعمل سطر الطلب الواحد (اللي كانت ناقصة عندك ومسببة ايرور)
  Widget _buildSingleJobRow(Map<String, dynamic> job) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            job['title'] ?? job['serviceType'] ?? "Service Request",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              //const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "${job['status']} - \$${job['price']}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- شبكة التصنيفات ---
  Widget _buildCategoriesGrid() {
    final List<Widget> categoryScreens = [
      // 1. Home Repair
      ServicesListScreen(
        categoryTitle: "Home Repair",
        servicesList: [
          {'name': 'Electrician', 'icon': Icons.bolt},
          {'name': 'Plumber', 'icon': Icons.water_drop},
          {'name': 'Carpenter', 'icon': Icons.handyman},
          {'name': 'Painter', 'icon': Icons.palette},
          {'name': 'AC & Cooling Repair', 'icon': Icons.ac_unit},
          {'name': 'Appliance Repair', 'icon': Icons.tv},
          {'name': 'Door & Lock Repair', 'icon': Icons.lock_outline},
          {'name': 'Gardening & Lawn Care', 'icon': Icons.yard_outlined},
        ],
      ),

      // 2. Cleaning
      ServicesListScreen(
        categoryTitle: "Cleaning",
        servicesList: [
          {'name': 'Home Cleaning', 'icon': Icons.home},
          {'name': 'Office & Commercial Cleaning', 'icon': Icons.business},
          {'name': 'Pest Control', 'icon': Icons.bug_report},
          {'name': 'Disinfection & Sanitation', 'icon': Icons.sanitizer},
        ],
      ),

      // 3. Personal
      ServicesListScreen(
        categoryTitle: "Personal Services",
        servicesList: [
          {'name': 'Barber at Home', 'icon': Icons.content_cut},
          {'name': 'Beauty / Makeup Artist', 'icon': Icons.auto_awesome},
          {'name': 'Tailor / Clothes Repair', 'icon': Icons.checkroom},
          {'name': 'Laundry & Ironing', 'icon': Icons.local_laundry_service},
        ],
      ),

      // 4. Vehicle
      ServicesListScreen(
        categoryTitle: "Vehicle Services",
        servicesList: [
          {'name': 'Car Wash (At Home)', 'icon': Icons.directions_car},
        ],
      ),

      // 5. Moving
      ServicesListScreen(
        categoryTitle: "Moving & Logistics",
        servicesList: [
          {'name': 'Furniture Moving', 'icon': Icons.inventory_2},
          {'name': 'Delivery & Courier Services', 'icon': Icons.local_shipping},
        ],
      ),

      // 6. Others
      ServicesListScreen(
        categoryTitle: "Other Services",
        servicesList: [
          {'name': 'CCTV & Security Systems', 'icon': Icons.security},
          {
            'name': 'Smart Home Setup &Repair',
            'icon': Icons.home_repair_service,
          },
          {'name': ' Swimming Pool Maintenance', 'icon': Icons.pool},
          {'name': 'Customized Request', 'icon': Icons.more_horiz},
          {'name': 'Interior Decoration', 'icon': Icons.light_outlined},
        ],
      ),
    ];
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.build_outlined, 'label': 'Home Repair'},
      {'icon': Icons.home_outlined, 'label': 'Cleaning'},
      {'icon': Icons.content_cut_outlined, 'label': 'Personal'},
      {'icon': Icons.directions_car_outlined, 'label': 'Vehicle'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Moving'},
      {'icon': Icons.more_horiz_outlined, 'label': 'Other'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            //  هنا الـ index بيعرف الصفحة اللي هيدخل عليها
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => categoryScreens[index]),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categories[index]['icon'],
                  color: AppColors.secondaryLightBeige,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['label'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.secondaryLightBeige,
                    // Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- كارت المراجعات ---
  Widget _buildReviewsCard(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return InkWell(
      onTap: () {
        _showRatingDialog(context, "SpencerN");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2EFE9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFF2EFE9),
              child: Icon(Icons.star, color: Colors.orange),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reviews Given",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "You rated ${userProvider.allRatings.length} services.",
                  // "You rated 2 services.",
                  style: TextStyle(color: AppColors.textgrey, fontSize: 13),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String workerName) {
    double selectedRating = 5.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate $workerName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select stars:"),
            Slider(
              value: selectedRating,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: Colors.amber,
              onChanged: (val) => selectedRating = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).submitWorkerRating("Jane D.", selectedRating);
              Navigator.pop(context);
            },
            child: Text("SUBMIT"),
          ),
        ],
      ),
    );
  }
  // 1. دالة بناء العنصر الواحد داخل قائمة الإشعارات
  // 1. Notification Item (User Version)
  Widget _buildNotificationItem({
    required String title,
    required String time,
    required Color color,
    required IconData icon,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                // This button appears ONLY for the User when a job is done
                if (type == 'completed')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton(
                      onPressed: () { /* Navigate to Rate Page */ },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        minimumSize: const Size(80, 30),
                      ),
                      child: const Text("Rate Service", style: TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. دالة بناء الـ Dialog (النافذة المنبثقة) للإشعارات
  Widget _buildNotificationDialog(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2EFE9), // الخلفية البيج
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Consumer<UserProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen, // اللون الغامق بتاعك
                      ),
                    ),
                    if (provider.notifications.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                        onPressed: () => provider.clearAllNotifications(),
                      ),
                  ],
                ),
                const Divider(height: 20),
                Flexible(
                  child: provider.notifications.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text("No new notifications", style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            var item = provider.notifications[index];
                            return Dismissible(
                              key: Key(item['id'].toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) => provider.deleteNotification(index),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                              child: _buildNotificationItem(
                                title: item['title'],
                                time: item['time'],
                                type: item['type'] ?? 'default',
                                // تحديد اللون والأيقونة بناءً على النوع
                                color: item['type'] == 'success' ? Colors.green : 
                                       (item['type'] == 'completed' ? Colors.orange : const Color(0xFF1B2B2B)),
                                icon: item['type'] == 'success' ? Icons.check_circle : 
                                      (item['type'] == 'completed' ? Icons.star : Icons.notifications_active_outlined),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

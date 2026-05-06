
import 'package:flutter/material.dart';
import 'custom_bottom_nav.dart';
import 'schedule_screen.dart';
import 'task_details_screen.dart';
import 'welcome_screen_modified.dart';
import 'account_screen.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }
}

class JobsScreen extends StatefulWidget {
  final List<String> selectedSkills;
  const JobsScreen({super.key, required this.selectedSkills});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchWorkerTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final allJobs = provider.availableJobs;

    final filteredJobs = allJobs;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      extendBody: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            _buildHeader(provider),

            // لو مفيش وظائف تناسب المهارات
            if (filteredJobs.isEmpty)
              _buildEmptyState(context)
            else
              // عرض أول وظيفة فقط (Show only the first job)
              _buildJobCard(
                context,
                title: filteredJobs[0]['title'],
                specialty: filteredJobs[0]['specialty'],
                price: filteredJobs[0]['price'],
                details: filteredJobs[0]['details'],
                location: filteredJobs[0]['location'],
                posted: filteredJobs[0]['posted'],
                icon: filteredJobs[0]['icon'] ?? Icons.work_outline,
                customer: filteredJobs[0]['customer'] ?? {},
                taskId: filteredJobs[0]['id'] ?? "",
              ),

            const SizedBox(height: 20),
            // قسم الـ Feedback في الآخر خالص تحت
            _buildRatingsSection(context),
            const SizedBox(height: 100), // مساحة عشان الـ Bottom Nav Bar
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Jobs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllJobsScreen(selectedSkills: widget.selectedSkills),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            provider.workerCategory.isNotEmpty 
                ? 'Showing tasks matching your specialty: ${provider.workerCategory}'
                : 'Showing all available tasks in your category',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String title,
    required String specialty,
    required int price,
    required String details,
    required String location,
    required String posted,
    required IconData icon,
    required Map<String, dynamic> customer,
    required String taskId,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.button, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
              Text(
                '\$$price',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  specialty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5E7153),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (Provider.of<UserProvider>(context).myBids[taskId] != null)
                (() {
                  final status = Provider.of<UserProvider>(context).myBids[taskId];
                  String text = "BID SENT";
                  Color color = Colors.orange;
                  if (status == 'accepted') {
                    text = "ACCEPTED";
                    color = Colors.green;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                })(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            details,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    posted,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: AppColors.primaryDarkGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                //onPressed: () {},
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(
                        title: title,
                        price: price,
                        details: details,
                        specialty: specialty,
                        customer: customer,
                        taskId: taskId,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View Details & Act',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
  final allRatings = provider.allRatings;
    // 1. عرفي اللستة هنا (جوه الميثود) عشان الأخطاء الحمراء تروح
   /* final List<Map<String, String>> allRatings = [
      {'rating': '4.0 from Jane D.', 'date': 'Sep 28, 2025'},
      {'rating': '5.0 from Mark R.', 'date': 'Oct 1, 2025'},
    ];*/

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Latest Ratings (${allRatings.length})', // الرقم هيتعدل لوحده لـ 2
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDarkGreen,
            ),
          ),
          const Divider(height: 20, color: AppColors.primaryDarkGreen),
          allRatings.isEmpty 
  ? Text("No ratings yet", style: TextStyle(color:AppColors.primaryDarkGreen,fontSize: 14))
  : Column(
      children: allRatings.map((r) => _buildRatingItem(r['rating']!, r['date']!)).toList(),
    ),

          // 2. اللوب اللي بيعرض التقييمات والتواريخ
          ...allRatings
              .map((r) => _buildRatingItem(r['rating']!, r['date']!))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRatingItem(String rating, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.button, size: 18),
              const SizedBox(width: 5),
              Text(
                rating,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
          ),
          Text(
            date,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(Icons.work_off_outlined, size: 70, color: AppColors.button),
            const SizedBox(height: 10),
            Text(
              "No jobs available in your category",
              style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 18),
            ),
            // النص الرصاصي الصغير اللي كان ناقصك
            const SizedBox(height: 8), // مسافة صغيرة
            const Text(
              'Check back later or update your profile services.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textgrey,
                // Colors.grey,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 24), // مسافة قبل الزرار
            // الزرار اللي هيودي للبروفايل
            ElevatedButton(
              onPressed: () {
                // هيروح لصفحة البروفايل علطول
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountScreen(selectedSkills: []),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                //const Color(0xFFE0D4AD), // لون الزرار البيج من التصميم
                foregroundColor: AppColors.primaryDarkGreen, // لون الكتابة
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Update Specialties',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryDarkGreen,
      title: const Text(
        'FIXPAY',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          // color: Colors.white,
        ),
      ),
      actions: [
        // 1. أيقونة التقويم
        IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.backgroundWhite, // أو AppColors.backgroundWhite
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyScheduleScreen()),
            );
          },
        ),
        SizedBox(width: 4),
        /* borderRadius: BorderRadius.circular(20),
          child:*/
        Consumer<UserProvider>(
          builder: (context, provider, child) {
            return Badge(
              // العلامة تظهر بس لو فيه إشعارات جديدة
              isLabelVisible:
                  provider.hasNewNotifications &&
                  provider.notifications.isNotEmpty,
              label: Text(
                provider.notifications.length.toString(),
              ), // اختياري: بيظهر الرقم جوه النقطة
              backgroundColor: Colors.red,
              child: InkWell(
                onTap: () {
                  provider.markNotificationsAsSeen();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return _buildNotificationDialog(context);
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.backgroundWhite,
                  child: Icon(
                    Icons.notifications_none,
                    size: 18,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(width: 8),
        // 3. أيقونة البروفايل
        InkWell(
          onTap: () => print("Go to Account"),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 10,
              left: 4,
            ), // تظبيط المسافة الأخيرة
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.backgroundWhite,
                  backgroundImage: userProvider.workerImage != null
                      ? FileImage(userProvider.workerImage!)
                      : null,
                  child: userProvider.workerImage == null
                      ? const Icon(
                          Icons.person,
                          size: 18,
                          color: Color(0xFF1B5E20),
                        )
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            // Color(0xFFF2EFE9),
            color.withOpacity(0.05), // خلفية خفيفة حسب نوع الإشعار
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دي الدالة اللي كانت ناقصة ومسببة الـ Error
  Widget _buildNotificationDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Color(0xFFF2EFE9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
      child: Consumer<UserProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep, color: Colors.red),
                      onPressed: () => provider.clearAllNotifications(),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: provider.notifications.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No notifications yet"),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            var item = provider.notifications[index];
                            return Dismissible(
                              key: Key(item['id'].toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) =>
                                  provider.deleteNotification(index),
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red.shade400,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: _buildNotificationItem(
                                title: item['title'],
                                time: item['time'],
                                color: item['type'] == 'success'
                                    ? Colors.green
                                    : AppColors.button,
                                icon: item['type'] == 'success'
                                    ? Icons.check_circle_outline
                                    : Icons.notifications_none,
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

class AllJobsScreen extends StatelessWidget {
  final List<String> selectedSkills;
  const AllJobsScreen({super.key, required this.selectedSkills});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final allJobs = provider.availableJobs;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('All Available Jobs'),
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
      ),
      body: allJobs.isEmpty
          ? const Center(child: Text('No jobs available'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: allJobs.length,
              itemBuilder: (context, index) {
                final job = allJobs[index];
                return _buildJobCard(
                  context,
                  title: job['title'],
                  specialty: job['specialty'],
                  price: job['price'],
                  details: job['details'],
                  location: job['location'],
                  posted: job['posted'],
                  icon: job['icon'] ?? Icons.work_outline,
                  customer: job['customer'] ?? {},
                  taskId: job['id'] ?? "",
                );
              },
            ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String title,
    required String specialty,
    required int price,
    required String details,
    required String location,
    required String posted,
    required IconData icon,
    required Map<String, dynamic> customer,
    required String taskId,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.button, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
              Text(
                '\$$price',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  specialty.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5E7153),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (Provider.of<UserProvider>(context).myBids[taskId] != null)
                (() {
                  final status = Provider.of<UserProvider>(context).myBids[taskId];
                  String text = "BID SENT";
                  Color color = Colors.orange;
                  if (status == 'accepted') {
                    text = "ACCEPTED";
                    color = Colors.green;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                })(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            details,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    posted,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: AppColors.primaryDarkGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(
                        title: title,
                        price: price,
                        details: details,
                        specialty: specialty,
                        customer: customer,
                        taskId: taskId,
                      ),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

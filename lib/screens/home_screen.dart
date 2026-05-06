import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_screen.dart';
import 'active_request_page.dart';
import 'cleaning_page.dart';
import 'custom_bottom_nav.dart';
import 'home_repairpage.dart';
import 'moving_page.dart';
import 'other_services_page.dart';
import 'personal_page.dart';
import 'task_details_screen.dart';
import 'services_list_screen.dart';
import 'user_provider.dart';
import 'welcome_screen_modified.dart';
import 'all_categories_screen.dart';
import 'request_details_screen.dart';
import '../core/category_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 Fetch real data from backend on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final up = Provider.of<UserProvider>(context, listen: false);
      up.loadUserData();
      up.fetchMyRequests();
      up.fetchCategories();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    // 5 PM (17) to 5 AM MUST show 'Good evening 🌙'
    if (hour >= 17 || hour < 5) {
      return "Good evening 🌙";
    } else if (hour >= 5 && hour < 12) {
      return "Good morning ☀️";
    } else {
      return "Good afternoon ☀️";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildGreetingCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Active Requests", () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveRequestPage()));
                  }),
                  const SizedBox(height: 12),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final requests = userProvider.myRequests;
                      if (requests.isEmpty) {
                        return _buildEmptyActiveState();
                      }
                      return _buildActiveRequestsSection(context, requests);
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Browse Categories", () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCategoriesScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildCategoriesGrid(),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Your Recent Reviews", null),
                  const SizedBox(height: 12),
                  _buildReviewsCard(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primaryDarkGreen,
      elevation: 0,
      title: const Text(
        "FIXPAY",
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
      ),
      actions: [
        Consumer<UserProvider>(
          builder: (context, provider, child) {
            int unreadCount = provider.notifications.where((n) => n['isRead'] == false).length;
            return Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Colors.redAccent,
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                onPressed: () => showDialog(context: context, builder: (context) => _buildNotificationDialog(context)),
              ),
            );
          },
        ),
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen(selectedSkills: [],))),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: userProvider.userImage != null ? FileImage(userProvider.userImage!) : null,
                  child: userProvider.userImage == null
                      ? const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20)
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDarkGreen, Color(0xFF2E4D4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Text(
                "${_getGreeting()} , \n${userProvider.userName}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            "What can we fix for you today?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2B2B),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "See All",
              style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyActiveState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDarkGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primaryDarkGreen.withOpacity(0.5)),
          const SizedBox(width: 12),
          const Text(
            "No active requests right now.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRequestsSection(BuildContext context, List<Map<String, dynamic>> requests) {
    final lastRequest = requests.last;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveRequestPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2EFE9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primaryDarkGreen, size: 24),
                    const SizedBox(width: 8),
                    Text("${requests.length} Active Requests", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lastRequest['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(lastRequest['status'] ?? '', style: const TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text("\$${lastRequest['price']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;

        if (categories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
        }

        // We show only the first 5 categories and an "Other" button
        final int displayCount = categories.length > 5 ? 5 : categories.length;
        final bool showOther = categories.length > 5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: showOther ? 6 : displayCount,
          itemBuilder: (context, index) {
            // Case: The "More" button (last item in a 6-item grid)
            if (showOther && index == 5) {
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllCategoriesScreen())),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDarkGreen.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryDarkGreen.withOpacity(0.1),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: AppColors.primaryDarkGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "More",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B2B2B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cat = categories[index];
            final String name = cat['name'] ?? 'Other';
            final IconData icon = CategoryHelper.getIcon(name);

            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsScreen(
                    serviceName: name,
                    categoryId: cat['_id'],
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDarkGreen.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryDarkGreen.withOpacity(0.15),
                            AppColors.primaryDarkGreen.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primaryDarkGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B2B2B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF2EFE9), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppColors.primaryDarkGreen)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Excellent work!", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("The worker was very professional and punctual.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Text(" 5.0", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDialog(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    return AlertDialog(
      title: const Text("Notifications"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: provider.notifications.length,
          itemBuilder: (context, index) {
            final n = provider.notifications[index];
            return ListTile(
              title: Text(n['title']),
              subtitle: Text(n['time']),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => provider.deleteNotification(index)),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        TextButton(onPressed: () { provider.clearAllNotifications(); Navigator.pop(context); }, child: const Text("Clear All")),
      ],
    );
  }
}

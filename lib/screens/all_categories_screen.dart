import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'welcome_screen_modified.dart';
import 'home_repairpage.dart';
import 'cleaning_page.dart';
import 'personal_page.dart';
import 'moving_page.dart';
import 'other_services_page.dart';
import 'request_details_screen.dart';
import '../core/category_helper.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text("All Services", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDarkGreen),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final String name = cat['name'] ?? 'Category';
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
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF2EFE9)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2EFE9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: AppColors.primaryDarkGreen, size: 36),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2B2B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

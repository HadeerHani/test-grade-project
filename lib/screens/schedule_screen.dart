import 'welcome_screen_modified.dart';

import 'user_provider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor:
          AppColors.backgroundWhite, // لون الخلفية الكريمي اللي في الصورة
      appBar: AppBar(title: const Text('My Schedule')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
         child: Column(
          children: [
            // 1. قسم التقويم (Calendar Section)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Color(0xFFF2EFE9),
                // Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2025, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFFE57373),
                    shape: BoxShape.circle,
                  ), // النقطة الحمراء
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            // 2. عنوان التفاصيل
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Details for ${_selectedDay?.day ?? _focusedDay.day}th Oct",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),

            // 3. قائمة المهام (Details List)
            
              const SizedBox(height: 20,),
              ListView.builder(
                shrinkWrap:true,
                physics:NeverScrollableScrollPhysics(),
                itemCount: provider.scheduledJobs.length,
                itemBuilder: (context, index) {
                  final job = provider.scheduledJobs[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF2EFE9),
                      borderRadius: BorderRadius.circular(15),
                      // border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "10:00 AM - ${job['type']} Service",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.button,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child:  Text( job['status']??'pending',
                              
                                //'Confirmed',
                                style: TextStyle(
                                  color: job['status']=='Pending' ? AppColors.primaryDarkGreen:AppColors.button,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          job['title'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          "Customer: ${job['customer']}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // استدعاء الدالة اللي عدلناها في البروفايدر
                              provider.completeJob(job);

                              // إظهار رسالة تأكيد بسيطة (SnackBar)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${job['title']} Completed!"),
                                  backgroundColor: AppColors.button,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDarkGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Complete",
                              style: TextStyle(
                                color: AppColors.backgroundWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            
          ],
        ),
        ),
      ),
    );
  }
}

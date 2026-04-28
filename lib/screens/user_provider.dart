import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProvider extends ChangeNotifier {
  // --- [1] بيانات المستخدم (User) ---
  String _userName = "Jane";
  String _userEmail = "jane@mail.com";
  String _userPhone = "0100000000";
  String _userAddress = "Cairo, Egypt";
  String _userBio = "Flutter Developer";
  File? _userImage;

  // --- [2] بيانات العامل (Worker) ---
  String _workerName = "Spencer N.";
  String _workerSSN = "12345678";
  String _workerBio = "Professional Electrician";
  String _workerEmail = "spencer@work.com";
  String _workerPhone = "01122334455";
  String _workerAddress = "Giza, Egypt";
  File? _workerImage;

  // --- [3] القوائم والأرباح ---
  double _totalEarnings = 0.0;
  List<Map<String, dynamic>> _earningsHistory = [];
  List<Map<String, dynamic>> _scheduledJobs = [];
  List<Map<String, dynamic>> _notifications = [];
  //List<Map<String, dynamic>> _allRatings = [];
  // ضيفي ده فوق مع باقي القوائم
  //List<Map<String, dynamic>> _availableJobs = [];
  List<Map<String, dynamic>> _availableJobs = [
    {
      'title': 'Unclog main shower drain',
      'customer': 'Jane D.',
      'amount': 120.0,
      'type': 'plumbing',
    },
    {
      'title': 'Install new ceiling fan',
      'customer': 'Tom H.',
      'amount': 160.0,
      'type': 'electric',
    },
  ];

  // وده الـ Getter بتاعها عشان الصفحات تشوفها
  List<Map<String, dynamic>> get availableJobs => _availableJobs;
  List<Map<String, dynamic>> get allRatings => _allRatings;
  List<Map<String, dynamic>> _allRatings = [];

  // 1. متغير عشان نعرف فيه إشعارات جديدة ولا لأ
  bool _hasNewNotifications = true;

  // 2. Getter عشان الصفحة تقرأ القيمة (للسطر 433 في صورتك)
  bool get hasNewNotifications => _hasNewNotifications;

  // 3. الدالة اللي بتشيل العلامة الحمراء لما يفتح الإشعارات (للسطر 441 في صورتك)
  void markNotificationsAsSeen() {
    _hasNewNotifications = false;
    notifyListeners(); // عشان النقطة الحمراء تختفي من الشاشة فوراً
  }

  // --- [4] الـ Getters (عشان الشاشات تقرأ الداتا) ---
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userAddress => _userAddress;
  String get userBio => _userBio;
  File? get userImage => _userImage;

  String get workerName => _workerName;
  String get workerSSN => _workerSSN;
  String get workerEmail => _workerEmail;
  String get workerPhone => _workerPhone;
  String get workerAddress => _workerAddress;
  String get workerBio => _workerBio;
  File? get workerImage => _workerImage;

  double get totalEarnings => _totalEarnings;
  List<Map<String, dynamic>> get earningsHistory => _earningsHistory;
  List<Map<String, dynamic>> get scheduledJobs => _scheduledJobs;
  List<Map<String, dynamic>> get myRequests => _myRequests; // لحل إيرور الهوم
  List<Map<String, dynamic>> get notifications => _notifications;

  // --- [5] كل الدوال اللي في الصور ---

  // دالة القبول (Confirm)
  void acceptJob(Map<String, dynamic> job) {
    _availableJobs.removeWhere((item) => item['title'] == job['title']);
    _scheduledJobs.insert(0, {...job, 'status': 'Confirmed'});
    addNotification("Job '${job['title']}' has been confirmed.", "success");
    notifyListeners();
  }

  // دالة التفاوض (Counter Offer)
  void sendCounterOffer(Map<String, dynamic> job) {
    // 1. نأخذ نسخة من الطلب ونغير حالته لـ Pending
    var pendingJob = Map<String, dynamic>.from(job);
    pendingJob['status'] = 'Pending';

    // 2. نضيفه لقائمة المواعيد (عشان يظهر في صفحة النتائج/الجدول)
    _scheduledJobs.add(pendingJob);

    // 3. نحذفه من قائمة الطلبات المتاحة (عشان يختفي من الـ Available)
    // استبدلي '_availableJobs' باسم القائمة المتاحة عندك
    _availableJobs.removeWhere((item) => item['title'] == job['title']);

    notifyListeners(); // تحديث كل الشاشات
  }

  // دالة الإتمام (Complete) - بتشيل من القائمة وتضيف للأرباح
  void completeJob(Map<String, dynamic> job) {
    _scheduledJobs.removeWhere((item) => item['title'] == job['title']);

    double jobAmount = 0.0;
    if (job['price'] != null) {
      jobAmount = double.tryParse(job['price'].toString()) ?? 0.0;
    } else if (job['amount'] != null) {
      jobAmount = double.tryParse(job['amount'].toString()) ?? 0.0;
    }

    _totalEarnings += jobAmount;
    _earningsHistory.insert(0, {
      'title': job['title'],
      'customer': job['customer'] ?? 'Client',
      'amount': jobAmount,
      'date': DateFormat('MMM dd, yyyy').format(DateTime.now()),
      'type': job['type'] ?? 'General',
    });

    addNotification("Completed: ${job['title']}. Earnings updated.", "success");
    notifyListeners();
  }

  // دالة حذف كل الإشعارات
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // دالة حذف إشعار واحد
  void deleteNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  // دالة حذف طلب من القائمة
  void removeRequest(int index) {
    if (index >= 0 && index < _myRequests.length) {
      _myRequests.removeAt(index);
      notifyListeners();
    }
  }

  void removeScheduledJob(int index) {
    if (index >= 0 && index < _scheduledJobs.length) {
      _scheduledJobs.removeAt(index);
      notifyListeners();
    }
  }

  // دالة التقييم
  void submitWorkerRating(String customerName, double rating) {
    _allRatings.insert(0, {
      'customer': customerName,
      'rate': rating,
      'date': DateTime.now().toString(),
    });
    notifyListeners();
  }

  // تحديث بيانات العامل
  void updateWorkerData({
    String? name,
    String? ssn,
    String? bio,
    String? email,
    String? phone,
    String? address,
    File? image,
  }) {
    if (name != null) _workerName = name;
    if (ssn != null) _workerSSN = ssn;
    if (bio != null) _workerBio = bio;
    if (email != null) _workerEmail = email;
    if (phone != null) _workerPhone = phone;
    if (image != null) _workerImage = image;
    if (address != null) _workerAddress = address;
    notifyListeners();
  }

  // تحديث بيانات المستخدم
  void updateUserData({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? bio,
    File? image,
  }) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (address != null) _userAddress = address;
    if (bio != null) _userBio = bio;
    if (image != null) _userImage = image;
    notifyListeners();
  }

  // إضافة طلب جديد (لصفحة Details)
  void addRequest(Map<String, dynamic> request) {
    _myRequests.insert(0, request);
    notifyListeners();
  }

  // جوه ملف الـ UserProvider
  List<Map<String, dynamic>> _myRequests = [
    {
      'title': 'Electrician',
      'serviceType': 'Electrician',
      'status': 'Accepted',
      'price': '150',
      'date': 'Monday, 2:00 PM',
    },
  ];

  // 4. دالة لتحديث حالة الطلب (لو وافق أو رفض أو جالنا عرض سعر)
  /* void updateRequestStatus(int index, String newStatus) {
    _myRequests[index]['status'] = newStatus;
    notifyListeners();
  }*/

  // دالة مساعدة للإشعارات
  void addNotification(String title, String type) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'type': type,
      'time': DateFormat('hh:mm a').format(DateTime.now()),
    });
    notifyListeners();
  }

  // دالة لتحديث بيانات طلب معين في القائمة
  void updateRequestStatus(
    int index,
    String newDate,
    String newTitle,
    String newprice,
  ) {
    if (index >= 0 && index < _scheduledJobs.length) {
      _scheduledJobs[index]['date'] = newDate;
      _scheduledJobs[index]['title'] = newTitle;
      _scheduledJobs[index]['price'] = newprice;
      notifyListeners();
    }
  }

  void logout() {
    // 1. تصفير بيانات المستخدم الأساسية
    _userName = "User Name";
    _userEmail = "";
    _userPhone = "";
    _userAddress = "";
    _userBio = "";
    _userImage = null;

    // 2. تصفير بيانات العامل
    _workerName = "Worker Name";
    _workerSSN = "";
    _workerBio = "";
    _workerEmail = "example@mail.com";
    _workerPhone = "";
    _workerAddress = "";
    _workerImage = null;
  }
}

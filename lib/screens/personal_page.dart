
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'welcome_screen_modified.dart';
import 'user_provider.dart';
import 'custom_bottom_nav.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  bool isEditing = false;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    // بنجيب نسخة من البروفايدر
    var up = Provider.of<UserProvider>(context, listen: false);
    
    // بنملى الـ Controllers ببيانات اليوزر
    nameController = TextEditingController(text: up.userName); // تأكدي من اسم المتغير في البروفايدر
    emailController = TextEditingController(text: up.userEmail);
    phoneController = TextEditingController(text: up.userPhone);
    addressController = TextEditingController(text: up.userAddress);
    bioController = TextEditingController(text: up.userBio);
  }
  
  /*final TextEditingController _nameController;
  final TextEditingController _emailController = TextEditingController(text: "jane.d@email.com");
  final TextEditingController _phoneController = TextEditingController(text: "+1 (555) 987-6543");
  final TextEditingController _addressController = TextEditingController(text: "456 Customer Ave, City, State");
  final TextEditingController _bioController =
   TextEditingController(text: "Homeowner seeking reliable, quick service for minor repairs.");*/

 /* @override
  void initState() {
    super.initState();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;
    _nameController = TextEditingController(text: userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }*/
 /* Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  
  // 💡 دي بتفتح قائمة صغيرة تختار منها المستخدم (الكاميرا أو الجاليري)
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera, 
    imageQuality: 50, 
  );
  if (image != null) {
    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).updateImage(File(image.path));
  }
}*/

 /* Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Provider.of<UserProvider>(context, listen: false).updateImage(File(image.path));
    }
  }*/
  Future<void> _pickImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    // اختيار الصورة من الجاليري
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // بنقلل الجودة شوية عشان ميهنجش في الموبايلات الضعيفة
    );

    if (image != null) {
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).updateUserData( image:File (image.path));
      
      print("Image picked successfully: ${image.path}");
    }
  } catch (e) {
    print("Error picking image: $e");
  }
}

  void _saveChanges() {
    Provider.of<UserProvider>(context, listen: false).updateUserData(name: nameController.text,
  email: emailController.text, 
  phone: phoneController.text,
  address: addressController.text,
  bio: bioController.text,);
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text("My Account"), 
        //style: TextStyle(color:App)//),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color:AppColors.backgroundWhite),
            onPressed: () {
              if (isEditing) _saveChanges();
              else setState(() => isEditing = true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFF2EFE9),
                        backgroundImage: userProvider.userImage != null ? FileImage(userProvider.userImage!) : null,
                        child: userProvider.userImage == null
                            ? Text(nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : "J",
                                style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, 
                                color: AppColors.primaryDarkGreen))
                            : null,
                      );
                    },
                  ),
                  if(isEditing)
                    GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFF2EFE9),
                        child: Icon(Icons.camera_alt, size: 18, color: AppColors.primaryDarkGreen),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Consumer<UserProvider>(
              builder: (context, user, child) {
                return Text(user.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen));
              },
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFE9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Personal Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDarkGreen)),
                  const SizedBox(height: 25),
                  _buildField("NAME", nameController, isEditing),
                  _buildField("EMAIL", emailController, isEditing, isEmail: true),
                  _buildField("PHONE", phoneController, isEditing),
                  _buildField("ADDRESS", addressController, isEditing),
                  _buildField("BIO", bioController, isEditing, maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
               // onPressed: () { },
               onPressed: () {
  // 1. مسح البيانات من الـ Provider
  Provider.of<UserProvider>(context, listen: false).logout();

  // 2. الرجوع لصفحة الـ Login ومسح كل الصفحات اللي فاتت
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()), 
    (route) => false,
  );
},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text("Log Out", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isEditMode, {bool isEmail = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFBCAAA4), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if(isEditMode)
            TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
              style: const TextStyle(fontSize: 16, color: AppColors.primaryDarkGreen),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: Text(controller.text, style: const TextStyle(fontSize: 16, color: AppColors.primaryDarkGreen), maxLines: maxLines, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}

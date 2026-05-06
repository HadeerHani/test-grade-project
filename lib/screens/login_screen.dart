import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_account_screen.dart';
import 'forgot_password.dart';
import 'home_screen.dart';
import 'main_aej_screen.dart';
import 'welcome_screen_modified.dart';
import 'worker_verification_screen.dart';
import 'user_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryLightBeige,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                //SizedBox(height: 2,),
                const Text(
                  'Log in to continue ',
                  style: TextStyle(
                    fontSize: 23,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final response = await http.post(
                                  Uri.parse(ApiConstants.login),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'email': _emailController.text.trim(),
                                    'password': _passwordController.text,
                                  }),
                                );

                                final data = jsonDecode(response.body);
                                print('DEBUG_WORKER_LOGIN_DATA: ${response.body}');
                                debugPrint('Login Response: ${response.body}');

                                if (response.statusCode == 200) {
                                  final token = data['token'];
                                  final user = data['user'];
                                  final prefs = await SharedPreferences.getInstance();

                                  if (token != null) {
                                    await prefs.setString('jwt_token', token);
                                    await prefs.setString('user_id', user['_id'] ?? '');
                                    await prefs.setString('user_role', user['role'] ?? 'user');
                                    await prefs.setString('user_name', user['userName'] ?? user['name'] ?? 'User');
                                    await prefs.setString('user_email', user['email'] ?? '');
                                    
                                    final categoryData = user['categoryId'];
                                    String catName = "";
                                    if (categoryData is Map) {
                                      catName = categoryData['name'] ?? "";
                                    } else if (categoryData is String) {
                                      catName = categoryData;
                                    }
                                    await prefs.setString('user_category', catName);
                                    
                                    debugPrint('Token Saved: $token');
                                  }

                                  if (!mounted) return;

                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  
                                  final String tokenStr = token ?? '';
                                  final String userId = user['_id'] ?? '';
                                  final String role = user['role'] ?? 'user';
                                  final String userName = user['userName'] ?? user['name'] ?? 'User';
                                  final String email = user['email'] ?? '';
                                  final identity = user['identityVerification'] ?? {};
                                  final String verifyStatus = identity['status'] ?? 'unverified';

                                  await prefs.setString('user_verify_status', verifyStatus);
                                  userProvider.setAuth(tokenStr, userId, role: role, verifyStatus: verifyStatus);
                                  if (role == 'worker') {
                                    final categoryData = user['categoryId'];
                                    String catName = "";
                                    if (categoryData is Map) {
                                      catName = categoryData['name'] ?? "";
                                    } else if (categoryData is String) {
                                      catName = categoryData;
                                    }
                                    userProvider.updateWorkerData(name: userName, email: email, category: catName);
                                  } else {
                                    userProvider.updateUserData(name: userName, email: email);
                                  }

                                  // Direct Routing (Bypassing OTP & ID Verification for presentation/testing)
                                  if (user['role'] == 'user') {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  } else if (user['role'] == 'worker') {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MainScreen(
                                          selectedSkills: [],
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        data['message'] ?? 'Login failed',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint('Login Error: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryDarkGreen,
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ForgotPassword();
                        },
                      ),
                    );
                  },
                  child: Center(
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 20,
                        endIndent: 10,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: Color.fromARGB(255, 97, 97, 97),
                          fontSize: 19,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 20,
                        endIndent: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  // padding: const EdgeInsets.symmetric(horizontal: 80,),
                  child: Center(
                    //width: 280,
                    //ConstrainedBox(constraints: const BoxConstraints(maxHeight: 50),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        //
                        print('Signing in with Google...');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primaryDarkGreen,
                          width: 2.0,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.symmetric(
                          horizontal: 35.0,
                          vertical: 10.0,
                        ),
                        minimumSize: Size.zero,
                        // padding: const EdgeInsets.symmetric(horizontal: 90),
                        backgroundColor: Colors.white70,
                        foregroundColor: AppColors.primaryDarkGreen,
                        elevation: 1,
                      ),

                      icon: Image.asset(
                        'lib/assets/images/google.png',
                        height: 20,
                      ),
                      label: const Text(
                        'Google',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Color.fromRGBO(56, 94, 72, 1),
                        fontSize: 19,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CreateAccountScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

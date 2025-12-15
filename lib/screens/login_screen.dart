import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Using your icon pack
import 'signup_screen.dart'; 
//import 'home_screen.dart'; // Ensure this exists

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  late TabController _tabController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _forgotPassEmailController = TextEditingController();

  //String? _verificationId;
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _forgotPassEmailController.dispose();
    super.dispose();
  }

  // Common Input Decoration to match your theme
  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
               Text("Sign in to continue verifying news.", style: TextStyle(fontSize: 16, color: Colors.grey)),
               SizedBox(height: 30),
              
              // Custom Tab Bar
              Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(12)
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: "Email"),
                    Tab(text: "Phone"),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmailLogin(),
                    _buildPhoneLogin(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Email Login UI ---
  Widget _buildEmailLogin() {
    return Form(
      key: _emailFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: _inputDecor("Email Address", LucideIcons.mail),
              validator: (val) => val!.isEmpty ? 'Enter an email' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: _inputDecor("Password", LucideIcons.lock),
              obscureText: true,
              validator: (val) => val!.length < 6 ? 'Password too short' : null,
            ),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text("Forgot Password?", style: TextStyle(color: Colors.blue[600])),
              ),
            ),
            
            SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_emailFormKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    //var user = await _auth.signInWithEmail(_emailController.text, _passwordController.text);
                    setState(() => _isLoading = false);                                        
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Login", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen())),
                  child: Text("Sign Up", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Phone Login UI ---
  Widget _buildPhoneLogin() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: _inputDecor("Phone (+92...)", LucideIcons.phone),
            keyboardType: TextInputType.phone,
          ),
          if (_isOtpSent) ...[
            SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              decoration: _inputDecor("Enter OTP", LucideIcons.messageSquare),
              keyboardType: TextInputType.number,
            ),
          ],
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,            
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    if (_emailController.text.isNotEmpty) {
      _forgotPassEmailController.text = _emailController.text;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter your email to receive a reset link."),
              SizedBox(height: 10),
              TextField(
                controller: _forgotPassEmailController,
                decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                //await _auth.sendPasswordResetEmail(_forgotPassEmailController.text);
                Navigator.pop(context);
              },
              child: Text("Send Link"),
            ),
          ],
        );
      },
    );
  }
}
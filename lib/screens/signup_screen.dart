import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:newstrustai/screens/home/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;

  // ✅ OTP state
  bool _otpStage = false; // false = form, true = enter otp
  String? _verificationId;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    numberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void showSnackBar(String message, {Color color = Colors.blue}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8 && RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(password);
  }

  String _normalizePhone(String phone) {
    phone = phone.trim();
    if (phone.isEmpty) return "";

    // Pakistan default: 03xx... -> +92...
    if (phone.startsWith("0")) return "+92${phone.substring(1)}";

    // If user writes 3xx... assume +92
    if (!phone.startsWith("+") && phone.length >= 10) return "+92$phone";

    return phone;
  }

  // ==========================
  // STEP 1: EMAIL SIGNUP + SEND OTP
  // ==========================
  Future<void> signupUser() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = _normalizePhone(numberController.text);

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      showSnackBar("All fields are required (including phone)", color: Colors.red);
      return;
    }

    if (!isValidEmail(email)) {
      showSnackBar("Enter a valid email address", color: Colors.red);
      return;
    }

    if (!isValidPassword(password)) {
      showSnackBar("Password must be 8+ chars and include 1 special character", color: Colors.red);
      return;
    }

    if (!phone.startsWith("+")) {
      showSnackBar("Phone must be like +923001234567 or 03xx...", color: Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Create Email/Password user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        showSnackBar("Signup failed (no user).", color: Colors.red);
        return;
      }

      // ✅ Set display name
      await user.updateDisplayName(firstName);
      await user.reload();

      // ✅ Send OTP (do NOT save Firestore yet; wait until verified & linked)
      await _sendOtpToLinkPhone(phone);

      if (!mounted) return;
      setState(() {
        _otpStage = true;
      });

      showSnackBar("OTP sent. Please enter the code.", color: Colors.blue);
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "Signup failed", color: Colors.red);
    } catch (_) {
      showSnackBar("Something went wrong", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtpToLinkPhone(String phone) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      // ✅ If Android auto-verifies, link immediately
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _linkPhoneCredentialAndFinish(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        showSnackBar(e.message ?? "Phone verification failed", color: Colors.red);
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // ==========================
  // STEP 2: VERIFY OTP + LINK PHONE + SAVE FIRESTORE
  // ==========================
  Future<void> verifyOtpAndCompleteSignup() async {
    final otp = otpController.text.trim();
    final vid = _verificationId;

    if (vid == null || vid.isEmpty) {
      showSnackBar("OTP not sent yet. Please resend OTP.", color: Colors.red);
      return;
    }
    if (otp.length < 4) {
      showSnackBar("Enter a valid OTP", color: Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );

      await _linkPhoneCredentialAndFinish(credential);

      showSnackBar("Signup completed!", color: Colors.blue);
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "OTP verification failed", color: Colors.red);
    } catch (_) {
      showSnackBar("Something went wrong", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkPhoneCredentialAndFinish(AuthCredential phoneCredential) async {
    final user = _auth.currentUser;
    if (user == null) {
      showSnackBar("No user session found. Please signup again.", color: Colors.red);
      return;
    }

    // Link phone to the SAME user (prevents duplicate accounts)
    try {
      await user.linkWithCredential(phoneCredential);
    } on FirebaseAuthException catch (e) {
      // If the phone is already linked to another account
      if (e.code == "credential-already-in-use" || e.code == "provider-already-linked") {
        showSnackBar("This phone is already linked to another account.", color: Colors.red);
        return;
      }
      // Other linking errors
      showSnackBar(e.message ?? "Phone linking failed", color: Colors.red);
      return;
    }

    // ✅ Save user profile to Firestore AFTER linking
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = _normalizePhone(numberController.text);

    await _db.collection("users").doc(user.uid).set({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "phoneVerified": true,
      "createdAt": FieldValue.serverTimestamp(),
      "lastLoginAt": FieldValue.serverTimestamp(),
      "provider": "email+phone",
    }, SetOptions(merge: true));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(firstName: firstName),
      ),
    );
  }

  Future<void> _resendOtp() async {
    final phone = _normalizePhone(numberController.text);
    if (phone.isEmpty) {
      showSnackBar("Enter phone number first", color: Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _sendOtpToLinkPhone(phone);
      showSnackBar("OTP resent.", color: Colors.blue);
    } catch (_) {
      showSnackBar("Failed to resend OTP.", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.shieldCheck,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'NewsTrust AI',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ==========================
                      // FORM STAGE
                      // ==========================
                      if (!_otpStage) ...[
                        TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            hintText: "First Name",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            hintText: "Last Name",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: numberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Phone Number (03xx... or +92...)",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),

                        const SizedBox(height: 30),

                        GestureDetector(
                          onTap: signupUser,
                          child: Container(
                            width: 200,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],

                      // ==========================
                      // OTP STAGE
                      // ==========================
                      if (_otpStage) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Verify Phone Number",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "We sent an OTP to: ${_normalizePhone(numberController.text)}",
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter OTP",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: verifyOtpAndCompleteSignup,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Verify & Complete Signup",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _resendOtp,
                              child: const Text("Resend OTP"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Cancel signup flow: sign out + return to form
                                await _auth.signOut();
                                if (!mounted) return;
                                setState(() {
                                  _otpStage = false;
                                  _verificationId = null;
                                  otpController.clear();
                                });
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController recoveryCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isEmailSelected = true; // Determine recovery method (Email or Phone)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF530000), Color(0xFFFF5E5E)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          // Adding the image as a background over the gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/limg.png'), // Ensure the image is in the assets folder
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), // Adding opacity for better text visibility
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // White corners
          Align(
            alignment: Alignment.topLeft,
            child: ClipPath(
              clipper: CustomRightCornerClippe(),
              child: Container(
                height: 120,
                width: 200,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: CustomRightCornerClipper(),
              child: Container(
                height: 150,
                width: 200,
                color: Colors.white,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, left: 1), // تقليل padding
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_sharp, size: 40),
                        onPressed: () {
                          Navigator.pop(context); // العودة إلى صفحة تسجيل الدخول
                        },
                        color: Colors.red[800], // لون أحمر داكن لزر العودة
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  // Title
                  const Text(
                    "Reset Password",
                    style: TextStyle(
                      color: Colors.white, // White title color
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Recovery method selection
                  const Text(
                    "Select recovery method:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSquareButton("Email", () {
                        setState(() {
                          isEmailSelected = true;
                        });
                      }, isEmailSelected),
                      _buildSquareButton("Phone", () {
                        setState(() {
                          isEmailSelected = false;
                        });
                      }, !isEmailSelected),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Input fields based on selection
                  if (isEmailSelected)
                    _buildTextField(emailController, "Email", Icons.email)
                  else
                    _buildTextField(recoveryCodeController, "Phone Number", Icons.phone),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(recoveryCodeController, "Recovery Code", Icons.code),
                      ),
                      const SizedBox(width: 10),
                      _buildSquareButton("Get", () {
                        // Logic to receive recovery code
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code sent!')),
                        );
                      }, true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(passwordController, "New Password", Icons.lock, isPassword: true),
                  const SizedBox(height: 20),
                  _buildTextField(confirmPasswordController, "Confirm Password", Icons.lock, isPassword: true),
                  const SizedBox(height: 30),
                  // Confirm button
                  _buildElevatedButton("Confirm", () {
                    // Logic to confirm password reset
                  }),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to create a uniform text field
  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF530000), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Function to create a custom square button
  Widget _buildSquareButton(String text, VoidCallback onPressed, bool isSelected) {
    return Container(
      width: 160,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 5), // Reduce space between buttons
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : const Color(0xFF530000), // Text color based on selection
          backgroundColor: isSelected ? const Color(0xFF530000) : const Color(0xFFFFC1C1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  // Function to create a custom button
  Widget _buildElevatedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.red[800], // Dark red text color
          backgroundColor: Colors.white, // White button color
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// Custom clipper for the white corner
class CustomRightCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.6, size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // No need to reclip
}

class CustomRightCornerClippe extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.4, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false; // No need to reclip
}
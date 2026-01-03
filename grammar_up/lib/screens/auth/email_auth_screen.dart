import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/common/buttons.dart';
import '../../widgets/common/dolphin_mascot.dart';
import '../main/main_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        // Navigate trực tiếp đến MainScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const DolphinMascot(size: 100, showBook: true),
                const SizedBox(height: 24),
                Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập email và mật khẩu để tiếp tục',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: subtitleColor),
                    prefixIcon: Icon(Icons.email_outlined, color: subtitleColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkTeal : AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: fillColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: subtitleColor),
                    prefixIcon: Icon(Icons.lock_outline, color: subtitleColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: subtitleColor,
                      ),
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkTeal : AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: fillColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: isDark ? AppColors.darkTeal : AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isLoading ? 'ĐANG XỬ LÝ...' : 'ĐĂNG NHẬP',
                  onPressed: _isLoading ? () {} : _handleLogin,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(color: subtitleColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailSignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTeal : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_emailController.text.trim());

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Gửi email thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _emailSent ? _buildSuccessView(context) : _buildFormView(context),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.lock_reset,
              size: 50,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Quên mật khẩu?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Nhập email để nhận link đặt lại mật khẩu',
            style: TextStyle(fontSize: 14, color: subtitleColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: subtitleColor),
              prefixIcon: Icon(Icons.email_outlined, color: subtitleColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!value.contains('@')) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            text: _isLoading ? 'ĐANG GỬI...' : 'GỬI EMAIL',
            onPressed: _isLoading ? () {} : _handleResetPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(26),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Email đã được gửi!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Kiểm tra email ${_emailController.text} để đặt lại mật khẩu',
          style: TextStyle(fontSize: 14, color: subtitleColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          text: 'QUAY LẠI ĐĂNG NHẬP',
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    );
  }
}

class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  State<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop về landing screen, AuthWrapper sẽ tự động chuyển sang MainScreen
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    required Color fillColor,
    required Color primaryColor,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: subtitleColor),
      prefixIcon: Icon(prefixIcon, color: subtitleColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: fillColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const DolphinMascot(size: 100),
                const SizedBox(height: 24),
                Text(
                  'Đăng ký',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo tài khoản mới để bắt đầu',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _fullNameController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icons.person_outline,
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    fillColor: fillColor,
                    primaryColor: primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    fillColor: fillColor,
                    primaryColor: primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: subtitleColor,
                      ),
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                    ),
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    fillColor: fillColor,
                    primaryColor: primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: subtitleColor,
                      ),
                      onPressed: () {
                        setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                      },
                    ),
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    fillColor: fillColor,
                    primaryColor: primaryColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: _isLoading ? 'ĐANG XỬ LÝ...' : 'ĐĂNG KÝ',
                  onPressed: _isLoading ? () {} : _handleSignUp,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: subtitleColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailLoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
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

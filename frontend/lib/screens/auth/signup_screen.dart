import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();
  final nicknameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
              ),

              const SizedBox(height: 24),

              const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'TripMate와 함께 여행을 시작해보세요.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B91A8),
                ),
              ),

              const SizedBox(height: 36),

              _inputField(
                controller: emailController,
                label: '이메일',
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: nicknameController,
                label: '닉네임',
                hint: '사용할 닉네임을 입력해주세요',
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: passwordController,
                label: '비밀번호',
                hint: '비밀번호를 입력해주세요',
                obscureText: true,
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: passwordCheckController,
                label: '비밀번호 확인',
                hint: '비밀번호를 다시 입력해주세요',
                obscureText: true,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final nickname = nicknameController.text.trim();
                    final password = passwordController.text;
                    final passwordCheck = passwordCheckController.text;

                    if (email.isEmpty ||
                        nickname.isEmpty ||
                        password.isEmpty ||
                        passwordCheck.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('모든 항목을 입력해주세요.'),
                            ),
                          );
                          return;
                        }

                    if (password != passwordCheck) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호가 일치하지 않습니다.'),
                        ),
                      );
                      return;
                    }

                    try {
                      await AuthService.signup(
                        email: email,
                        password: password,
                        nickname: nickname,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('회원가입이 완료되었습니다.'),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('회원가입 실패: $e'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(
                      color: Color(0xFF8B91A8),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('로그인'),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
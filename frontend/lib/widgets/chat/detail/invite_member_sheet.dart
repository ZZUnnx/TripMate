import 'package:flutter/material.dart';

import '../../common/responsive.dart';
import 'chat_detail_circle_button.dart';

class InviteMemberSheet extends StatefulWidget {
  const InviteMemberSheet({super.key});

  @override
  State<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<InviteMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: context.insetsFromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF9),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(22)),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '친구 초대',
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ChatDetailCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const ResponsiveGap(height: 6),
              Text(
                '초대할 친구의 이메일을 입력해 주세요.',
                style: TextStyle(
                  color: const Color(0xFF60706D),
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const ResponsiveGap(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'friend@example.com',
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: Color(0xFF60706D),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: context.symmetricInsets(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(color: Color(0xFFDCE6E3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(
                      color: Color(0xFF148776),
                      width: 1.4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(color: Color(0xFFF27864)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.rs(12)),
                    borderSide: const BorderSide(
                      color: Color(0xFFF27864),
                      width: 1.4,
                    ),
                  ),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }

                  if (!email.contains('@')) {
                    return '이메일 형식을 확인해주세요.';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const ResponsiveGap(height: 14),
              SizedBox(
                width: double.infinity,
                height: context.rs(46),
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: context.rs(17),
                  ),
                  label: const Text('초대하기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF148776),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.rs(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

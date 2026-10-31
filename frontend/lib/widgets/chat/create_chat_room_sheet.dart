import 'package:flutter/material.dart';

import '../../controllers/chat/create_chat_room_controller.dart';
import '../common/responsive.dart';

class CreateChatRoomSheet extends StatefulWidget {
  const CreateChatRoomSheet({super.key, required this.accessToken});

  final String accessToken;

  @override
  State<CreateChatRoomSheet> createState() => _CreateChatRoomSheetState();
}

class _CreateChatRoomSheetState extends State<CreateChatRoomSheet> {
  final _titleController = TextEditingController();

  late final CreateChatRoomController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreateChatRoomController(accessToken: widget.accessToken);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('채팅방 이름을 입력해주세요.');
      return;
    }

    try {
      final created = await _controller.createRoom(title);

      if (!mounted || !created) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: context.insetsFromLTRB(24, 18, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '채팅방 만들기',
                      style: TextStyle(
                        color: const Color(0xFF121827),
                        fontSize: context.rs(22),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _controller.isSaving
                        ? null
                        : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const ResponsiveGap(height: 18),
              _SheetTextField(
                controller: _titleController,
                label: '채팅방 이름',
                hint: '예: 테스트방',
                textInputAction: TextInputAction.done,
              ),
              const ResponsiveGap(height: 24),
              SizedBox(
                width: double.infinity,
                height: context.rs(54),
                child: FilledButton(
                  onPressed: _controller.isSaving ? null : _createRoom,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF148776),
                    foregroundColor: Colors.white,
                  ),
                  child: _controller.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '만들기',
                          style: TextStyle(fontWeight: FontWeight.w900),
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

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.rs(14)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

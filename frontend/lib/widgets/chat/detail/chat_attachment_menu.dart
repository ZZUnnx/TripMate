import 'package:flutter/material.dart';

import '../../common/responsive.dart';

class ChatAttachmentMenu extends StatelessWidget {
  const ChatAttachmentMenu({
    super.key,
    required this.onAiSummaryTap,
    required this.onActionTap,
  });

  final VoidCallback onAiSummaryTap;
  final ValueChanged<String> onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.rs(96),
          width: double.infinity,
          padding: context.symmetricInsets(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAiSummaryTap,
              borderRadius: BorderRadius.circular(context.rs(16)),
              child: Row(
                children: [
                  Container(
                    width: context.rs(50),
                    height: context.rs(50),
                    decoration: BoxDecoration(
                      color: const Color(0xFF148776),
                      borderRadius: BorderRadius.circular(context.rs(16)),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.white,
                      size: context.rs(22),
                    ),
                  ),
                  const ResponsiveGap(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI 요약',
                          style: TextStyle(
                            color: const Color(0xFF152523),
                            fontSize: context.rs(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const ResponsiveGap(height: 4),
                        Text(
                          '대화 내용을 일정과 정보로 정리해줘',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF60706D),
                            fontSize: context.rs(11),
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: context.rs(262),
          width: double.infinity,
          padding: context.insetsFromLTRB(20, 22, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFDCE6E3))),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _AttachmentAction(
                    icon: Icons.image_outlined,
                    label: '사진',
                    backgroundColor: const Color(0xFFE1F2EE),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('사진'),
                  ),
                  _AttachmentAction(
                    icon: Icons.photo_camera_outlined,
                    label: '카메라',
                    backgroundColor: const Color(0xFFEAF0FB),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('카메라'),
                  ),
                  _AttachmentAction(
                    icon: Icons.insert_drive_file_outlined,
                    label: '파일',
                    backgroundColor: const Color(0xFFF0ECFA),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('파일'),
                  ),
                  _AttachmentAction(
                    icon: Icons.location_on_outlined,
                    label: '위치',
                    backgroundColor: const Color(0xFFFFF0EC),
                    iconColor: const Color(0xFF0B5F55),
                    badgeText: '준비 중',
                    onTap: () => onActionTap('위치'),
                  ),
                ],
              ),
              const ResponsiveGap(height: 20),
              Row(
                children: [
                  _AttachmentAction(
                    icon: Icons.calendar_month_outlined,
                    label: '일정',
                    backgroundColor: const Color(0xFFDDF3EE),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('일정'),
                  ),
                  _AttachmentAction(
                    icon: Icons.receipt_long_outlined,
                    label: '정산',
                    backgroundColor: const Color(0xFFFFF6DF),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('정산'),
                  ),
                  _AttachmentAction(
                    icon: Icons.bar_chart_rounded,
                    label: '투표',
                    backgroundColor: const Color(0xFFEAF0FB),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('투표'),
                  ),
                  _AttachmentAction(
                    icon: Icons.contacts_outlined,
                    label: '연락처',
                    backgroundColor: const Color(0xFFEEF3F2),
                    iconColor: const Color(0xFF0B5F55),
                    onTap: () => onActionTap('연락처'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.badgeText,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rs(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: context.rs(66),
                height: context.rs(55),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: context.rs(50),
                      height: context.rs(50),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(context.rs(16)),
                      ),
                      child: Icon(icon, color: iconColor, size: context.rs(22)),
                    ),
                    if (badgeText != null)
                      Positioned(
                        top: context.rs(-5),
                        right: context.rs(0),
                        child: Container(
                          padding: context.symmetricInsets(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A33D),
                            borderRadius: BorderRadius.circular(
                              context.rs(999),
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rs(8),
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const ResponsiveGap(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF152523),
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

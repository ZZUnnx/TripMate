import 'package:flutter/material.dart';

import 'presentation/calendar_formatters.dart';
import 'presentation/calendar_view_data.dart';

import '../../models/trip.dart';
import 'calendar_circle_button.dart';
import '../common/responsive.dart';

class AddScheduleSheet extends StatefulWidget {
  const AddScheduleSheet({
    super.key,
    required this.trips,
    required this.initialDate,
  });

  final List<Trip> trips;
  final DateTime initialDate;

  @override
  State<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<AddScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _tripId;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay? _scheduledTime;
  String _category = '관광';

  @override
  void initState() {
    super.initState();
    _tripId = widget.trips.first.id;
    _scheduledDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) {
      return;
    }

    setState(() => _scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() => _scheduledTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _tripId == null) {
      return;
    }

    Navigator.of(context).pop(
      CalendarScheduleDraft(
        tripId: _tripId!,
        title: _titleController.text.trim(),
        category: _category,
        scheduledDate: _scheduledDate,
        scheduledTime: _scheduledTime == null
            ? null
            : _formatTimeOfDay(_scheduledTime!),
        placeName: _nullIfBlank(_placeController.text),
        url: _nullIfBlank(_urlController.text),
        description: _nullIfBlank(_descriptionController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.rs(650)),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF9),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.rs(22)),
          ),
        ),
        child: SingleChildScrollView(
          padding: context.insetsFromLTRB(18, 16, 18, 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '일정 추가',
                        style: TextStyle(
                          color: const Color(0xFF152523),
                          fontSize: context.rs(18),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    CalendarCircleButton(
                      icon: Icons.close_rounded,
                      iconSize: 18,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 14),
                _SheetFieldLabel('여행'),
                DropdownButtonFormField<int>(
                  initialValue: _tripId,
                  items: widget.trips
                      .map(
                        (trip) => DropdownMenuItem<int>(
                          value: trip.id,
                          child: Text(
                            trip.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _tripId = value),
                  decoration: _sheetInputDecoration(context),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('제목'),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _sheetInputDecoration(
                    context,
                    hintText: '예: 해운대 산책',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '일정 제목을 입력해주세요.';
                    }

                    return null;
                  },
                ),
                const ResponsiveGap(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PickerField(
                        label: '날짜',
                        value: calendarFormatShortDate(_scheduledDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: _pickDate,
                      ),
                    ),
                    const ResponsiveGap(width: 8),
                    Expanded(
                      child: _PickerField(
                        label: '시간',
                        value: _scheduledTime == null
                            ? '시간 미정'
                            : _formatTimeOfDay(_scheduledTime!),
                        icon: Icons.access_time_rounded,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('카테고리'),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: const ['관광', '식당', '숙소', '교통', '예약', '기타']
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                  decoration: _sheetInputDecoration(context),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('장소'),
                TextFormField(
                  controller: _placeController,
                  textInputAction: TextInputAction.next,
                  decoration: _sheetInputDecoration(
                    context,
                    hintText: '장소명 또는 주소',
                  ),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('링크'),
                TextFormField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: _sheetInputDecoration(
                    context,
                    hintText: 'https://',
                  ),
                ),
                const ResponsiveGap(height: 10),
                _SheetFieldLabel('메모'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _sheetInputDecoration(context, hintText: '일정 메모'),
                ),
                const ResponsiveGap(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: context.rs(46),
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(Icons.add_rounded, size: context.rs(18)),
                    label: const Text('추가하기'),
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
      ),
    );
  }
}

class _SheetFieldLabel extends StatelessWidget {
  const _SheetFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(6)),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF60706D),
          fontSize: context.rs(11),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetFieldLabel(label),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.rs(12)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.rs(12)),
            child: Container(
              height: context.rs(48),
              padding: context.symmetricInsets(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDCE6E3)),
                borderRadius: BorderRadius.circular(context.rs(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF0B5F55),
                    size: context.rs(16),
                  ),
                  const ResponsiveGap(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF152523),
                        fontSize: context.rs(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _sheetInputDecoration(
  BuildContext context, {
  String? hintText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF8A9895)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: context.symmetricInsets(horizontal: 12, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFFDCE6E3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFF148776), width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFFF27864)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.rs(12)),
      borderSide: const BorderSide(color: Color(0xFFF27864), width: 1.4),
    ),
  );
}

String? _nullIfBlank(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute:00';
}

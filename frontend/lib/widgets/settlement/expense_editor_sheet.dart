import 'package:flutter/material.dart';

import '../../models/settlement.dart';
import '../common/responsive.dart';

class ExpenseEditorSheet extends StatefulWidget {
  const ExpenseEditorSheet({
    super.key,
    required this.members,
    required this.currentUserId,
    this.expense,
    this.initialDraft,
    this.submitLabel = '저장',
  });
  final List<SettlementMember> members;
  final int currentUserId;
  final SettlementExpense? expense;
  final ExpenseDraft? initialDraft;
  final String submitLabel;
  @override
  State<ExpenseEditorSheet> createState() => _ExpenseEditorSheetState();
}

class _ExpenseEditorSheetState extends State<ExpenseEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.initialDraft?.title ?? widget.expense?.title,
  );
  late final _amount = TextEditingController(
    text: (widget.initialDraft?.amount ?? widget.expense?.amount)?.toString(),
  );
  late final _place = TextEditingController(
    text: widget.initialDraft?.placeName ?? widget.expense?.placeName,
  );
  late int _payer;
  late DateTime _date;
  late Set<int> _participants;
  @override
  void initState() {
    super.initState();
    _payer =
        widget.initialDraft?.payerId ??
        widget.expense?.payerId ??
        (widget.members.any((m) => m.userId == widget.currentUserId)
            ? widget.currentUserId
            : widget.members.first.userId);
    _date = widget.initialDraft?.date ?? widget.expense?.date ?? DateTime.now();
    _participants =
        (widget.initialDraft?.participantIds ??
                widget.expense?.participantIds ??
                widget.members.map((m) => m.userId).toList())
            .toSet();
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _place.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('분담 대상을 한 명 이상 선택해주세요.')));
      return;
    }
    Navigator.pop(
      context,
      ExpenseDraft(
        title: _title.text,
        amount: int.parse(_amount.text),
        payerId: _payer,
        date: _date,
        participantIds: _participants.toList()..sort(),
        placeName: _place.text.trim().isEmpty ? null : _place.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: context.symmetricInsets(horizontal: 24, vertical: 20),
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
                      widget.expense == null ? '지출 등록' : '지출 수정',
                      style: TextStyle(
                        fontSize: context.rs(20),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const ResponsiveGap(height: 14),
              TextFormField(
                controller: _title,
                maxLength: 100,
                decoration: const InputDecoration(labelText: '지출 이름'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '지출 이름을 입력해주세요.' : null,
              ),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '금액 (원)'),
                validator: (v) {
                  final amount = int.tryParse(v ?? '');
                  return amount == null || amount <= 0 || amount > 1000000000000
                      ? '1원 이상, 1조원 이하의 정수를 입력해주세요.'
                      : null;
                },
              ),
              const ResponsiveGap(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _payer,
                decoration: const InputDecoration(labelText: '결제자'),
                items: widget.members
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.userId,
                        child: Text(m.nickname),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _payer = v);
                },
              ),
              const ResponsiveGap(height: 14),
              TextFormField(
                controller: _place,
                maxLength: 100,
                decoration: const InputDecoration(labelText: '장소 (선택)'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text('${_date.year}.${_date.month}.${_date.day}'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (mounted && date != null) setState(() => _date = date);
                },
              ),
              const Text('분담 대상 · 선택한 참여자끼리 균등 분담'),
              const ResponsiveGap(height: 8),
              Wrap(
                spacing: 8,
                children: widget.members
                    .map(
                      (m) => FilterChip(
                        label: Text(m.nickname),
                        selected: _participants.contains(m.userId),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _participants.add(m.userId);
                          } else {
                            _participants.remove(m.userId);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
              const ResponsiveGap(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF148776),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.submitLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import 'responsive.dart';

BoxDecoration cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(context.rs(10)),
    boxShadow: [
      BoxShadow(
        color: const Color(0x10000000),
        blurRadius: context.rs(20),
        offset: Offset(0, context.rs(8)),
      ),
    ],
  );
}

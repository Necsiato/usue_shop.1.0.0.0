import 'package:flutter/material.dart';

bool isWide(BuildContext context) => MediaQuery.of(context).size.width >= 900;

int gridCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > 1200) return 4;
  if (width > 900) return 3;
  if (width > 600) return 2;
  return 1;
}

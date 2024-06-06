import 'package:flutter/material.dart';
import 'package:saferead/api.dart';

abstract class BasePage extends StatelessWidget {
  final BackendAPI api;

  const BasePage(this.api, {super.key});
}
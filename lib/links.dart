import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: thay bằng kênh hỗ trợ thật của bạn
const facebookUrl = 'https://www.facebook.com/cachuon.23';
const discordUrl = 'https://discord.gg/your-invite';

Future<void> openLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger.showSnackBar(const SnackBar(content: Text('Không mở được liên kết')));
  }
}
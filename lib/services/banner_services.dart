import 'package:flutter/material.dart';

class BannerService {
  static final BannerService _instance = BannerService._internal();
  factory BannerService() => _instance;

  BannerService._internal();

  OverlayEntry? _overlayEntry;

  void showBanner(BuildContext context, String message, {Color color = Colors.red}) {
    _removeBanner();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 70,
        left: 20,
        right: 20,
        child: _AppBanner(message: message, backgroundColor: color),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () => _removeBanner());
  }

  void _removeBanner() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _AppBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const _AppBanner({
    required this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.teal, width: 1),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//BannerService().showBanner(context, "please agree to Terms and Policy");
import 'package:flutter/material.dart';

class RewardAnimation {
  static void showReward(BuildContext context, int points) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: MediaQuery.of(context).size.width * 0.3,
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          onEnd: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              entry.remove();
            });
          },
          builder: (context, value, child) {
            return Opacity(
              opacity: value <= 0.8 ? value : (1 - value) * 5,
              child: Transform.translate(
                offset: Offset(0, -50 * value),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 40),
                      const SizedBox(width: 8),
                      Text(
                        '+$points',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    overlay.insert(entry);

    // Also show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Luar biasa! Anda mendapatkan $points poin.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

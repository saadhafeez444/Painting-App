import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<String> icons;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double barHeight = 65;
    final double iconSize = 57;
    final double notchRadius = 38;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSpacing = screenWidth / icons.length;
    final double selectedIconCenter = iconSpacing * selectedIndex + iconSpacing / 2;

    return SizedBox(
      height: barHeight + notchRadius,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: barHeight,
              child: Stack(
                children: [
                  // Black background behind the curve
                  Container(
                    height: barHeight,
                    decoration:  BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),

                  // White clipped bar with curve
                  ClipPath(
                    clipper: DeepCurveClipper(centerX: selectedIconCenter, radius: notchRadius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: barHeight,
                      decoration:  BoxDecoration(
                        // color: Colors.white,
                         gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(icons.length, (index) {
                          final isSelected = index == selectedIndex;
                          return GestureDetector(
                            onTap: () => onTap(index),
                            child: SizedBox(
                              height: barHeight,
                              width: 60,
                              child: Center(
                                child: !isSelected
                                    ? Image.asset(
                                  icons[index],
                                  height: 24,
                                  width: 24,
                                )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: barHeight - notchRadius,
            left: selectedIconCenter - iconSize / 2,
            child: GestureDetector(
              onTap: () => onTap(selectedIndex),
              child: Container(
                height: iconSize,
                width: iconSize,

                decoration: BoxDecoration(
                  color: const Color(0xff76CAC6),
                  shape: BoxShape.circle,
                  // border: Border.all(color: Colors.white, width: 5),
                ),
                child: Center(
                  child: Image.asset(
                  
                    icons[selectedIndex],
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class DeepCurveClipper extends CustomClipper<Path> {
  final double centerX;
  final double radius;

  DeepCurveClipper({required this.centerX, required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();

    final double dipDepth = radius * 1.2; // More depth for space under the icon
    final double dipWidth = radius * 1.2; // Wider curve

    path.moveTo(0, 0);
    path.lineTo(centerX - dipWidth, 0);

    path.cubicTo(
      centerX - dipWidth * 0.8, 0,        // Control point 1 (entry slope)
      centerX - dipWidth * 0.8, dipDepth, // Control point 2 (deep base left)
      centerX, dipDepth,                  // Center bottom of U
    );
    path.cubicTo(
      centerX + dipWidth * 0.8, dipDepth, // Control point 3 (deep base right)
      centerX + dipWidth * 0.8, 0,        // Control point 4 (exit slope)
      centerX + dipWidth, 0,              // Exit point
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant DeepCurveClipper oldClipper) =>
      oldClipper.centerX != centerX || oldClipper.radius != radius;
}
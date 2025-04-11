import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 402,
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
      color: Colors.blue[50],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [menuButton(), Flexible(child: townHallName()), userIcon()],
      ),
    );
  }

  Widget menuButton() {
    return Container(
      width: 28,
      height: 28,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/home_button.png"),
          fit: BoxFit.contain,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFF5686E1)),
          borderRadius: BorderRadius.circular(5),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3F5686E1),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  Widget townHallName() {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'THE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF0000),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 0.92,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color(0xFF000000).withOpacity(0.30),
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => SweepGradient(
              colors: [
                Color(0xFFFF0000),
                Color(0xFFFFFFFF),
                Color(0xFF5686E1),
              ],
              stops: [0.28, 0.42, 0.96],
              transform: GradientRotation(0.90),
            ).createShader(bounds),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOWN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.92,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Color(0xFF000000).withOpacity(0.30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'HALL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5686E1),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 0.92,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color(0xFF000000).withOpacity(0.30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/user_icon.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
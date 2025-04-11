import 'package:flutter/material.dart';
import 'package:the_town_hall/widgets/location_search.dart';
import 'package:the_town_hall/widgets/gps_map.dart';

class MapAndSearch extends StatelessWidget{
  const MapAndSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 400, // Set a fixed height for the map
              child: GpsMap(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LocationSearchScreen(),
            ),
          ],
        ),
      ],
    );
  }

  ConstrainedBox gpsSearchBar() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 360, maxWidth: 720),
      child: Container(
        width: double.infinity,
        height: 56,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFECE6F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 8,
                          children: [gpsIcon(), gpsTextBox()],
                        ),
                      ),
                    ),
                    gpsTrailingIcon(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox gpsTrailingIcon() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [searchIcon()],
            ),
          ),
        ],
      ),
    );
  }

  Container searchIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(children: [Icon(Icons.search)]),
          ),
        ],
      ),
    );
  }

  Container gpsIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/gps_arrow.png"),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  SizedBox gpsTextBox() {
    return SizedBox(
      height: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.50,
            child: Text(
              'La Mesa, 92125',
              style: TextStyle(
                color: const Color(0xFF938E8E),
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: 0.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
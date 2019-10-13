import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FixedLocationGps extends StatelessWidget {
  final bool showFixedGpsIcon;
  const FixedLocationGps({@required this.showFixedGpsIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: showFixedGpsIcon == true
            ? Align(
                alignment: Alignment.center,
                child: new Icon(
                  Icons.gps_fixed,
                  size: 140.0,
                  color: Colors.red,
                ),
              )
            : Container());
  }
}
 // DELETE
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:example1/model/location_model.dart';
import 'package:example1/model/radius_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:great_circle_distance/great_circle_distance.dart';

import './bloc.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  @override
  MapsState get initialState =>
      InitialMapsState(); //Returns the state before any event has dispatched

  @override
  Stream<MapsState> mapEventToState(
    MapsEvent event,
  ) async* {
    if (event is GenerateMarkerWithRadius) {
      yield* _mapGenerateMarkerwithRadiusToMap(
          event.lastPosition, event.radius);
    } else if (event is IsRadiusFixedPressed) {
      yield* _mapRadiusFixedToMap(event.isRadiusFixed);
    } else if (event is GenerateMarkerToCompareLocation) {
      yield* _mapGenerateMarkerToCompareToMap(
          event.mapPosition, event.radiusLocation, event.radius);
    }
  }

  Stream<MapsState> _mapGenerateMarkerwithRadiusToMap(
      LatLng _position, double _radius) async* {
    try {
      yield Loading();
      Marker _marker = Marker(
        markerId: MarkerId(_position.toString()),
        position: _position,
        infoWindow: InfoWindow(
          title: 'Radius is $_radius meters',
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      Circle _circle = Circle(
        circleId: CircleId(_position.toString()),
        center: _position,
        radius: _radius,
        fillColor: Color(1778384895),
        strokeColor: Colors.red,
      );

      yield MarkerWithRadius(
          raidiusModel: RadiusModel(marker: _marker, circle: _circle));
    } catch (_) {
      yield Failure();
    }
  }

  Stream<MapsState> _mapRadiusFixedToMap(bool _isRadiusFixed) async* {
    if (_isRadiusFixed)
      yield RadiusFixedUpdate(radiusFixed: false);
    else
      yield RadiusFixedUpdate(radiusFixed: true);
  }

  Stream<MapsState> _mapGenerateMarkerToCompareToMap(
      LatLng _mapPostion, LatLng _radiusPostion, double _radius) async* {
    try {
      yield Loading();
      String message;
      Color colorSnack;
      var gcd = new GreatCircleDistance.fromDegrees(
          latitude1: _radiusPostion.latitude,
          longitude1: _radiusPostion.longitude,
          latitude2: _mapPostion.latitude,
          longitude2: _mapPostion.longitude);
      if (_radius >= gcd.haversineDistance()) {
        colorSnack = Colors.green;
      } else {
        colorSnack = Colors.red;
      }

      final _marker = Marker(
        markerId: MarkerId(_mapPostion.toString()),
        position: _mapPostion,
        infoWindow: InfoWindow(
          title: '${gcd.haversineDistance().toInt()} mts of radius',
        ),
        icon: colorSnack == Colors.green
            ? BitmapDescriptor.defaultMarkerWithHue(130.0)
            : BitmapDescriptor.defaultMarker,
      );
      yield MarkerWithSnackbar(marker: _marker);
    } catch (_) {
      yield Failure();
    }
  }
}

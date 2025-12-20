// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Zone {

 String get id; ZoneType get type; String get name; double get x;// Grid position X
 double get y;// Grid position Y
/// Demand curve: Map of hour (0-23) to multiplier
/// Example: {8: 2.0, 14: 1.5, 20: 0.1} means 2.0x at 8 AM, 1.5x at 2 PM, 0.1x at 8 PM
 Map<int, double> get demandCurve;/// Base traffic multiplier (0.5 to 2.0)
 double get trafficMultiplier;
/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ZoneCopyWith<Zone> get copyWith => _$ZoneCopyWithImpl<Zone>(this as Zone, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&const DeepCollectionEquality().equals(other.demandCurve, demandCurve)&&(identical(other.trafficMultiplier, trafficMultiplier) || other.trafficMultiplier == trafficMultiplier));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,x,y,const DeepCollectionEquality().hash(demandCurve),trafficMultiplier);

@override
String toString() {
  return 'Zone(id: $id, type: $type, name: $name, x: $x, y: $y, demandCurve: $demandCurve, trafficMultiplier: $trafficMultiplier)';
}


}

/// @nodoc
abstract mixin class $ZoneCopyWith<$Res>  {
  factory $ZoneCopyWith(Zone value, $Res Function(Zone) _then) = _$ZoneCopyWithImpl;
@useResult
$Res call({
 String id, ZoneType type, String name, double x, double y, Map<int, double> demandCurve, double trafficMultiplier
});




}
/// @nodoc
class _$ZoneCopyWithImpl<$Res>
    implements $ZoneCopyWith<$Res> {
  _$ZoneCopyWithImpl(this._self, this._then);

  final Zone _self;
  final $Res Function(Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? x = null,Object? y = null,Object? demandCurve = null,Object? trafficMultiplier = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ZoneType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,demandCurve: null == demandCurve ? _self.demandCurve : demandCurve // ignore: cast_nullable_to_non_nullable
as Map<int, double>,trafficMultiplier: null == trafficMultiplier ? _self.trafficMultiplier : trafficMultiplier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Zone].
extension ZonePatterns on Zone {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Zone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Zone value)  $default,){
final _that = this;
switch (_that) {
case _Zone():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Zone value)?  $default,){
final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ZoneType type,  String name,  double x,  double y,  Map<int, double> demandCurve,  double trafficMultiplier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.x,_that.y,_that.demandCurve,_that.trafficMultiplier);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ZoneType type,  String name,  double x,  double y,  Map<int, double> demandCurve,  double trafficMultiplier)  $default,) {final _that = this;
switch (_that) {
case _Zone():
return $default(_that.id,_that.type,_that.name,_that.x,_that.y,_that.demandCurve,_that.trafficMultiplier);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ZoneType type,  String name,  double x,  double y,  Map<int, double> demandCurve,  double trafficMultiplier)?  $default,) {final _that = this;
switch (_that) {
case _Zone() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.x,_that.y,_that.demandCurve,_that.trafficMultiplier);case _:
  return null;

}
}

}

/// @nodoc


class _Zone extends Zone {
  const _Zone({required this.id, required this.type, required this.name, required this.x, required this.y, final  Map<int, double> demandCurve = const {}, this.trafficMultiplier = 1.0}): _demandCurve = demandCurve,super._();
  

@override final  String id;
@override final  ZoneType type;
@override final  String name;
@override final  double x;
// Grid position X
@override final  double y;
// Grid position Y
/// Demand curve: Map of hour (0-23) to multiplier
/// Example: {8: 2.0, 14: 1.5, 20: 0.1} means 2.0x at 8 AM, 1.5x at 2 PM, 0.1x at 8 PM
 final  Map<int, double> _demandCurve;
// Grid position Y
/// Demand curve: Map of hour (0-23) to multiplier
/// Example: {8: 2.0, 14: 1.5, 20: 0.1} means 2.0x at 8 AM, 1.5x at 2 PM, 0.1x at 8 PM
@override@JsonKey() Map<int, double> get demandCurve {
  if (_demandCurve is EqualUnmodifiableMapView) return _demandCurve;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_demandCurve);
}

/// Base traffic multiplier (0.5 to 2.0)
@override@JsonKey() final  double trafficMultiplier;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ZoneCopyWith<_Zone> get copyWith => __$ZoneCopyWithImpl<_Zone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Zone&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&const DeepCollectionEquality().equals(other._demandCurve, _demandCurve)&&(identical(other.trafficMultiplier, trafficMultiplier) || other.trafficMultiplier == trafficMultiplier));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,name,x,y,const DeepCollectionEquality().hash(_demandCurve),trafficMultiplier);

@override
String toString() {
  return 'Zone(id: $id, type: $type, name: $name, x: $x, y: $y, demandCurve: $demandCurve, trafficMultiplier: $trafficMultiplier)';
}


}

/// @nodoc
abstract mixin class _$ZoneCopyWith<$Res> implements $ZoneCopyWith<$Res> {
  factory _$ZoneCopyWith(_Zone value, $Res Function(_Zone) _then) = __$ZoneCopyWithImpl;
@override @useResult
$Res call({
 String id, ZoneType type, String name, double x, double y, Map<int, double> demandCurve, double trafficMultiplier
});




}
/// @nodoc
class __$ZoneCopyWithImpl<$Res>
    implements _$ZoneCopyWith<$Res> {
  __$ZoneCopyWithImpl(this._self, this._then);

  final _Zone _self;
  final $Res Function(_Zone) _then;

/// Create a copy of Zone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? x = null,Object? y = null,Object? demandCurve = null,Object? trafficMultiplier = null,}) {
  return _then(_Zone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ZoneType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,demandCurve: null == demandCurve ? _self._demandCurve : demandCurve // ignore: cast_nullable_to_non_nullable
as Map<int, double>,trafficMultiplier: null == trafficMultiplier ? _self.trafficMultiplier : trafficMultiplier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_client_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ApiClientState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(KFailure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(KFailure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(KFailure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ApiClientStateInitial value) initial,
    required TResult Function(ApiClientStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ApiClientStateInitial value)? initial,
    TResult? Function(ApiClientStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ApiClientStateInitial value)? initial,
    TResult Function(ApiClientStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiClientStateCopyWith<$Res> {
  factory $ApiClientStateCopyWith(
          ApiClientState value, $Res Function(ApiClientState) then) =
      _$ApiClientStateCopyWithImpl<$Res, ApiClientState>;
}

/// @nodoc
class _$ApiClientStateCopyWithImpl<$Res, $Val extends ApiClientState>
    implements $ApiClientStateCopyWith<$Res> {
  _$ApiClientStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ApiClientStateInitialImplCopyWith<$Res> {
  factory _$$ApiClientStateInitialImplCopyWith(
          _$ApiClientStateInitialImpl value,
          $Res Function(_$ApiClientStateInitialImpl) then) =
      __$$ApiClientStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ApiClientStateInitialImplCopyWithImpl<$Res>
    extends _$ApiClientStateCopyWithImpl<$Res, _$ApiClientStateInitialImpl>
    implements _$$ApiClientStateInitialImplCopyWith<$Res> {
  __$$ApiClientStateInitialImplCopyWithImpl(_$ApiClientStateInitialImpl _value,
      $Res Function(_$ApiClientStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ApiClientStateInitialImpl implements ApiClientStateInitial {
  const _$ApiClientStateInitialImpl();

  @override
  String toString() {
    return 'ApiClientState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiClientStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(KFailure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(KFailure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(KFailure failure)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ApiClientStateInitial value) initial,
    required TResult Function(ApiClientStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ApiClientStateInitial value)? initial,
    TResult? Function(ApiClientStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ApiClientStateInitial value)? initial,
    TResult Function(ApiClientStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class ApiClientStateInitial implements ApiClientState {
  const factory ApiClientStateInitial() = _$ApiClientStateInitialImpl;
}

/// @nodoc
abstract class _$$ApiClientStateErrorImplCopyWith<$Res> {
  factory _$$ApiClientStateErrorImplCopyWith(_$ApiClientStateErrorImpl value,
          $Res Function(_$ApiClientStateErrorImpl) then) =
      __$$ApiClientStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({KFailure failure});

  $KFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$ApiClientStateErrorImplCopyWithImpl<$Res>
    extends _$ApiClientStateCopyWithImpl<$Res, _$ApiClientStateErrorImpl>
    implements _$$ApiClientStateErrorImplCopyWith<$Res> {
  __$$ApiClientStateErrorImplCopyWithImpl(_$ApiClientStateErrorImpl _value,
      $Res Function(_$ApiClientStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$ApiClientStateErrorImpl(
      failure: null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as KFailure,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $KFailureCopyWith<$Res> get failure {
    return $KFailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$ApiClientStateErrorImpl implements ApiClientStateError {
  const _$ApiClientStateErrorImpl({required this.failure});

  @override
  final KFailure failure;

  @override
  String toString() {
    return 'ApiClientState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiClientStateErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiClientStateErrorImplCopyWith<_$ApiClientStateErrorImpl> get copyWith =>
      __$$ApiClientStateErrorImplCopyWithImpl<_$ApiClientStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(KFailure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(KFailure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(KFailure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ApiClientStateInitial value) initial,
    required TResult Function(ApiClientStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ApiClientStateInitial value)? initial,
    TResult? Function(ApiClientStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ApiClientStateInitial value)? initial,
    TResult Function(ApiClientStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ApiClientStateError implements ApiClientState {
  const factory ApiClientStateError({required final KFailure failure}) =
      _$ApiClientStateErrorImpl;

  KFailure get failure;
  @JsonKey(ignore: true)
  _$$ApiClientStateErrorImplCopyWith<_$ApiClientStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

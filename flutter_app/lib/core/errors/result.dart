import 'failure.dart';

/// Stand-in for "no meaningful return value" — used instead of
/// `Result<void>`. Storing a generic type parameter bound to `void` in a
/// field (`final T value`) is a known Dart edge case; `Unit` sidesteps it
/// entirely and is the same pattern used by `Either<L, void>` alternatives
/// in packages like fpdart/dartz.
final class Unit {
  const Unit._();
  static const value = Unit._();
}

/// A minimal success-or-failure wrapper. Repository methods return this
/// instead of throwing, so a controller/UI can never forget to catch —
/// the type itself forces handling both branches.
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok<T>;
  factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) {
    final self = this;
    if (self is Ok<T>) return ok(self.value);
    if (self is Err<T>) return err(self.failure);
    throw StateError('Unreachable: Result must be Ok or Err');
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

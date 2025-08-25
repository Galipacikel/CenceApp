sealed class Result<S, F> {
  const Result();

  R fold<R>({
    required R Function(S) onSuccess,
    required R Function(F) onFailure,
  }) {
    final self = this;
    if (self is Success<S, F>) return onSuccess(self.value);
    return onFailure((self as Err<S, F>).error);
  }

  bool get isSuccess => this is Success<S, F>;
  bool get isFailure => this is Err<S, F>;

  S? get successOrNull =>
      this is Success<S, F> ? (this as Success<S, F>).value : null;
  F? get failureOrNull => this is Err<S, F> ? (this as Err<S, F>).error : null;

  static Result<S, F> ok<S, F>(S value) => Success(value);
  static Result<S, F> err<S, F>(F error) => Err(error);
}

final class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);
}

final class Err<S, F> extends Result<S, F> {
  final F error;
  const Err(this.error);
}

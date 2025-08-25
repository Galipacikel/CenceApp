/// Base UseCase abstraction for Clean Architecture
/// Each feature-specific use case should implement this contract.
abstract class UseCase<Out, Params> {
  Future<Out> call(Params params);
}

/// A placeholder for use cases that don't require parameters
class NoParams {
  const NoParams();
}
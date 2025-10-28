part of 'splash_cubit.dart';              

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  final bool isAnimating;
  final double animationValue;

  const SplashInitial({
    this.isAnimating = false,
    this.animationValue = 0.0,
  });

  @override
  List<Object?> get props => [isAnimating, animationValue];

  SplashInitial copyWith({
    bool? isAnimating,
    double? animationValue,
  }) {
    return SplashInitial(
      isAnimating: isAnimating ?? this.isAnimating,
      animationValue: animationValue ?? this.animationValue,
    );
  }
}

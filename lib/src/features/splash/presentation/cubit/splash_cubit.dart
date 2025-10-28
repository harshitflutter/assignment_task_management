import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class StartAnimation extends SplashEvent {
  const StartAnimation();
}

class CheckAuthStatus extends SplashEvent {
  const CheckAuthStatus();
}

// States
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

// Cubit
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashInitial());

  void startAnimation() {
    emit(const SplashInitial(isAnimating: true, animationValue: 0.0));

    // Simulate animation progress
    Future.delayed(const Duration(milliseconds: 100), () {
      emit(const SplashInitial(isAnimating: true, animationValue: 0.3));
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      emit(const SplashInitial(isAnimating: true, animationValue: 0.7));
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      emit(const SplashInitial(isAnimating: true, animationValue: 1.0));
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      emit(const SplashInitial(isAnimating: false, animationValue: 1.0));
    });
  }

  void checkAuthStatus() {
    emit(const SplashInitial(isAnimating: false, animationValue: 1.0));
  }
}

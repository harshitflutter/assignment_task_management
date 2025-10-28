import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

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

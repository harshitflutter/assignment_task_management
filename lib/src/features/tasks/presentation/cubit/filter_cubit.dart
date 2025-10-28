import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'filter_state.dart';

// Cubit
class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterInitial());

  void changeFilter(String filter) {
    final currentState = state as FilterInitial;
    emit(currentState.copyWith(selectedFilter: filter));
  }
}

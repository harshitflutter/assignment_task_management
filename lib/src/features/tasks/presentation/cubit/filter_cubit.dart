import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

class ChangeFilter extends FilterEvent {
  final String filter;
  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

// States
abstract class FilterState extends Equatable {
  const FilterState();

  @override
  List<Object?> get props => [];
}

class FilterInitial extends FilterState {
  final String selectedFilter;
  final List<String> availableFilters;

  const FilterInitial({
    this.selectedFilter = 'All',
    this.availableFilters = const ['All', 'Pending', 'Completed'],
  });

  @override
  List<Object?> get props => [selectedFilter, availableFilters];

  FilterInitial copyWith({
    String? selectedFilter,
    List<String>? availableFilters,
  }) {
    return FilterInitial(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      availableFilters: availableFilters ?? this.availableFilters,
    );
  }
}

// Cubit
class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterInitial());

  void changeFilter(String filter) {
    final currentState = state as FilterInitial;
    emit(currentState.copyWith(selectedFilter: filter));
  }
}

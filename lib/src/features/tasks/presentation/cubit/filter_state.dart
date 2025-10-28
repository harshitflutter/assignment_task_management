part of "filter_cubit.dart";
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
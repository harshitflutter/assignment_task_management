part of "form_cubit.dart";

// States
abstract class FormCubitState extends Equatable {
  const FormCubitState();

  @override
  List<Object?> get props => [];
}

class FormInitial extends FormCubitState {
  final String title;
  final String description;
  final DateTime? selectedDate;
  final String? attachmentPath;
  final String? attachmentName;

  const FormInitial({
    this.title = '',
    this.description = '',
    this.selectedDate,
    this.attachmentPath,
    this.attachmentName,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        selectedDate,
        attachmentPath,
        attachmentName,
      ];

  FormInitial copyWith({
    String? title,
    String? description,
    DateTime? selectedDate,
    String? attachmentPath,
    String? attachmentName,
  }) {
    return FormInitial(
      title: title ?? this.title,
      description: description ?? this.description,
      selectedDate: selectedDate ?? this.selectedDate,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}
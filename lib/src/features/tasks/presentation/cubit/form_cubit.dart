import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTitle extends FormEvent {
  final String title;
  const UpdateTitle(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdateDescription extends FormEvent {
  final String description;
  const UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdateDate extends FormEvent {
  final DateTime? date;
  const UpdateDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateAttachment extends FormEvent {
  final String? path;
  final String? name;
  const UpdateAttachment(this.path, this.name);

  @override
  List<Object?> get props => [path, name];
}

class ResetForm extends FormEvent {
  const ResetForm();
}

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

// Cubit
class FormCubit extends Cubit<FormCubitState> {
  FormCubit({
    String? initialTitle,
    String? initialDescription,
    DateTime? initialDate,
    String? initialAttachmentPath,
    String? initialAttachmentName,
  }) : super(FormInitial(
          title: initialTitle ?? '',
          description: initialDescription ?? '',
          selectedDate: initialDate,
          attachmentPath: initialAttachmentPath,
          attachmentName: initialAttachmentName,
        ));

  void updateTitle(String title) {
    final currentState = state as FormInitial;
    emit(currentState.copyWith(title: title));
  }

  void updateDescription(String description) {
    final currentState = state as FormInitial;
    emit(currentState.copyWith(description: description));
  }

  void updateDate(DateTime? date) {
    final currentState = state as FormInitial;
    emit(currentState.copyWith(selectedDate: date));
  }

  void updateAttachment(String? path, String? name) {
    final currentState = state as FormInitial;
    emit(currentState.copyWith(
      attachmentPath: path,
      attachmentName: name,
    ));
  }

  void resetForm() {
    emit(const FormInitial());
  }
}

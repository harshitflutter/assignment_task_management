import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part "form_state.dart";

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

import 'package:equatable/equatable.dart';

class ToDo extends Equatable {
  final String id;
  final String title;
  final bool isComplete;

  const ToDo({
    required this.id,
    required this.title,
    this.isComplete = false,
  });

  ToDo copyWith({
    String? id,
    String? title,
    bool? isComplete,
  }) {
    return ToDo(
      id: id ?? this.id,
      title: title ?? this.title,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  String toString() => 'ToDo(id: $id, title: $title, isComplete: $isComplete)';

  @override
  List<Object?> get props => [id, title, isComplete];
}
